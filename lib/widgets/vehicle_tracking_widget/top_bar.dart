import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'common_small_widgets.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;final barBg = isDark
        ? theme.cardColor.withOpacity(0.85)
        : AppColors.white.withOpacity(0.92);

    return Positioned(
      top: 7.h,
      left: 5.w,
      right: 5.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BackButtonCircle(),
          MovingChip(text: 'Moving'),
          RightSideButtons(),
        ],
      ),
    );
  }
}