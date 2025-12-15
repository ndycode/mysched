import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_log.dart';

const _scope = 'OnboardingService';
const _tourCompletedKey = 'onboarding_tour_completed';
const _tourVersionKey = 'onboarding_tour_version';

/// Current tour version - bump this to show tour again after major updates.
const _currentTourVersion = 1;

/// Service for managing onboarding tour state.
class OnboardingService {
  OnboardingService._();
  static final OnboardingService instance = OnboardingService._();

  SharedPreferences? _prefs;
  bool _tourCompleted = false;
  int _completedVersion = 0;

  /// Whether the tour has been completed.
  bool get hasCompletedTour => _tourCompleted && _completedVersion >= _currentTourVersion;

  /// Whether we should show the tour.
  bool get shouldShowTour => !hasCompletedTour;

  /// Initialize the service.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _tourCompleted = _prefs?.getBool(_tourCompletedKey) ?? false;
    _completedVersion = _prefs?.getInt(_tourVersionKey) ?? 0;
    
    AppLog.debug(_scope, 'Initialized', data: {
      'completed': _tourCompleted,
      'version': _completedVersion,
      'current': _currentTourVersion,
    });
  }

  /// Mark the tour as completed.
  Future<void> completeTour() async {
    _tourCompleted = true;
    _completedVersion = _currentTourVersion;
    
    await _prefs?.setBool(_tourCompletedKey, true);
    await _prefs?.setInt(_tourVersionKey, _currentTourVersion);
    
    AppLog.info(_scope, 'Tour completed');
  }

  /// Reset the tour (for testing or settings).
  Future<void> resetTour() async {
    _tourCompleted = false;
    _completedVersion = 0;
    
    await _prefs?.remove(_tourCompletedKey);
    await _prefs?.remove(_tourVersionKey);
    
    AppLog.info(_scope, 'Tour reset');
  }
}

/// A single step in the onboarding tour.
class TourStep {
  const TourStep({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.targetKey,
  });

  /// Unique identifier for this step.
  final String id;

  /// Title shown in the tooltip.
  final String title;

  /// Description shown in the tooltip.
  final String description;

  /// Icon to display.
  final int icon; // IconData codePoint

  /// GlobalKey of the widget to highlight (optional).
  final String? targetKey;
}

/// Predefined tour steps for the app.
class TourSteps {
  static const List<TourStep> mainTour = [
    TourStep(
      id: 'welcome',
      title: 'Welcome to MySched!',
      description: 'Let\'s take a quick tour of the key features.',
      icon: 0xe156, // Icons.waving_hand
    ),
    TourStep(
      id: 'schedule',
      title: 'Your Schedule',
      description: 'View your weekly class schedule at a glance. Tap any class for details.',
      icon: 0xe614, // Icons.calendar_today
    ),
    TourStep(
      id: 'reminders',
      title: 'Reminders',
      description: 'Set reminders for classes, assignments, and more. Never miss a deadline.',
      icon: 0xe4ba, // Icons.notifications
    ),
    TourStep(
      id: 'timer',
      title: 'Study Timer',
      description: 'Use the Pomodoro timer to stay focused during study sessions.',
      icon: 0xe425, // Icons.timer
    ),
    TourStep(
      id: 'scan',
      title: 'Scan Schedule',
      description: 'Scan your official schedule to import all your classes automatically.',
      icon: 0xe0e4, // Icons.qr_code_scanner
    ),
    TourStep(
      id: 'done',
      title: 'You\'re All Set!',
      description: 'Explore the app and customize it to your needs. Good luck this semester!',
      icon: 0xe5ca, // Icons.check_circle
    ),
  ];
}
