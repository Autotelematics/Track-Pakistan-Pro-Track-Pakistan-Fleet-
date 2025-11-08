import 'package:flutter/material.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double height;
  final double width;
  final FontWeight fontWeight;
  final double fontSize;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.borderRadius = 10,
    this.height = 50,
    this.width = double.infinity,
    this.fontWeight = FontWeight.bold,
    this.fontSize = 16,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // If no background color provided → use gradient based on theme
    final bool useGradient = backgroundColor == null;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: useGradient ? Colors.transparent : backgroundColor,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: useGradient
                ? (isDark
                ? LinearGradient(
              colors: [theme.cardColor, theme.cardColor],
            )
                :  LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.purple,
                AppColors.blueCyanWithOpacity,
              ],
            ))
                : null,
            color: useGradient ? null : backgroundColor,
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppStyles.regularTextStyle(context).copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800
              )
            ),
          ),
        ),
      ),
    );
  }
}
