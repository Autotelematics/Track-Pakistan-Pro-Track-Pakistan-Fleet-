import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';

class GroupFilterItem extends StatelessWidget {
  final String title;
  final Color primary;
  final Color onSurface;

  const GroupFilterItem({
    super.key,
    required this.title,
    required this.primary,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleListProvider>(context);
    final isSelected = provider.selectedGroups.contains(title);

    return GestureDetector(
      onTap: () => provider.toggleGroupSelection(title),
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppStyles.groupItem(context),
            ),
            Icon(
              isSelected
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank,
              color: isSelected ? primary : primary.withOpacity(0.3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}