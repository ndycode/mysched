# MySched Security Guidelines

This document describes security practices, authentication flows, and data protection measures.

---

## Security Overview

MySched handles student personal information and academic data. Security is implemented at multiple layers:

- **Authentication**: Supabase Auth with secure token management
- **Authorization**: Row Level Security (RLS) on all tables
- **Data Protection**: No PII in logs, on-device OCR processing
- **Transport**: HTTPS for all network communication

---

## Authentication

### Supported Methods

| Method | Description |
|--------|-------------|
| Email/Password | Standard Supabase Auth with email verification |
| Google OAuth | Native Google Sign-In integration |

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Email/Password Flow                       │
├─────────────────────────────────────────────────────────────┤
│  1. User enters credentials                                  │
│  2. AuthService.signUp() or signIn()                        │
│  3. Supabase validates credentials                          │
│  4. Email verification (signup only)                        │
│  5. Session tokens stored by Supabase SDK                   │
│  6. App redirects to authenticated state                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Google OAuth Flow                         │
├─────────────────────────────────────────────────────────────┤
│  1. User taps "Sign in with Google"                         │
│  2. GoogleSignIn SDK shows native picker                    │
│  3. ID token returned to app                                │
│  4. Token exchanged with Supabase Auth                      │
│  5. Profile completed if new user                           │
│  6. Session established                                     │
└─────────────────────────────────────────────────────────────┘
```

### Token Management

- **Storage**: Handled by Supabase Flutter SDK (secure storage)
- **Refresh**: Automatic token refresh by SDK
- **Expiry**: Session expiry detected via auth state listener
- **Logout**: Tokens cleared on sign-out

```dart
// Session state monitoring in env.dart
supa.auth.onAuthStateChange.listen((data) {
  if (data.event == AuthChangeEvent.signedOut) {
    // Handle session end
  }
});
```

---

## Authorization

### Row Level Security (RLS)

All database tables are protected by RLS policies. Users can only access their own data.

**Standard Policy Pattern:**

```sql
-- Users can only access their own records
CREATE POLICY "user_isolation" ON table_name
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

**Shared Data Access:**

Some tables (classes, sections, instructors) are readable by all authenticated users since they represent shared academic data.

```sql
CREATE POLICY "authenticated_read" ON classes
FOR SELECT
USING (auth.role() = 'authenticated');
```

### Service-Level Checks

Even with RLS, services include explicit user checks:

```dart
Future<void> deleteReminder(String reminderId) async {
  final userId = Env.supa.auth.currentUser?.id;
  if (userId == null) throw AuthException('Not authenticated');
  
  await Env.supa
      .from('reminders')
      .delete()
      .eq('id', reminderId)
      .eq('user_id', userId); // Belt and suspenders
}
```

---

## Data Protection

### Personal Information Handling

| Data Type | Storage | Protection |
|-----------|---------|------------|
| Email | Supabase Auth + profiles | RLS, encrypted at rest |
| Password | Supabase Auth | Hashed (bcrypt), never stored in app |
| Student ID | profiles table | RLS isolation |
| Profile Photo | URL reference | User-controlled, no hosting |
| Schedule Data | classes/sections | RLS isolation |
| Study Sessions | study_sessions | RLS isolation |

### OCR Processing

Images scanned for schedule extraction are:

- Processed **on-device** using Google ML Kit
- **Never uploaded** to servers
- **Discarded after extraction** (not stored)

```dart
// OCR is local only
final recognizer = TextRecognizer();
final result = await recognizer.processImage(inputImage);
// Image never leaves device
```

### Logging and Telemetry

**Sentry Configuration:**

```dart
await SentryFlutter.init((options) {
  options.sendDefaultPii = false;  // No PII in crash reports
  options.environment = kReleaseMode ? 'production' : 'development';
});
```

**Telemetry Rules:**

- Never log email addresses, student IDs, or names
- Log only event names and non-identifying metadata
- Sanitize error messages before sending

```dart
// Good: Non-identifying telemetry
TelemetryService.instance.recordEvent(
  'schedule_scan_completed',
  data: {'class_count': classes.length},
);

// Bad: Never do this
TelemetryService.instance.recordEvent(
  'user_login',
  data: {'email': user.email}, // NEVER
);
```

---

## Input Validation

### Client-Side Validation

All user inputs are validated before submission:

```dart
// Email validation
static bool isValidEmail(String email) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
}

// Student ID validation
static bool isValidStudentId(String id) {
  return RegExp(r'^\d{4}-\d{5}(-[A-Z]{2})?$').hasMatch(id);
}

// Password requirements
static bool isStrongPassword(String password) {
  return password.length >= 8;
}
```

### Server-Side Constraints

Database constraints provide defense in depth:

```sql
-- Title length constraint
CONSTRAINT reminders_title_check 
CHECK (char_length(title) <= 160);

-- Enum constraints
CONSTRAINT study_sessions_type_check 
CHECK (session_type IN ('work', 'short_break', 'long_break'));
```

---

## Network Security

### Transport Security

- All Supabase communication over HTTPS
- SSL/TLS encryption for data in transit
- Certificate pinning not currently implemented (future consideration)

### Offline Security

When offline:

- Write operations queued encrypted in SharedPreferences
- Queue flushed when connection restored
- Failed operations logged (without sensitive data)

---

## Session Security

### Session Expiration

- Sessions expire based on Supabase configuration
- App detects expiry via auth state listener
- User redirected to login on session end

### Logout Process

```dart
Future<void> signOut() async {
  // Clear local caches
  await _clearLocalData();
  
  // Clear notifications
  await LocalNotifs.cancelAll();
  
  // Sign out from Supabase
  await Env.supa.auth.signOut();
  
  // Navigate to welcome screen
  navKey.currentContext?.go(AppRoutes.welcome);
}
```

---

## Secure Development Practices

### Environment Variables

Secrets are never committed to source control:

```
# .env (gitignored)
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SENTRY_DSN=https://xxx@sentry.io/xxx
GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
```

### Build-Time Injection

Production builds use `--dart-define`:

```bash
flutter build apk \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

---

## Vulnerability Reporting

If you discover a security vulnerability:

1. **Do not** open a public issue
2. Email the maintainers directly
3. Include detailed reproduction steps
4. Allow reasonable time for fix before disclosure

---

## Security Checklist

For code reviews, verify:

- [ ] No PII logged or exposed in errors
- [ ] RLS policies cover new tables
- [ ] User ID checks in service methods
- [ ] Input validation on all user data
- [ ] Secrets not hardcoded
- [ ] Sensitive data not stored in plain SharedPreferences
