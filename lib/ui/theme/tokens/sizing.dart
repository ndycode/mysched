import 'package:flutter/material.dart';

/// Icon size tokens for consistent icon dimensions across the app.
class AppIconSize {
  const AppIconSize();

  /// Bullet point icon size (8)
  final double bullet = 8;

  /// Checkmark icon size (10)
  final double check = 10;

  /// Extra small icon size (14)
  final double xs = 14;

  /// Small icon size (16)
  final double sm = 16;

  /// Medium icon size (20)
  final double md = 20;

  /// Large icon size (24)
  final double lg = 24;

  /// Extra large icon size (28)
  final double xl = 28;

  /// FAB icon size (32)
  final double fab = 32;

  /// Extra extra large icon size (40)
  final double xxl = 40;

  /// Display icon size (64)
  final double display = 64;
}

/// Centralized component size tokens for avatars, badges, and containers.
class AppComponentSize {
  const AppComponentSize();

  // Avatar sizes
  final double avatarXs = 24;
  final double avatarXsDense = 26;
  final double avatarSmDense = 28;
  final double avatarSm = 32;
  final double avatarMd = 36;
  final double avatarMdLg = 40;
  final double avatarLg = 42;
  final double avatarLgXl = 44;
  final double avatarXl = 48;
  final double avatarXlXxl = 52;

  /// Profile avatar radius (56) - for main profile avatars
  final double avatarProfile = 56;
  final double avatarXxl = 64;

  // Badge sizes
  final double badgeSm = 8;
  final double badgeMd = 16;

  /// Badge medium plus - for progress indicators with padding
  final double badgeMdPlus = 18;
  final double badgeLg = 24;

  // List item heights
  final double listItemSm = 48;
  final double listItemMd = 56;
  final double listItemLg = 64;

  // Divider/border thickness
  final double divider = 1;
  final double dividerThin = 0.5;
  final double dividerMedium = 1.2;

  /// Navigation bubble border thickness
  final double dividerNav = 1.4;
  final double dividerThick = 1.5;
  final double dividerBold = 2;
  final double strokeHeavy = 6;
  final double paddingAdjust = 2;

  // Button heights
  /// Compact icon/button size (used for small icon actions)
  final double buttonXs = 36;
  final double buttonSm = 44;
  final double buttonMd = 48;
  final double buttonLg = 52;

  // Card preview heights
  final double previewSm = 120;
  final double previewMd = 200;
  final double previewSmd = 140;
  final double previewLg = 280;

  // Progress indicator
  final double progressHeight = 4;
  final double progressWidth = 40;
  final double progressStroke = 2;

  // RefreshIndicator
  final double refreshDisplacement = 24;

  // Skeleton text block heights (approximate typography heights)
  final double skeletonTextXs = 12;
  final double skeletonTextSm = 14;
  final double skeletonTextMd = 16;
  final double skeletonTextLg = 18;
  final double skeletonTextXl = 20;
  final double skeletonTextXxl = 22;
  final double skeletonTextDisplay = 24;
  final double skeletonTextHero = 28;

  // Skeleton placeholder widths (content approximations)
  final double skeletonWidthXxs = 48;
  final double skeletonWidthXs = 60;
  final double skeletonWidthSm = 70;
  final double skeletonWidthMd = 80;
  final double skeletonWidthLg = 100;
  final double skeletonWidthXl = 120;
  final double skeletonWidthXxl = 140;
  final double skeletonWidthWide = 160;
  final double skeletonWidthFull = 180;
  final double skeletonWidthHero = 200;
  final double skeletonWidthMax = 220;

  // Crop dialog dimensions
  final double cropDialogMin = 220;
  final double cropDialogMax = 360;

  // Switch toggle dimensions
  final double switchWidth = 52;
  final double switchHeight = 32;
  final double switchThumbSize = 28;

  // Radio button dimensions
  final double radioOuter = 20;
  final double radioInner = 10;

  // Navigation bar dimensions
  final double navBubbleSize = 68;
  final double navBubbleLabelWidth = 114;
  final double navBubbleLabelHeight = 44;
  final double navBubbleInnerWidth = 88;
  final double navBubbleInnerHeight = 34;
  final double navItemWidth = 72;
  final double navItemHeight = 64;
  final double navFabSize = 56;

  /// Navigation FAB offset from top (negative)
  final double navFabOffset = -22;

  /// Navigation bubble outer offset from bottom (negative)
  final double navBubbleOuterOffset = -18;

  /// Navigation bubble inner offset from bottom (negative)
  final double navBubbleInnerOffset = -8;

  // Alarm preview dimensions
  final double alarmPreviewMinWidth = 420;
  final double alarmPreviewMaxWidth = 460;
  final double alarmPreviewMinHeight = 460;
  final double alarmPreviewMaxHeight = 560;
  final double alarmActionHeight = 62;
  final double alarmPillHeight = 34;

  // State illustration sizes
  /// Compact state icon container size (56)
  final double stateIconCompact = 56;

  /// Large state icon container size (88)
  final double stateIconLarge = 88;

  /// Compact state icon inner size (28)
  final double stateIconInnerCompact = 28;

  /// Large state icon inner size (36)
  final double stateIconInnerLarge = 36;
}

/// Font weight tokens for consistent typography emphasis.
class AppFontWeight {
  const AppFontWeight();

  /// Regular text (400)
  final FontWeight regular = FontWeight.w400;

  /// Medium emphasis (500)
  final FontWeight medium = FontWeight.w500;

  /// Semi-bold for labels and emphasis (600)
  final FontWeight semiBold = FontWeight.w600;

  /// Bold for headings and strong emphasis (700)
  final FontWeight bold = FontWeight.w700;

  /// Extra bold for hero/display text (800)
  final FontWeight extraBold = FontWeight.w800;
}
