import 'package:flutter/material.dart';

/// Design system color tokens for FieldTrack (Light & Dark modes).
abstract final class AppColors {
  // ── Brand / Primary (buttons, active tabs, sliders, toggles, links) ──
  static const Color primaryLight = Color(0xFF0D9488);
  static const Color primaryDark = Color(0xFF2DD4BF);

  // Primary buttons text/icon color
  static const Color primaryButtonLight = Color(0xFF0D9488);
  static const Color primaryButtonDark = Color(0xFF2DD4BF);

  // Light/Dark tint for icon circles, avatar backgrounds, geofence circle fill
  static const Color primaryContainerLight = Color(0xFFD9F2EE);
  static const Color primaryContainerDark = Color(0xFF12332F);

  // Text/icon color sitting ON TOP of the primary background
  static const Color onPrimaryLight = Color(0xFFFFFFFF); // White text on teal button
  static const Color onPrimaryDark = Color(0xFF04211D); // Dark text on mint button

  // ── Backgrounds / Surfaces ──
  static const Color backgroundLight = Color(0xFFF4F6F8); // Scaffold background
  static const Color backgroundDark = Color(0xFF0E1521);

  static const Color surfaceLight = Color(0xFFFFFFFF); // Cards, tiles, bottom navigation
  static const Color surfaceDark = Color(0xFF18212F);

  // Search bar background, map placeholder background, inactive badge, disabled input
  static const Color surfaceVariantLight = Color(0xFFEDF0F3);
  static const Color surfaceVariantDark = Color(0xFF1F2A3A);

  // Input borders / card hairline borders / dividers
  static const Color borderLight = Color(0xFFE2E6EA);
  static const Color borderDark = Color(0xFF2A3444);

  // ── Text ──
  static const Color textPrimaryLight = Color(0xFF131A24);
  static const Color textPrimaryDark = Color(0xFFEEF2F7);
  static const Color textSecondaryLight = Color(0xFF5C6675);
  static const Color textSecondaryDark = Color(0xFF98A4B4);
  static const Color textHintLight = Color(0xFF9AA4B2); // Placeholder text
  static const Color textHintDark = Color(0xFF6B7686);

  // ── Status: Pending (Orange / Amber) ──
  static const Color pendingBgLight = Color(0xFFFBEFD7);
  static const Color pendingTextLight = Color(0xFFC8821A);
  static const Color pendingBgDark = Color(0xFF312511);
  static const Color pendingTextDark = Color(0xFFE0A33C);

  // ── Status: Completed / Active / Success (Green) ──
  static const Color successBgLight = Color(0xFFDDF4E7);
  static const Color successTextLight = Color(0xFF15A05A);
  static const Color successBgDark = Color(0xFF123227);
  static const Color successTextDark = Color(0xFF34C77B);

  // ── Status: Inactive (Grey) ──
  static const Color inactiveBgLight = Color(0xFFEDF0F3);
  static const Color inactiveTextLight = Color(0xFF7C8794);
  static const Color inactiveBgDark = Color(0xFF232E3E);
  static const Color inactiveTextDark = Color(0xFF8996A6);

  // ── Error / Destructive ──
  static const Color errorLight = Color(0xFFDC4040);
  static const Color errorDark = Color(0xFFE5595B);

  // ── Bottom Navigation ──
  static const Color navActiveLight = Color(0xFF0D9488);
  static const Color navActiveDark = Color(0xFF2DD4BF);
  static const Color navInactiveLight = Color(0xFF9AA4B2);
  static const Color navInactiveDark = Color(0xFF66738A);
}