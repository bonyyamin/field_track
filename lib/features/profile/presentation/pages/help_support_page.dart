import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/core/widgets/app_toast.dart';

/// Help & Support screen containing contact cards, FAQs, issue reporting, and system health status.
class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How does automated geofence entry tracking work?',
      'answer':
          'FieldTrack uses your device GPS to monitor designated operational zones. When you enter a registered location radius, the app automatically logs your entry time and updates your task status without requiring manual input.',
    },
    {
      'question': 'What happens to my tasks when I lose internet connectivity?',
      'answer':
          'All task updates, check-ins, and location entries are stored locally on your device in offline mode. Once a network connection is re-established, the background sync engine automatically transmits all pending updates to the cloud.',
    },
    {
      'question': 'How can I adjust the boundary radius of a location?',
      'answer':
          'Go to the Locations tab, tap on the desired location item, and select "Edit Location". You can modify the radius slider between 50 meters and 500 meters.',
    },
    {
      'question': 'Why am I not receiving entry notifications?',
      'answer':
          'Ensure that Location Services are set to "Always Allow" in your device settings and that Notifications are enabled for FieldTrack.',
    },
    {
      'question': 'How do I trigger a manual sync?',
      'answer':
          'Navigate to the Sync tab from the bottom navigation bar and tap the "Sync Now" button to force an immediate server synchronization.',
    },
  ];

  void _showFeedbackModal() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final activeColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    String selectedCategory = 'Bug Report';
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Report Issue / Feedback',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Our support team responds within 24 hours.',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: secondaryTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),

                // Issue Category Selector
                Text('Category', style: AppTextStyles.fieldLabel.copyWith(color: textColor)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  dropdownColor: cardBg,
                  style: AppTextStyles.body.copyWith(color: textColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: activeColor)),
                  ),
                  items: ['Bug Report', 'Geofence Error', 'Feature Request', 'General Query'].map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedCategory = val);
                  },
                ),
                const SizedBox(height: 14),

                // Description text field
                Text('Description', style: AppTextStyles.fieldLabel.copyWith(color: textColor)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  style: AppTextStyles.inputText.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Describe the issue or feedback in detail...',
                    hintStyle: AppTextStyles.cardSubtitle.copyWith(color: secondaryTextColor),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: activeColor)),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      AppToast.show(
                        context,
                        message: 'Thank you! Your ticket has been submitted.',
                      );
                    },
                    child: Text(
                      'Submit Ticket',
                      style: AppTextStyles.button.copyWith(
                        color: isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactSnackBar(String channel) {
    AppToast.show(
      context,
      message: 'Opening $channel...',
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
    final successColor = isDark ? AppColors.successTextDark : AppColors.successTextLight;

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
          'Help & Support',
          style: AppTextStyles.headingMedium.copyWith(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── System Status Banner Card ──
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: successColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'All Geofence Tracking Systems Operational',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Section 1: Contact Support ──
                  Text(
                    'Contact Support',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactActionCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Chat Support',
                          subtitle: 'Chat live with an agent',
                          color: activeColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          onTap: () => _showContactSnackBar('Live Chat'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildContactActionCard(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email Support',
                          subtitle: 'Get answers in 24h',
                          color: activeColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          onTap: () => _showContactSnackBar('Email Client'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Section 2: Submit Ticket / Feedback ──
                  Text(
                    'Submit Ticket / Feedback',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _showFeedbackModal,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.bug_report_outlined, color: activeColor, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Submit Feedback or Report Bug',
                                  style: AppTextStyles.cardTitle.copyWith(
                                    color: textColor,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Send logs and issue details directly to engineers',
                                  style: AppTextStyles.cardSubtitle.copyWith(
                                    color: secondaryTextColor,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: _showFeedbackModal,
                            child: Text(
                              'Report',
                              style: AppTextStyles.button.copyWith(
                                color: isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Section 3: Frequently Asked Questions ──
                  Text(
                    'Frequently Asked Questions',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Column(
                        children: List.generate(_faqs.length, (index) {
                          final faq = _faqs[index];
                          final isLast = index == _faqs.length - 1;
                          return Column(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  iconColor: activeColor,
                                  collapsedIconColor: secondaryTextColor,
                                  title: Text(
                                    faq['question']!,
                                    style: AppTextStyles.body.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                      child: Text(
                                        faq['answer']!,
                                        style: AppTextStyles.cardSubtitle.copyWith(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast) Divider(height: 1, color: borderColor, indent: 16, endIndent: 16),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.cardTitle.copyWith(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
