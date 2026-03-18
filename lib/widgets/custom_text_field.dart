// lib/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function()? onSuffixTap; // ← NEW: Dedicated callback for suffix icon
  final TextInputType keyboardType;
  final bool obscureText;
  final Color? fillColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final double? fontSize;
  final double? contentPaddingV;
  final double? contentPaddingH;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool showShadow;
  final FontWeight? fontWeight;
  final TextAlign textAlign;
  final Function(String)? onSubmitted; // ← For search on enter

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.fillColor,
    this.textColor,
    this.labelColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.fontSize,
    this.contentPaddingV,
    this.contentPaddingH,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.validator,
    this.onTap,
    this.showShadow = false,
    this.fontWeight,
    this.textAlign = TextAlign.start,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final defaultFillColor = fillColor ?? const Color(0xFFF9FAFB);
    final defaultTextColor = textColor ?? Colors.black87;
    final defaultLabelColor = labelColor ?? Colors.grey.shade600;
    final defaultBorderColor = borderColor ?? Colors.grey.shade300;
    final defaultFocusedBorderColor = focusedBorderColor ?? Colors.teal;
    final defaultBorderRadius = borderRadius ?? 12.px;
    final defaultFontSize = fontSize ?? 15.sp;

    return Container(
      decoration: showShadow
          ? BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      )
          : null,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        readOnly: readOnly,
        maxLines: maxLines,
        validator: validator,
        onTap: onTap,
        textAlign: textAlign,
        onFieldSubmitted: onSubmitted,
        style: TextStyle(
          color: defaultTextColor,
          fontSize: defaultFontSize,
          fontWeight: fontWeight ?? FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 15.sp,
            color: defaultLabelColor,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: defaultLabelColor, size: 20.sp)
              : null,

          // Suffix Icon with proper tap handling & ripple effect
          suffixIcon: suffixIcon != null
              ? Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: onSuffixTap ?? onTap, // Priority to dedicated callback
              child: Icon(
                suffixIcon,
                color: defaultLabelColor,
                size: 22.sp,
              ),
            ),
          )
              : null,

          filled: true,
          fillColor: defaultFillColor,
          contentPadding: EdgeInsets.symmetric(
            vertical: contentPaddingV ?? 1.8.h,
            horizontal: contentPaddingH ?? 4.w,
          ),

          // Borders
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            borderSide: BorderSide(color: defaultBorderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            borderSide: BorderSide(color: defaultFocusedBorderColor, width: 1.8),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
          ),
        ),
      ),
    );
  }
}
