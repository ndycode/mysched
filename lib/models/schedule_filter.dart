/// Shared filter options for schedules across dashboard and detail screens.
enum ScheduleFilter {
  all,
  enabled,
  disabled,
  custom,
}

extension ScheduleFilterLabels on ScheduleFilter {
  String get label {
    switch (this) {
      case ScheduleFilter.all:
        return 'All';
      case ScheduleFilter.enabled:
        return 'Enabled';
      case ScheduleFilter.disabled:
        return 'Disabled';
      case ScheduleFilter.custom:
        return 'Custom';
    }
  }

  /// Returns true when the given class properties match this filter.
  bool includes({required bool enabled, required bool isCustom}) {
    switch (this) {
      case ScheduleFilter.all:
        return true;
      case ScheduleFilter.enabled:
        return enabled;
      case ScheduleFilter.disabled:
        return !enabled;
      case ScheduleFilter.custom:
        return isCustom;
    }
  }
}
