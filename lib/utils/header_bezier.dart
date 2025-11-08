import 'package:flutter/material.dart';

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Start at top-left
    path.lineTo(0, size.height * 0.85);

    // Left-side Bezier curve
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 1.00,
      size.width * 0.5, size.height * 0.90,
    );

    // Right-side Bezier curve
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.80,
      size.width, size.height * 0.92,
    );

    // Right edge to top
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
