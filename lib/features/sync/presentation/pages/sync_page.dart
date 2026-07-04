import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import '../bloc/sync_bloc.dart';
import '../bloc/sync_event.dart';
import '../bloc/sync_state.dart';
import '../widgets/offline_status_card.dart';
import '../widgets/pending_change_tile.dart';
import '../widgets/pending_summary_card.dart';
import '../widgets/sync_now_button.dart';

/// Screen 08: Sync screen displaying offline status, pending upload list, and manual sync action.
class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successTextDark : AppColors.successTextLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Sync',
          style: AppTextStyles.headingMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.errorLight,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.successMessage != null && state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offline Status Banner if device is offline
                  if (state.isOffline) const OfflineStatusCard(),

                  // Pending summary card (3 changes pending / Last synced today...)
                  PendingSummaryCard(
                    count: state.pendingChanges.length,
                    lastSyncedAt: state.lastSyncedAt,
                  ),

                  // Section Title: WAITING TO UPLOAD
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'WAITING TO UPLOAD',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: textSecondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // Pending Changes List
                  Expanded(
                    child: state.pendingChanges.isEmpty
                        ? _buildEmptyState(context, isDark, textSecondary, successColor)
                        : ListView.builder(
                            itemCount: state.pendingChanges.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = state.pendingChanges[index];
                              return PendingChangeTile(item: item);
                            },
                          ),
                  ),

                  const SizedBox(height: 12),

                  // Sync Now Action Button
                  SyncNowButton(
                    isLoading: state.isSyncing,
                    enabled: !state.isSyncing,
                    onPressed: () {
                      context.read<SyncBloc>().add(const ManualSyncRequested());
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    Color textSecondary,
    Color successColor,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.successBgDark : AppColors.successBgLight,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: successColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All changes synced',
            style: AppTextStyles.cardTitle.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No pending updates waiting to upload',
            style: AppTextStyles.cardSubtitle.copyWith(
              color: textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}