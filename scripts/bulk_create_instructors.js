// Bulk create CSIT instructor auth accounts
// Run with: node scripts/bulk_create_instructors.js
//
// Prerequisites:
// 1. npm install @supabase/supabase-js
// 2. Set environment variables:
//    - SUPABASE_URL (your project URL)
//    - SUPABASE_SERVICE_ROLE_KEY (from Supabase Settings > API)

const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL || 'YOUR_SUPABASE_URL';
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || 'YOUR_SERVICE_ROLE_KEY';

// Common password for all instructor accounts
const DEFAULT_PASSWORD = '12345678';

// Function to extract last name and generate email
function generateEmail(fullName) {
    // Full name format: "LastName, FirstName" or "LastName Jr., FirstName"
    const parts = fullName.split(',');
    if (parts.length === 0) return null;

    let lastName = parts[0].trim();

    // Remove Jr., Sr., III, etc.
    lastName = lastName.replace(/\s+(Jr\.?|Sr\.?|III|II|IV)$/i, '');

    // Remove spaces (e.g., "De Jesus" -> "DeJesus")
    lastName = lastName.replace(/\s+/g, '');

    persistSession: false,
    },
});

async function createInstructorAccounts() {
    console.log(`Creating ${instructors.length} instructor accounts...`);
    console.log(`Default password: ${DEFAULT_PASSWORD}\n`);

    const results = [];

    for (let i = 0; i < instructors.length; i++) {
        const instructor = instructors[i];
        const email = `instructor${i + 1}@mysched.test`;

        console.log(`[${i + 1}/${instructors.length}] Creating: ${email} (${instructor.full_name})`);

        try {
            // Create auth user
            const { data: user, error: createError } = await supabase.auth.admin.createUser({
                email,
                password: DEFAULT_PASSWORD,
                email_confirm: true, // Auto-confirm email
                user_metadata: {
                    full_name: instructor.full_name,
                    role: 'instructor',
                },
            });

            if (createError) {
                console.error(`  ❌ Failed to create user: ${createError.message}`);
                results.push({ instructor_id: instructor.id, email, success: false, error: createError.message });
                continue;
            }

            // Update instructor record with user_id
            const { error: updateError } = await supabase
                .from('instructors')
                .update({ user_id: user.user.id, email })
                .eq('id', instructor.id);

            if (updateError) {
                console.error(`  ⚠️ User created but failed to link: ${updateError.message}`);
                results.push({ instructor_id: instructor.id, email, user_id: user.user.id, success: false, error: updateError.message });
                continue;
            }

            console.log(`  ✅ Created and linked: ${user.user.id}`);
            results.push({ instructor_id: instructor.id, email, user_id: user.user.id, success: true });

        } catch (err) {
            console.error(`  ❌ Unexpected error: ${err.message}`);
            results.push({ instructor_id: instructor.id, email, success: false, error: err.message });
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

    // Output credentials for reference
    console.log('\n📋 INSTRUCTOR CREDENTIALS');
    console.log('========================================');
    console.log(`Password (all accounts): ${DEFAULT_PASSWORD}`);
    console.log('\nEmails:');
    results.filter(r => r.success).forEach((r, i) => {
        const inst = instructors.find(x => x.id === r.instructor_id);
        console.log(`  ${r.email} - ${inst?.full_name}`);
    });
}

createInstructorAccounts().catch(console.error);
