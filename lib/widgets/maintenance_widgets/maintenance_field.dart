import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class MaintenanceField extends StatelessWidget {
  final String title;
  final String hint;
  final VoidCallback? onTap;

  /// OPTIONAL CONTROLLER
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLines;

  final double? height;
  final double? width;
  final double? titleFontSize;
  final double? fieldFontSize;
  final double? hintFontSize;
  final double? titleBottomSpacing;
  final double? inputVerticalPadding;

  const MaintenanceField({
    super.key,
    required this.title,
    required this.hint,
    this.onTap,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.height,
    this.width,
    this.titleFontSize,
    this.fieldFontSize,
    this.hintFontSize,
    this.titleBottomSpacing,
    this.inputVerticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final borderColor = theme.dividerColor.withOpacity(.4);
    final primaryOpacity = theme.colorScheme.primary.withOpacity(.8);
    final effectiveTitleFontSize = titleFontSize ?? 16.sp;
    final effectiveFieldFontSize = fieldFontSize ?? 16.sp;
    final effectiveHintFontSize = hintFontSize ?? 16.sp;
    final effectiveTitleBottomSpacing = titleBottomSpacing ?? 1.h;
    final effectiveInputVerticalPadding = inputVerticalPadding ?? 1.8.h;

    OutlineInputBorder getBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1),
    );

    Widget fieldWidget;

    // Text input mode
    if (controller != null) {
      fieldWidget = TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: effectiveFieldFontSize, color: onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: onSurface.withOpacity(.5),
            fontSize: effectiveHintFontSize,
          ),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: effectiveInputVerticalPadding,
          ),
          enabledBorder: getBorder(borderColor),
          focusedBorder: getBorder(primaryOpacity),
          border: getBorder(borderColor),
        ),
      );
    }
    // Picker / read-only mode
    else if (onTap != null) {
      fieldWidget = GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: effectiveInputVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              hint,
              style: TextStyle(
                fontSize: effectiveHintFontSize,
                color: onSurface.withOpacity(.6),
              ),
            ),
          ),
        ),
      );
    } else {
      fieldWidget = const SizedBox.shrink(); // Fallback if misconfigured
    }

    // Effective height: custom if provided, otherwise default for picker
    final double? effectiveHeight =
        height ?? (controller == null ? 6.h : null);

    // Wrap in SizedBox for dynamic width/height control
    // Default width = double.infinity → takes full available width (perfect for dialogs/rows)
    final Widget sizedField = SizedBox(
      width: width ?? double.infinity,
      height: effectiveHeight,
      child: fieldWidget,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: effectiveTitleFontSize,
            color: onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        verticalSpace(height: effectiveTitleBottomSpacing),
        sizedField,
      ],
    );
  }
}
