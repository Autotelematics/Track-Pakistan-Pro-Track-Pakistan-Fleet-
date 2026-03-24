import 'package:flutter/material.dart';
import 'package:trackerapp/utils/diagonal_bezier.dart';

class ThemeOptionCard extends StatelessWidget {
  final String title;
  final Color bgColor;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accent = const Color(0xFF1DBF73);

  const ThemeOptionCard({
    super.key,
    required this.title,
    required this.bgColor,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 90,
            height: 170,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? accent : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  _previewBars(isDark),
                  if (title == 'System')
                    ClipPath(
                      clipper: DiagonalClipper(),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? accent : Colors.grey,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _previewBars(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: 15,
          left: 20,
          right: 20,
          child: Container(
            height: 18,
            decoration: BoxDecoration(
              color: isDark ? Colors.green[800] : accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        Positioned(
          top: 45,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              return Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
        Positioned(
          bottom: 25,
          left: 20,
          right: 20,
          child: Container(
            height: 18,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
}
