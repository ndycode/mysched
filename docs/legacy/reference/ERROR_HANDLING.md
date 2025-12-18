# MySched Error Handling

This document covers error handling patterns, user messaging, and crash reporting.

---

## Error Handling Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Error Sources                             │
├──────────────┬──────────────┬──────────────┬───────────────┤
│   Network    │   Database   │  Validation  │    Flutter    │
│   Errors     │   Errors     │   Errors     │    Errors     │
└──────┬───────┴──────┬───────┴──────┬───────┴───────┬───────┘
       │              │              │               │
       └──────────────┴──────────────┴───────────────┘
                              │
                      ┌───────┴───────┐
                      │   Catching    │
                      │   Layer       │
                      └───────┬───────┘
                              │
           ┌──────────────────┼──────────────────┐
           │                  │                  │
    ┌──────┴──────┐   ┌───────┴───────┐  ┌──────┴──────┐
    │  Telemetry  │   │  User Message │  │   Recovery  │
    │   (Sentry)  │   │   (Toast/UI)  │  │   Action    │
    └─────────────┘   └───────────────┘  └─────────────┘
```

---

## Global Error Handlers

### Flutter Errors

```dart
// main.dart
void _installErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    TelemetryService.instance.logError(
      'flutter_error',
      error: details.exception,
      stack: details.stack,
    );
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    TelemetryService.instance.logError(
      'platform_error',
      error: error,
      stack: stack,
    );
    return false; // Let Flutter handle the error
  };
}
```

### Zone Errors

```dart
await runZonedGuarded(() async {
  // App code
}, (error, stack) {
  TelemetryService.instance.logError(
    'zone_unhandled_error',
    error: error,
    stack: stack,
  );
});
```

### Sentry Integration

```dart
await SentryFlutter.init((options) {
  options.dsn = const String.fromEnvironment('SENTRY_DSN');
  options.tracesSampleRate = 0.2;
  options.sendDefaultPii = false;  // Privacy: no PII
});
```

---

## Service-Level Error Handling

### Repository Pattern

```dart
class ScheduleRepository {
  Future<List<ScheduleClass>> getClasses() async {
    try {
      final response = await Env.supa.from('classes').select();
      return response.map(ScheduleClass.fromJson).toList();
    } on PostgrestException catch (e) {
      TelemetryService.instance.logError(
        'schedule_fetch_failed',
        error: e,
        data: {'code': e.code, 'message': e.message},
      );
      throw AppException('Failed to load schedule');
    } on SocketException catch (e) {
      TelemetryService.instance.logError(
        'schedule_network_error',
        error: e,
      );
      throw AppException('Network unavailable');
    }
  }
}
```

### Silent vs. User-Facing Errors

```dart
// User-facing: Throw AppException
throw AppException('Unable to save reminder');

// Silent: Log only, don't throw
TelemetryService.instance.logError('analytics_failed', error: e);
// Continue execution
```

---

## User-Facing Error Messages

### Message Structure

```
1. WHAT happened (briefly)
2. WHY it happened (if known)
3. WHAT to do next (actionable)
```

### Examples

```dart
// Network error
'Unable to sync schedule. Your device is offline. Changes will sync when connection is restored.'

// Server error
'Failed to load classes. The server is temporarily unavailable. Pull down to retry.'

// Authentication error
'Session expired. Please sign in again to continue.'

// Validation error
'Invalid student ID format. Use the format: 2024-12345 or 2024-12345-CC'
```

### Toast/Snackbar Usage

```dart
// Show error toast
ToastX.show(
  context,
  message: 'Failed to save reminder',
  type: ToastType.error,
  action: ToastAction(
    label: 'Retry',
    onPressed: () => saveReminder(),
  ),
);
```

---

## Error States in UI

### Empty vs. Error States

```dart
Widget build(BuildContext context) {
  if (error != null) {
    return StateDisplay.error(
      title: 'Unable to load schedule',
      message: 'Check your connection and try again',
      onRetry: () => fetchSchedule(),
    );
  }
  
  if (classes.isEmpty) {
    return StateDisplay.empty(
      title: 'No classes yet',
      message: 'Scan your schedule to get started',
    );
  }
  
  return ScheduleList(classes: classes);
}
```

### Inline Errors

```dart
// Form field errors
TextFormField(
  decoration: InputDecoration(
    errorText: emailError,  // Displays below field
  ),
  validator: (value) {
    if (!ValidationUtils.isValidEmail(value)) {
      return 'Enter a valid email address';
    }
    return null;
  },
)
```

---

## Error Recovery

### Retry Pattern

```dart
Future<T> withRetry<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      if (attempt >= maxAttempts) rethrow;
      await Future.delayed(delay * attempt);
    }
  }
}
```

### Offline Queue

```dart
// Queue writes when offline
class OfflineQueue {
  Future<void> enqueue({
    required String table,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    // Store in local queue
    // Flush when online
  }
}
```

---

## Specific Error Types

### Authentication Errors

```dart
try {
  await AuthService.instance.signIn(email, password);
} on AuthException catch (e) {
  switch (e.message) {
    case 'Invalid login credentials':
      showError('Incorrect email or password');
      break;
    case 'Email not confirmed':
      showError('Please verify your email first');
      break;
    default:
      showError('Sign in failed. Please try again.');
  }
}
```

### Network Errors

```dart
try {
  await fetchData();
} on SocketException {
  showError('No internet connection');
} on TimeoutException {
  showError('Request timed out. Check your connection.');
} on HttpException catch (e) {
  showError('Server error: ${e.message}');
}
```

### Database Errors

```dart
try {
  await Env.supa.from('reminders').insert(data);
} on PostgrestException catch (e) {
  if (e.code == '23505') {
    showError('This item already exists');
  } else if (e.code == '23503') {
    showError('Referenced item not found');
  } else {
    showError('Database error occurred');
  }
}
```

---

## Logging Best Practices

### What to Log

```dart
// ✅ Good: Contextual, actionable
TelemetryService.instance.logError(
  'reminder_save_failed',
  error: e,
  data: {
    'reminder_id': reminder.id,
    'error_code': e.code,
    'is_offline': ConnectionMonitor.instance.isOffline,
  },
);
```

### What NOT to Log

```dart
// ❌ Never log PII
TelemetryService.instance.logError(
  'login_failed',
  data: {
    'email': user.email,      // NEVER
    'password': password,      // NEVER
    'student_id': studentId,  // NEVER
  },
);
```

---

## Testing Error Scenarios

### Unit Tests

```dart
test('handles network error gracefully', () async {
  when(mockClient.get(any)).thenThrow(SocketException('No connection'));
  
  expect(
    () => repository.getClasses(),
    throwsA(isA<AppException>()),
  );
});
```

### Widget Tests

```dart
testWidgets('shows error state on fetch failure', (tester) async {
  when(mockRepo.getClasses()).thenThrow(AppException('Error'));
  
  await tester.pumpWidget(ScheduleScreen());
  await tester.pumpAndSettle();
  
  expect(find.text('Unable to load schedule'), findsOneWidget);
  expect(find.text('Retry'), findsOneWidget);
});
```

---

## Error Handling Checklist

For code reviews:

- [ ] All async operations wrapped in try-catch
- [ ] Errors logged with context (no PII)
- [ ] User-friendly messages shown
- [ ] Recovery action provided where possible
- [ ] Errors don't crash the app
- [ ] Network errors handled separately
- [ ] Validation errors show inline
- [ ] Tests cover error scenarios
