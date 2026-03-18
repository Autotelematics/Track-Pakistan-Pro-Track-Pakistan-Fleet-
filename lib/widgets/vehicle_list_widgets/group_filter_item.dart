import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_group_provider.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

class GroupFilterItem extends StatelessWidget {
  final String title;
  final int? groupId;

  const GroupFilterItem({
    super.key,
    required this.title,
    this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetDevicesListProvider>(context);
    final String? selectedId = provider.selectedGroupId;
    final String? currentId = groupId?.toString();

    final bool isSelected =
        (title == 'All' && selectedId == null) ||
        (currentId != null && selectedId == currentId);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        provider.setGroupFilter(currentId, title);
        final grp = Provider.of<GetDeviceGroupProvider>(context, listen: false);
        provider.updateGroupModel(grp.model);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 3.1.w, vertical: 1.15.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? ConstantColor.primaryColor.withOpacity(.09)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? ConstantColor.primaryColor.withOpacity(.45)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 2.05.h,
              width: 2.05.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? ConstantColor.primaryColor
                      : Colors.grey.shade500,
                  width: isSelected ? 5 : 1.4,
                ),
              ),
            ),
            horizontalSpace(width: 3.2.w),
            Expanded(
              child: Text(
                title,
                style: AppStyles.groupItem(context).copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? ConstantColor.primaryColor
                      : AppColors.textBlack.withOpacity(0.78),
                  fontSize: 14.8.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
