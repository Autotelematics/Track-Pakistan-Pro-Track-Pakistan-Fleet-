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

    return GestureDetector(
      onTap: () {
        provider.setGroupFilter(currentId, title);
        final grp = Provider.of<GetDeviceGroupProvider>(context, listen: false);
        provider.updateGroupModel(grp.model);
      },
      child: Row(
        children: [
          Container(
            height: 2.h,
            width: 2.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? ConstantColor.primaryColor
                    : Colors.grey.shade500,
                width: isSelected ? 6 : 1.6,
              ),
            ),
          ),

          horizontalSpace(width: 4.w),
          Expanded(
            child: Text(
              title,
              style: AppStyles.groupItem(context).copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? ConstantColor.primaryColor
                    : AppColors.textBlack.withOpacity(0.75),
                fontSize: 15.5.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
