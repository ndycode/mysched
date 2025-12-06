import 'package:flutter/material.dart';

/// Shadow blur radius presets and BoxShadow factories for consistent elevation effects.
class AppShadow {
  const AppShadow();

  /// Extra-small blur for subtle badges (4)
  final double xs = 4;

  /// Small blur for minimal elevation (6)
  final double sm = 6;

  /// Medium blur for standard tiles/cards (12)
  final double md = 12;

  /// Large blur for elevated cards (16)
  final double lg = 16;

  /// Button/action blur (18)
  final double action = 18;

  /// Extra-large blur for prominent cards (20)
  final double xl = 20;

  /// Glow effect blur (22)
  final double glow = 22;

  /// Card hover base blur (24)
  final double cardHover = 24;

  /// Hero card blur (26)
  final double hero = 26;

  /// Nav bubble inactive blur (30)
  final double navBubbleInactive = 30;

  /// Nav bubble active blur (36)
  final double navBubbleActive = 36;

  /// XXL blur for hero cards and modals (40)
  final double xxl = 40;

  /// Backdrop filter blur sigma for glass effects (16)
  final double backdropBlur = 16;

  // ---------------------------------------------------------------------------
  // Material Elevation Values
  // ---------------------------------------------------------------------------

  /// Dark mode popup elevation (8)
  final double elevationDark = 8;

  /// Light mode popup elevation (12)
  final double elevationLight = 12;

  /// Spread radius for indicator glow (0.5)
  final double spreadXs = 0.5;

  /// Spread radius for subtle glow effects (1)
  final double spreadSm = 1;

  /// Spread radius for active glow effects (2)
  final double spreadMd = 2;

  /// Spread radius for hero/card glow effects (10)
  final double spreadLg = 10;

  // ---------------------------------------------------------------------------
  // BoxShadow Factory Methods
  // ---------------------------------------------------------------------------

  /// Subtle elevation for chips, badges, and inline elements.
  BoxShadow elevation1(Color color) => BoxShadow(
        color: color,
        blurRadius: xs,
        offset: AppShadowOffset.xs,
      );

  /// Light elevation for list tiles and small cards.
  BoxShadow elevation2(Color color) => BoxShadow(
        color: color,
        blurRadius: sm,
        offset: AppShadowOffset.sm,
      );

  /// Standard elevation for cards and containers.
  BoxShadow elevation3(Color color) => BoxShadow(
        color: color,
        blurRadius: md,
        offset: AppShadowOffset.md,
      );

  /// Elevated cards with prominent shadow.
  BoxShadow elevation4(Color color) => BoxShadow(
        color: color,
        blurRadius: lg,
        offset: AppShadowOffset.lg,
      );

  /// High elevation for modals and sheets.
  BoxShadow elevation5(Color color) => BoxShadow(
        color: color,
        blurRadius: xl,
        offset: AppShadowOffset.xl,
      );

  /// Maximum elevation for floating action buttons and hero elements.
  BoxShadow elevation6(Color color) => BoxShadow(
        color: color,
        blurRadius: xxl,
        offset: AppShadowOffset.xxl,
      );

  /// Card shadow with customizable blur and offset.
  BoxShadow card(Color color,
          {double blur = 12, Offset offset = AppShadowOffset.sm}) =>
      BoxShadow(color: color, blurRadius: blur, offset: offset);

  /// Modal/sheet shadow with high elevation.
  BoxShadow modal(Color color, {bool isDark = false}) => BoxShadow(
        color: color,
        blurRadius: cardHover,
        offset: AppShadowOffset.modal,
      );

  /// Navigation bar shadow.
  BoxShadow navBar(Color color) => BoxShadow(
        color: color,
        blurRadius: navBubbleInactive,
        offset: AppShadowOffset.lg,
      );

  /// FAB/quick action button shadow with spread.
  BoxShadow fab(Color color, {bool active = false}) => BoxShadow(
        color: color,
        blurRadius: active ? navBubbleActive : navBubbleInactive,
        offset: active ? AppShadowOffset.navBubbleActive : AppShadowOffset.lg,
        spreadRadius: active ? spreadMd : 0,
      );

  /// Hint bubble shadow.
  BoxShadow bubble(Color color) => BoxShadow(
        color: color,
        blurRadius: hero,
        offset: AppShadowOffset.modal,
      );
}

/// Centralized shadow offset tokens.
///
/// Use these for consistent BoxShadow offsets.
class AppShadowOffset {
  const AppShadowOffset._();

  /// Minimal elevation offset
  static const Offset xs = Offset(0, 2);

  /// Small elevation offset
  static const Offset sm = Offset(0, 4);

  /// Medium elevation offset
  static const Offset md = Offset(0, 6);

  /// Large elevation offset
  static const Offset lg = Offset(0, 8);

  /// Modal/auth shell elevation offset
  static const Offset modal = Offset(0, 10);

  /// Extra-large elevation offset
  static const Offset xl = Offset(0, 12);

  /// Hero card elevation offset
  static const Offset hero = Offset(0, 14);

  /// Modal/hero elevation offset
  static const Offset xxl = Offset(0, 16);

  /// Sheet elevation offset
  static const Offset sheet = Offset(0, 18);

  /// Bubble/tooltip elevation offset
  static const Offset bubble = Offset(0, 20);

  /// Alarm preview elevation offset
  static const Offset alarm = Offset(0, 22);

  /// Quick actions panel offset
  static const Offset panel = Offset(0, 24);

  /// Layout body card elevation offset
  static const Offset layout = Offset(0, 28);

  /// Nav FAB inactive offset (10)
  static const Offset navFabInactive = Offset(0, 10);

  /// Nav FAB active offset (12)
  static const Offset navFabActive = Offset(0, 12);

  /// Nav bubble inactive offset (16)
  static const Offset navBubbleInactive = Offset(0, 16);

  /// Nav bubble active offset (18)
  static const Offset navBubbleActive = Offset(0, 18);

  /// Nav FAB lift offset (negative to raise above nav bar)
  static const Offset navFabLift = Offset(0, -4);

  /// Slide-in animation offset (subtle upward entry)
  static const Offset slideIn = Offset(0, 0.05);
}
