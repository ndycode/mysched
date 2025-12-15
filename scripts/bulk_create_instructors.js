// Bulk create CSIT instructor auth accounts
// Run with: node scripts/bulk_create_instructors.js
//
// Prerequisites:
// 1. npm install @supabase/supabase-js
// 2. Set environment variables:
//    - SUPABASE_URL (your project URL)
//    - SUPABASE_SERVICE_ROLE_KEY (from Supabase Settings > API)

const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
    console.error('Missing required env vars: SUPABASE_URL and/or SUPABASE_SERVICE_ROLE_KEY');
    process.exit(1);
}

// Common password for all instructor accounts
const DEFAULT_PASSWORD = process.env.DEFAULT_PASSWORD || '12345678';
const EMAIL_DOMAIN = process.env.EMAIL_DOMAIN || 'mysched.test';

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false,
    },
});

async function fetchInstructors() {
    const { data, error } = await supabase
        .from('instructors')
        .select('id, full_name, email, user_id')
        .order('id', { ascending: true });

    if (error) {
        throw new Error(`Failed to fetch instructors: ${error.message}`);
    }

    return data ?? [];
}

function makeFallbackEmail(index) {
    return `instructor${index + 1}@${EMAIL_DOMAIN}`;
}

async function createInstructorAccounts() {
    const instructors = await fetchInstructors();
    console.log(`Fetched ${instructors.length} instructors.`);
    console.log(`Creating auth users with DEFAULT_PASSWORD from env (or fallback).`);

    const results = [];
    const usedEmails = new Set();

    for (let i = 0; i < instructors.length; i++) {
        const instructor = instructors[i];

        if (instructor.user_id) {
            results.push({ instructor_id: instructor.id, email: instructor.email, skipped: true, reason: 'already_linked' });
            continue;
        }

        const emailCandidate = (typeof instructor.email === 'string' && instructor.email.includes('@'))
            ? instructor.email
            : makeFallbackEmail(i);

        if (usedEmails.has(emailCandidate)) {
            results.push({ instructor_id: instructor.id, email: emailCandidate, success: false, error: 'duplicate_email_in_run' });
            continue;
        }
        usedEmails.add(emailCandidate);

        console.log(`[${i + 1}/${instructors.length}] Creating: ${emailCandidate} (${instructor.full_name})`);

        try {
            // Create auth user
            const { data: created, error: createError } = await supabase.auth.admin.createUser({
                email: emailCandidate,
                password: DEFAULT_PASSWORD,
                email_confirm: true, // Auto-confirm email
                user_metadata: {
                    full_name: instructor.full_name,
                    role: 'instructor',
                },
            });

            if (createError) {
                console.error(`  ❌ Failed to create user: ${createError.message}`);
                results.push({ instructor_id: instructor.id, email: emailCandidate, success: false, error: createError.message });
                continue;
            }

            const userId = created?.user?.id;
            if (!userId) {
                console.error('  ❌ Failed to create user: missing user id in response');
                results.push({ instructor_id: instructor.id, email: emailCandidate, success: false, error: 'missing_user_id' });
                continue;
            }

            // Update instructor record with user_id
            const { error: updateError } = await supabase
                .from('instructors')
                .update({ user_id: userId, email: emailCandidate })
                .eq('id', instructor.id);

            if (updateError) {
                console.error(`  ⚠️ User created but failed to link: ${updateError.message}`);
                results.push({ instructor_id: instructor.id, email: emailCandidate, user_id: userId, success: false, error: updateError.message });
                continue;
            }

            console.log(`  ✅ Created and linked: ${userId}`);
            results.push({ instructor_id: instructor.id, email: emailCandidate, user_id: userId, success: true });

        } catch (err) {
            console.error(`  ❌ Unexpected error: ${err.message}`);
            results.push({ instructor_id: instructor.id, email: emailCandidate, success: false, error: err.message });
        }
    }

    // Summary
    const successful = results.filter(r => r.success).length;
    const failed = results.filter(r => !r.success).length;

    console.log('\n========================================');
    console.log(`SUMMARY: ${successful} successful, ${failed} failed`);
    console.log('========================================\n');

    if (failed > 0) {
        console.log('Failed accounts:');
        results.filter(r => !r.success).forEach(r => {
            console.log(`  - ${r.email}: ${r.error}`);
        });
    }

    console.log('\nCreated accounts:');
    results.filter(r => r.success).forEach(r => console.log(`  - ${r.email}`));
}

createInstructorAccounts().catch(console.error);
