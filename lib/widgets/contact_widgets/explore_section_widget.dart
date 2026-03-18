import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/white_labeling/contacts.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = [];

    // Terms and Conditions
    if (CompanyInfo.termAndCondition.trim().isNotEmpty) {
      cards.add(
        _ActionCard(
          title: "Terms and Conditions",
          subtitle: "Legal policies and user agreement",
          icon: Icons.gavel_outlined,
          onTap: () => _launchUrl(CompanyInfo.termAndCondition),
        ),
      );
    }

    // Privacy Policy
    if (CompanyInfo.privacyPolicy.trim().isNotEmpty) {
      cards.add(
        _ActionCard(
          title: "Privacy Policy",
          subtitle: "How we protect your data",
          icon: Icons.shield_outlined,
          onTap: () => _launchUrl(CompanyInfo.privacyPolicy),
        ),
      );
    }

    // Company News
    if (CompanyInfo.websiteNews.trim().isNotEmpty) {
      cards.add(
        _ActionCard(
          title: "Company News",
          subtitle: "Latest updates and announcements",
          icon: Icons.campaign_outlined,
          onTap: () => _launchUrl(CompanyInfo.websiteNews),
        ),
      );
    }

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> children = [
      verticalSpace(height: 2.2.h),
      Text(
        "Explore",
        style: AppStyles.appTitleTextStyle.copyWith(
          fontSize: 17.sp,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      verticalSpace(height: 1.4.h),
    ];

    for (int i = 0; i < cards.length; i++) {
      if (i > 0) {
        children.add(verticalSpace(height: 1.1.h));
      }
      children.add(cards[i]);
    }

    children.add(verticalSpace(height: 2.2.h));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: .6.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : AppColors.white,
          borderRadius: BorderRadius.circular(12.px),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 21.sp,
              color: isDark ? AppColors.white : AppColors.purple,
            ),
            horizontalSpace(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      color: isDark ? AppColors.white : AppColors.textBlack,
                      fontSize: 14.2.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  verticalSpace(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppStyles.lightTextStyle(context).copyWith(
                      color: AppColors.grey.withValues(alpha: 0.85),
                      fontSize: 12.1.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 21.sp,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
