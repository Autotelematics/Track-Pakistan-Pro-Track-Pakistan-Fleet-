import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/utils/top_curve_bezier.dart';
import 'package:trackerapp/widgets/settings_widgets/settings_header.dart';
import 'package:trackerapp/widgets/settings_widgets/settings_menu_tile.dart';
class ModernSettingsScreen extends StatelessWidget {
  const ModernSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(colors: [theme.cardColor, theme.cardColor])
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purple,
              AppColors.blueCyanWithOpacity,
            ],
          ),
        ),
        child: Column(
          children: [
            const SettingsHeader(),
            Expanded(
              child: ClipPath(
                clipper: TopCurveClipper(),
                child: Container(
                  color: theme.scaffoldBackgroundColor,
                  padding: EdgeInsets.only(left: 6.w,right: 6.w, top: 5.h),
                  child: const SettingsMenuList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
