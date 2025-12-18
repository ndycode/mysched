# MySched API Reference

This document describes the Supabase database schema, RLS policies, and data access patterns.

---

## Backend Overview

MySched uses **Supabase** as its backend-as-a-service:

- **Database**: PostgreSQL with Row Level Security
- **Authentication**: Supabase Auth (email/password, Google OAuth)
- **Storage**: Not currently used (OCR is on-device)
- **Realtime**: Available but currently polling-based

---

## Database Schema

### Core Tables

#### `profiles`

Stores user profile information, linked 1:1 with `auth.users`.

| Column | Type | Description |
|--------|------|-------------|
| `id` | uuid (PK) | References `auth.users(id)` |
| `full_name` | text | User's display name |
| `student_id` | text (unique) | Student ID number |
| `email` | text (unique) | Email address |
| `avatar_url` | text | Profile picture URL |
| `app_user_id` | integer | Auto-increment friendly ID |
| `created_at` | timestamptz | Creation timestamp |

#### `semesters`

Academic semester definitions.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint (PK) | Auto-increment ID |
| `code` | text (unique) | Semester code (e.g., "2024-2S") |
| `name` | text | Display name |
| `academic_year` | text | Academic year |
| `term` | integer | Term number (1-3) |
| `start_date` | date | Semester start |
| `end_date` | date | Semester end |
| `is_active` | boolean | Currently active semester |

#### `sections`

Class sections (e.g., "BSIT-3A").

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint (PK) | Auto-increment ID |
| `code` | text | Section code |
| `section_number` | text | Section number |
| `semester_id` | bigint (FK) | References `semesters(id)` |

#### `classes`

Individual class entries within a section.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint (PK) | Auto-increment ID |
| `section_id` | bigint (FK) | References `sections(id)` |
| `code` | text | Subject code |
| `title` | text | Subject title |
| `units` | integer | Credit units |
| `room` | text | Room location |
| `day` | dow (enum) | Day of week |
| `start` | time | Start time |
| `end` | time | End time |
| `instructor_id` | uuid (FK) | References `instructors(id)` |

#### `instructors`

Instructor directory.

| Column | Type | Description |
|--------|------|-------------|
| `id` | uuid (PK) | Auto-generated UUID |
| `full_name` | text | Instructor name |
| `email` | text | Email address |
| `avatar_url` | text | Profile picture |
| `title` | text | Title (e.g., "Prof.") |
| `department` | text | Department |
| `normalized_name` | text | Search-optimized name |

#### `reminders`

User reminders.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint (PK) | Auto-increment ID |
| `user_id` | uuid (FK) | References `auth.users(id)` |
| `title` | text | Reminder title (max 160 chars) |
| `details` | text | Reminder details |
| `due_at` | timestamptz | Due date/time |
| `status` | reminder_status | pending/completed/snoozed |
| `snooze_until` | timestamptz | Snooze expiry |
| `completed_at` | timestamptz | Completion timestamp |

#### `study_sessions`

Pomodoro session history.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint (PK) | Auto-increment ID |
| `user_id` | uuid (FK) | References `auth.users(id)` |
| `session_type` | text | work/short_break/long_break |
| `duration_minutes` | integer | Session duration |
| `started_at` | timestamptz | Start time |
| `completed_at` | timestamptz | End time |
| `class_id` | bigint (FK) | Optional linked class |
| `class_title` | text | Snapshot of class title |
| `skipped` | boolean | Was session skipped? |

#### `user_sections`

Links users to their enrolled sections.

| Column | Type | Description |
|--------|------|-------------|
| `user_id` | uuid (PK, FK) | References `auth.users(id)` |
| `section_id` | bigint (PK, FK) | References `sections(id)` |
| `added_at` | timestamptz | Enrollment timestamp |

#### `user_settings`

User preferences.

| Column | Type | Default | Description |
|--------|------|---------|-------------|
| `user_id` | uuid (PK, FK) | - | References `auth.users(id)` |
| `use_24_hour_format` | boolean | false | Time format preference |
| `haptic_feedback` | boolean | true | Haptics enabled |
| `class_alarms` | boolean | true | Class alarm notifications |
| `app_notifs` | boolean | true | In-app notifications |
| `quiet_week` | boolean | false | Mute all notifications |
| `class_lead_minutes` | integer | 5 | Minutes before class alert |
| `snooze_minutes` | integer | 5 | Snooze duration |
| `dnd_enabled` | boolean | false | Do-not-disturb mode |
| `dnd_start_time` | text | "22:00" | DND start |
| `dnd_end_time` | text | "07:00" | DND end |
| `alarm_volume` | integer | 80 | Volume (0-100) |
| `alarm_vibration` | boolean | true | Vibration enabled |
| `auto_refresh_minutes` | integer | 30 | Background refresh interval |

#### `user_class_overrides`

Per-class notification overrides.

| Column | Type | Description |
|--------|------|-------------|
| `user_id` | uuid (PK, FK) | References `auth.users(id)` |
| `class_id` | bigint (PK, FK) | References `classes(id)` |
| `enabled` | boolean | Override notification for this class |

#### `user_custom_classes`

User-created custom class entries.

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint (PK) | Auto-increment ID |
| `user_id` | uuid (FK) | References `auth.users(id)` |
| `day` | dow (enum) | Day of week |
| `start_time` | text | Start time (HH:mm) |
| `end_time` | text | End time (HH:mm) |
| `title` | text | Class title |
| `room` | text | Room location |
| `instructor` | text | Instructor name |
| `enabled` | boolean | Active flag |

---

## Row Level Security

All tables are protected by RLS policies. Users can only access their own data.

### Common Policy Pattern

```sql
-- Users can only read their own data
CREATE POLICY "Users can read own data"
ON table_name FOR SELECT
USING (auth.uid() = user_id);

-- Users can only insert their own data
CREATE POLICY "Users can insert own data"
ON table_name FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can only update their own data
CREATE POLICY "Users can update own data"
ON table_name FOR UPDATE
USING (auth.uid() = user_id);

-- Users can only delete their own data
CREATE POLICY "Users can delete own data"
ON table_name FOR DELETE
USING (auth.uid() = user_id);
```

### Special Cases

**profiles**: Created automatically via trigger on `auth.users` insert.

**classes/sections**: Read access for all authenticated users (shared schedule data).

**instructors**: Read access for all authenticated users (shared directory).

---

## Data Access Patterns

### Repository Pattern

Services use a repository pattern for data access:

```dart
class ScheduleRepository {
  static final instance = ScheduleRepository._();
  
  Future<List<ScheduleClass>> getClasses() async {
    final response = await Env.supa
        .from('classes')
        .select('*, instructor:instructors(*)')
        .eq('section_id', sectionId);
    return response.map(ScheduleClass.fromJson).toList();
  }
}
```

### Offline Queue

Write operations go through `OfflineQueue` when offline:

```dart
// In service
Future<void> saveReminder(Reminder reminder) async {
  if (ConnectionMonitor.instance.isOnline) {
    await Env.supa.from('reminders').insert(reminder.toJson());
  } else {
    OfflineQueue.instance.enqueue(
      table: 'reminders',
      operation: 'insert',
      data: reminder.toJson(),
    );
  }
}
```

### Caching Strategy

1. **Read-through cache**: Check local cache first, then network
2. **Write-through**: Update cache on successful write
3. **Cache invalidation**: Clear on sign-out or refresh

---

## Custom Types

### Enums

```sql
-- Day of week
CREATE TYPE dow AS ENUM ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');

-- Reminder status
CREATE TYPE reminder_status AS ENUM ('pending', 'completed', 'snoozed');
```

---

## Admin Tables

For admin dashboard (separate Next.js app):

| Table | Purpose |
|-------|---------|
| `admins` | Admin user registry |
| `audit_log` | Action audit trail |
| `class_issue_reports` | Student-reported issues |

---

## Common Queries

### Get user's schedule for today

```dart
final today = DateTime.now().weekday; // 1=Mon, 7=Sun
final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][today - 1];

final classes = await Env.supa
    .from('classes')
    .select('*, instructor:instructors(*)')
    .eq('day', dayName)
    .in_('section_id', userSectionIds)
    .order('start');
```

### Get pending reminders

```dart
final reminders = await Env.supa
    .from('reminders')
    .select()
    .eq('user_id', userId)
    .eq('status', 'pending')
    .gte('due_at', DateTime.now().toIso8601String())
    .order('due_at');
```

### Upsert user settings

```dart
await Env.supa
    .from('user_settings')
    .upsert({
      'user_id': userId,
      ...settings.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    });
```

---

## Error Handling

API errors are wrapped in service methods:

```dart
try {
  await Env.supa.from('reminders').insert(data);
} on PostgrestException catch (e) {
  TelemetryService.instance.logError('reminder_insert_failed', error: e);
  throw AppException('Failed to save reminder');
}
```

See [ERROR_HANDLING.md](ERROR_HANDLING.md) for error handling patterns.
