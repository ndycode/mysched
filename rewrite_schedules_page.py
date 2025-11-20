lines.extend([
    "    final value = raw.trim().toLowerCase();",
    "    final hasMeridian = value.endsWith('am') || value.endsWith('pm');",
    "    var text = value;",
    "    String meridian = '';",
    "    if (hasMeridian) {",
    "      meridian = text.substring(text.length - 2);",
    "      text = text.substring(0, text.length - 2).trim();",
    "    }",
    "    final parts = text.split(':');",
    "    if (parts.length != 2) {",
    "      return const TimeOfDay(hour: 0, minute: 0);",
    "    }",
    "    var hour = int.tryParse(parts[0]) ?? 0;",
    "    final minute = int.tryParse(parts[1]) ?? 0;",
    "    if (meridian == 'pm' && hour != 12) hour += 12;",
    "    if (meridian == 'am' && hour == 12) hour = 0;",
    "    hour = hour.clamp(0, 23);",
    "    final clampedMinute = minute.clamp(0, 59);",
    "    return TimeOfDay(hour: hour, minute: clampedMinute);",
    "  }",
    "",
    "  @override",
    "  void dispose() {
    "    _scrollController.dispose();
    "    super.dispose();
    "  }
])
