import 'package:flutter/material.dart';

/// Shared UI tokens to keep spacing, radius, and softness consistent
/// with dashboard styling across the app.
class AppUiTokens {
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  static const double cardShadowBlur = 14;
  static const double cardShadowY = 5;

  static double adaptiveHeight(
    BuildContext context, {
    required double ratio,
    required double min,
    required double max,
  }) {
    final h = MediaQuery.of(context).size.height;
    return (h * ratio).clamp(min, max).toDouble();
  }

  static double adaptiveWidth(
    BuildContext context, {
    required double ratio,
    required double min,
    required double max,
  }) {
    final w = MediaQuery.of(context).size.width;
    return (w * ratio).clamp(min, max).toDouble();
  }

  static BoxDecoration softCardDecoration(
    BuildContext context, {
    Color? color,
    double radius = radiusLg,
    double opacity = 0.14,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowOpacity = isDark ? opacity + 0.1 : opacity;
    return BoxDecoration(
      color: color ?? theme.cardColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: shadowOpacity),
          blurRadius: cardShadowBlur,
          offset: const Offset(0, cardShadowY),
        ),
      ],
    );
  }
}
