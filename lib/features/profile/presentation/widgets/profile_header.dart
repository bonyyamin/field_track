import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/features/auth/entities/user_entity.dart';

/// User profile header card displaying user avatar, name, email, and role badge.
class ProfileHeader extends StatelessWidget {
  final UserEntity user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _formatRole(String role) {
    if (role.isEmpty) return 'Field User';
    final clean = role.replaceAll('_', ' ').trim();
    return clean
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final avatarBg = isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight;
    final avatarTextColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final nameTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final emailTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final badgeBg = isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight;
    final badgeTextColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final displayName = user.fullName.trim().isNotEmpty
        ? user.fullName
        : (user.email.isNotEmpty ? user.email.split('@').first : 'User');
    final initials = _getInitials(displayName);
    final formattedRole = _formatRole(user.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Avatar Circle
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: avatarBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTextStyles.headingMedium.copyWith(
                color: avatarTextColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // User Full Name
          Text(
            displayName,
            style: AppTextStyles.headingMedium.copyWith(
              color: nameTextColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // User Email
          Text(
            user.email,
            style: AppTextStyles.cardSubtitle.copyWith(
              color: emailTextColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 15,
                  color: badgeTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  formattedRole,
                  style: AppTextStyles.status.copyWith(
                    color: badgeTextColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}