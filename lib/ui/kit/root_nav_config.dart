import 'package:flutter/material.dart';

class RootNavTabs {
  static const dashboard = 0;
  static const schedules = 1;
  static const reminders = 2;
  static const settings = 3;
}

const List<NavigationDestination> rootNavDestinations = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.event_note_outlined),
    selectedIcon: Icon(Icons.event_note),
    label: 'Schedules',
  ),
  NavigationDestination(
    icon: Icon(Icons.notifications_outlined),
    selectedIcon: Icon(Icons.notifications),
    label: 'Reminders',
  ),
  NavigationDestination(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    label: 'Settings',
  ),
];
