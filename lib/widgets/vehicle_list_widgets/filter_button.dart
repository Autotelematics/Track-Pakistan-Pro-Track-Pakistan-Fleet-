import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
class FilterButton extends StatelessWidget {
  final Color onSurface;
  final Color primary;

  const FilterButton({
    super.key,
    required this.onSurface,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleListProvider>(
      builder: (context, provider, child) => GestureDetector(
        onTap: () => provider.toggleFilter(),
        child: Container(
          height: 5.h,
          width: 5.h,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: Tween<double>(begin: 0, end: 1).animate(anim),
              child: child,
            ),
            child: provider.isFilterOpen
                ? Icon(
              Icons.close,
              key: const ValueKey('close'),
              color: onSurface,
            )
                : Image.asset(
              "assets/images/filter.png",
              key: const ValueKey('filter'),
            ),
          ),
        ),
      ),
    );
  }
}