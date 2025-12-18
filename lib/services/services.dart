// =============================================================================
// Services - Business logic and data access layer
// =============================================================================
// This barrel file exports all services, organized by category.
// Import via: import 'package:mysched/services/services.dart';
// =============================================================================

// ---------------------------------------------------------------------------
// Authentication & User Profile
// ---------------------------------------------------------------------------
export 'auth_service.dart';
export 'profile_cache.dart';
export 'user_scope.dart';
// Note: user_settings.dart not exported - use user_settings_service.dart instead
export 'user_settings_service.dart';
export 'onboarding_service.dart';
export 'admin_service.dart';

// ---------------------------------------------------------------------------
// Schedule Management
// ---------------------------------------------------------------------------
export 'schedule_repository.dart';
export 'schedule_service.dart';
export 'schedule_export_service.dart';
export 'schedule_share_service.dart';
export 'semester_service.dart';
export 'scan_service.dart';
export 'instructor_service.dart';

// ---------------------------------------------------------------------------
// Reminders & Tasks
// ---------------------------------------------------------------------------
export 'reminders_repository.dart';
export 'reminder_scope_store.dart';

// ---------------------------------------------------------------------------
// Study Timer & Stats
// ---------------------------------------------------------------------------
export 'study_timer_service.dart';
export 'study_session_repository.dart';
export 'stats_service.dart';

// ---------------------------------------------------------------------------
// Notifications & Alarms
// ---------------------------------------------------------------------------
export 'notification_scheduler.dart';
export 'widget_service.dart';

// ---------------------------------------------------------------------------
// Sync & Offline Support
// ---------------------------------------------------------------------------
export 'connection_monitor.dart';
export 'offline_queue.dart';
export 'offline_cache_service.dart';
export 'data_sync.dart';
export 'export_queue.dart';

// ---------------------------------------------------------------------------
// Navigation & UI State
// ---------------------------------------------------------------------------
export 'navigation_channel.dart';
export 'root_nav_controller.dart';
export 'theme_controller.dart';

// ---------------------------------------------------------------------------
// Analytics & Telemetry
// ---------------------------------------------------------------------------
export 'analytics_service.dart';
export 'telemetry_service.dart';

// ---------------------------------------------------------------------------
// Sharing
// ---------------------------------------------------------------------------
export 'share_service.dart';
