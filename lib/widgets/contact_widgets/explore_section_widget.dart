import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/contact_us_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContactProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(height: 3.h),
        Text(
          "Explore",
          style: AppStyles.appTitleTextStyle.copyWith(fontSize: 16.sp),
        ),
        verticalSpace(height: 2.h),
        _ActionCard(
          title: "Terms and Conditions",
          subtitle: "Legal policies and user agreement",
          icon: Icons.gavel_outlined,
          onTap: () => provider.selectIndex(0),
        ),
        verticalSpace(height: 1.8.h),
        _ActionCard(
          title: "Privacy Policy",
          subtitle: "How we protect your data",
          icon: Icons.shield_outlined,
          onTap: () => provider.selectIndex(1),
        ),
        verticalSpace(height: 1.8.h),
        _ActionCard(
          title: "Company News",
          subtitle: "Latest updates and announcements",
          icon: Icons.campaign_outlined,
          onTap: () => provider.selectIndex(2),
        ),
        verticalSpace(height: 3.h),
      ],
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
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : AppColors.white,
          borderRadius: BorderRadius.circular(10.px),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 23.sp,
                color: isDark ? AppColors.white : AppColors.purple),
            horizontalSpace(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppStyles.regularTextStyle(context).copyWith(
                          color:
                              isDark ? AppColors.white : AppColors.textBlack)),
                  verticalSpace(height: 0.5.h),
                  Text(subtitle,
                      style: AppStyles.lightTextStyle(context)
                          .copyWith(color: AppColors.grey)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 23.sp,
                color: isDark ? Colors.grey[500] : Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
