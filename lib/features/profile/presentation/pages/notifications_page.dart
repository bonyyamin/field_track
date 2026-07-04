import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:field_tracker/core/di/injection_container.dart';
import 'package:field_tracker/core/services/notification/notification_service.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/core/widgets/app_button.dart';

/// Screen for viewing and managing geofence notifications and notification settings.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _geofenceAlerts = true;
  bool _soundVibration = true;
  bool _syncAlerts = true;

  final List<Map<String, String>> _notificationLogs = [
    {
      'title': 'Location entered',
      'body': 'You entered Downtown Branch',
      'time': 'Just now',
    },
    {
      'title': 'Location entered',
      'body': 'You entered North Regional Office',
      'time': '2 hours ago',
    },
    {
      'title': 'Sync completed',
      'body': '3 pending task changes synced successfully',
      'time': 'Yesterday',
    },
  ];

  Future<void> _triggerTestNotification() async {
    try {
      await sl<NotificationService>().showEntryNotification('Downtown Branch');
      setState(() {
        _notificationLogs.insert(0, {
          'title': 'Location entered',
          'body': 'You entered Downtown Branch (Test)',
          'time': 'Just now',
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Test geofence notification sent!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send test notification: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
          'Notifications',
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
            // Settings Header
            Text(
              'Notification Preferences',
              style: AppTextStyles.cardTitle.copyWith(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            // Preferences Card Container
            Container(
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
              child: Column(
                children: [
                  SwitchListTile(
                    activeThumbColor: activeColor,
                    title: Text(
                      'Geofence Entry Alerts',
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Trigger notifications when entering saved geofence locations',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: secondaryTextColor,
                        fontSize: 12.5,
                      ),
                    ),
                    value: _geofenceAlerts,
                    onChanged: (val) => setState(() => _geofenceAlerts = val),
                  ),
                  Divider(height: 1, color: borderColor, indent: 16, endIndent: 16),
                  SwitchListTile(
                    activeThumbColor: activeColor,
                    title: Text(
                      'Sound & Vibration',
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Play alert sound and vibrate on geofence arrival',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: secondaryTextColor,
                        fontSize: 12.5,
                      ),
                    ),
                    value: _soundVibration,
                    onChanged: (val) => setState(() => _soundVibration = val),
                  ),
                  Divider(height: 1, color: borderColor, indent: 16, endIndent: 16),
                  SwitchListTile(
                    activeThumbColor: activeColor,
                    title: Text(
                      'Offline Sync Notifications',
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Notify when pending task updates complete synchronization',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: secondaryTextColor,
                        fontSize: 12.5,
                      ),
                    ),
                    value: _syncAlerts,
                    onChanged: (val) => setState(() => _syncAlerts = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test Notification Button
            AppButton.outline(
              label: 'Send Test Geofence Alert',
              icon: Icon(
                Icons.notifications_active_outlined,
                size: 20,
                color: activeColor,
              ),
              textColor: activeColor,
              backgroundColor: Colors.transparent,
              onPressed: _triggerTestNotification,
            ),

            const SizedBox(height: 28),

            // Activity Log Section
            Text(
              'Recent Notification Activity',
              style: AppTextStyles.cardTitle.copyWith(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notificationLogs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _notificationLogs[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryContainerDark
                              : AppColors.primaryContainerLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: activeColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: AppTextStyles.cardTitle.copyWith(
                                color: textColor,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['body']!,
                              style: AppTextStyles.cardSubtitle.copyWith(
                                color: secondaryTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item['time']!,
                        style: AppTextStyles.cardSubtitle.copyWith(
                          color: secondaryTextColor,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
