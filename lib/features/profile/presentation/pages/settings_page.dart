import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:field_tracker/features/settings/presentation/cubit/settings_state.dart';

/// Settings page for configuring app preferences, tracking modes, geofence, and app info.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showThemeSelector(BuildContext context, String currentTheme) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Theme',
          style: AppTextStyles.headingMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 18,
          ),
        ),
        children: ['System Default', 'Light Mode', 'Dark Mode'].map((opt) {
          final isSelected = opt == currentTheme;
          final activeColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
          return ListTile(
            title: Text(
              opt,
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: isSelected ? activeColor : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              size: 20,
            ),
            onTap: () {
              context.read<SettingsCubit>().updateTheme(opt);
              Navigator.of(ctx).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  void _showGpsModeSelector(BuildContext context, String currentGpsMode) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final modes = [
      {
        'title': 'High Accuracy',
        'label': 'High Accuracy (GPS + Wi-Fi)',
        'subtitle': 'Best for real-time precise geofencing',
      },
      {
        'title': 'Balanced Mode',
        'label': 'Balanced Mode (Accuracy vs Battery)',
        'subtitle': 'Optimal battery usage with cellular fallback',
      },
      {
        'title': 'Battery Saver Mode',
        'label': 'Battery Saver Mode',
        'subtitle': 'Updates position less frequently for maximum battery life',
      },
    ];

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'GPS Tracking Accuracy',
          style: AppTextStyles.headingMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 18,
          ),
        ),
        children: modes.map((m) {
          final isSelected = m['title'] == currentGpsMode;
          return ListTile(
            title: Text(
              m['label']!,
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              m['subtitle']!,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            trailing: Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: isSelected ? activeColor : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              size: 20,
            ),
            onTap: () {
              context.read<SettingsCubit>().updateGpsMode(m['title']!);
              Navigator.of(ctx).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  void _showGeofenceRadiusSelector(BuildContext context, int currentRadius) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final radii = [100, 150, 250, 500];

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Default Geofence Radius',
          style: AppTextStyles.headingMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 18,
          ),
        ),
        children: radii.map((r) {
          final isSelected = r == currentRadius;
          return ListTile(
            title: Text(
              '$r meters',
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: isSelected ? activeColor : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              size: 20,
            ),
            onTap: () {
              context.read<SettingsCubit>().updateDefaultGeofenceRadius(r);
              Navigator.of(ctx).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  void _showInfoModal(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Close',
                  style: AppTextStyles.button.copyWith(
                    color: isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final activeColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: textColor,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Settings',
              style: AppTextStyles.headingMedium.copyWith(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section 1: Appearance & Language ──
                _buildSectionHeader('Appearance & Language', textColor),
                const SizedBox(height: 10),
                _buildCardContainer(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  isDark: isDark,
                  children: [
                    _buildTile(
                      icon: Icons.palette_outlined,
                      title: 'App Theme',
                      subtitle: state.themeModeStr,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () => _showThemeSelector(context, state.themeModeStr),
                    ),
                    Divider(height: 1, color: borderColor, indent: 52, endIndent: 16),
                    _buildTile(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: state.settings.language,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      trailingWidget: _buildComingSoonBadge(isDark),
                      onTap: () => _showInfoModal(
                        context,
                        'Language Selection',
                        'Multi-language support (Spanish, French, German) is coming soon in a future update!',
                      ),
                    ),
                    Divider(height: 1, color: borderColor, indent: 52, endIndent: 16),
                    _buildTile(
                      icon: Icons.map_outlined,
                      title: 'Default Map Style',
                      subtitle: state.settings.mapStyle,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      trailingWidget: _buildComingSoonBadge(isDark),
                      onTap: () => _showInfoModal(
                        context,
                        'Default Map Style',
                        'Map style customization (Satellite, Terrain, Dark Maps) is coming soon in a future update!',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Section 2: Location & Tracking ──
                _buildSectionHeader('Location & Tracking', textColor),
                const SizedBox(height: 10),
                _buildCardContainer(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  isDark: isDark,
                  children: [
                    _buildTile(
                      icon: Icons.gps_fixed_rounded,
                      title: 'GPS Mode',
                      subtitle: state.gpsMode,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () => _showGpsModeSelector(context, state.gpsMode),
                    ),
                    Divider(height: 1, color: borderColor, indent: 52, endIndent: 16),
                    _buildTile(
                      icon: Icons.radar_rounded,
                      title: 'Default Geofence Radius',
                      subtitle: '${state.defaultGeofenceRadius} m',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () => _showGeofenceRadiusSelector(context, state.defaultGeofenceRadius),
                    ),
                    Divider(height: 1, color: borderColor, indent: 52, endIndent: 16),
                    SwitchListTile(
                      activeThumbColor: activeColor,
                      secondary: Icon(Icons.wifi_rounded, color: activeColor, size: 22),
                      title: Text(
                        'Auto-Sync on Wi-Fi',
                        style: AppTextStyles.body.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Automatically upload pending logs when connected to Wi-Fi',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          color: secondaryTextColor,
                          fontSize: 12.5,
                        ),
                      ),
                      value: state.autoSyncWifi,
                      onChanged: (val) => context.read<SettingsCubit>().updateAutoSync(val),
                    ),
                    Divider(height: 1, color: borderColor, indent: 52, endIndent: 16),
                    SwitchListTile(
                      activeThumbColor: activeColor,
                      secondary: Icon(Icons.location_on_outlined, color: activeColor, size: 22),
                      title: Text(
                        'Background Location',
                        style: AppTextStyles.body.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Allow geofence checks while app is minimized',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          color: secondaryTextColor,
                          fontSize: 12.5,
                        ),
                      ),
                      value: state.backgroundLocationEnabled,
                      onChanged: (val) => context.read<SettingsCubit>().updateBackgroundLocation(val),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Section 3: About & Legal ──
                _buildSectionHeader('About & Legal', textColor),
                const SizedBox(height: 10),
                _buildCardContainer(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  isDark: isDark,
                  children: [
                    _buildTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Version & Build',
                      subtitle: 'FieldTrack v1.0.0 (Build 104)',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      showChevron: false,
                      onTap: () {},
                    ),
                    Divider(height: 1, color: borderColor, indent: 52, endIndent: 16),
                    _buildTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'View software usage terms',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () => _showInfoModal(
                        context,
                        'Terms of Service',
                        'By using FieldTrack, you agree to allow background location updates for geofencing compliance and task management within authorized zones.',
                      ),
                    ),
                    Divider(height: 1, color: borderColor, indent: 52, endIndent: 16),
                    _buildTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'View data collection & storage policy',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () => _showInfoModal(
                        context,
                        'Privacy Policy',
                        'FieldTrack encrypts offline local storage and only transmits location data during active geofence interactions.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComingSoonBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.amber.withValues(alpha: 0.15) : Colors.amber.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? Colors.amber.shade400 : Colors.amber.shade700,
          width: 0.8,
        ),
      ),
      child: Text(
        'Coming Soon',
        style: AppTextStyles.cardSubtitle.copyWith(
          color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: AppTextStyles.cardTitle.copyWith(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildCardContainer({
    required Color cardBg,
    required Color borderColor,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
    Widget? trailingWidget,
    bool showChevron = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor, size: 22),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.cardSubtitle.copyWith(
          color: secondaryTextColor,
          fontSize: 12.5,
        ),
      ),
      trailing: trailingWidget ??
          (showChevron
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: secondaryTextColor,
                  size: 20,
                )
              : null),
      onTap: onTap,
    );
  }
}
