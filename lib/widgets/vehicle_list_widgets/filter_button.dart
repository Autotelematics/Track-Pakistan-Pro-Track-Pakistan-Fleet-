import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_group_provider.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';

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
    return Consumer<GetDevicesListProvider>(
      builder: (context, provider, child) {
        final hasActiveFilter = provider.selectedGroupId != null;
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            _showFilterMenu(context, primary, onSurface);
          },
          child: Container(
            height: 5.h,
            width: 13.w,
            decoration: BoxDecoration(
              color: hasActiveFilter
                  ? primary.withOpacity(0.14)
                  : primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasActiveFilter
                    ? primary.withOpacity(0.6)
                    : onSurface.withOpacity(0.15),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.tune_rounded,
                    size: 18.5.sp,
                    color: hasActiveFilter ? primary : onSurface,
                  ),
                ),
                if (hasActiveFilter)
                  Positioned(
                    right: 2.4.w,
                    top: 1.1.h,
                    child: Container(
                      width: .9.h,
                      height: .9.h,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFilterMenu(
      BuildContext context, Color primary, Color onSurface) async {
    final provider =
        Provider.of<GetDevicesListProvider>(context, listen: false);
    final groupProvider =
        Provider.of<GetDeviceGroupProvider>(context, listen: false);
    await groupProvider.fetchDeviceGroups(isRefresh: true, context: context);

    if (!context.mounted) return;

    final button = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;

    final buttonTopLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final buttonRect = Rect.fromLTWH(
      buttonTopLeft.dx,
      buttonTopLeft.dy,
      button.size.width,
      button.size.height,
    );

    final selected = await showMenu<String>(
      context: context,
      elevation: 10,
      color: Theme.of(context).cardColor,
      constraints: BoxConstraints(
        minWidth: 44.w,
        maxWidth: 58.w,
        maxHeight: 38.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: onSurface.withOpacity(.14)),
      ),
      position: RelativeRect.fromLTRB(
        buttonRect.left,
        buttonRect.bottom + .55.h,
        overlay.size.width - buttonRect.right,
        overlay.size.height - (buttonRect.bottom + .55.h),
      ),
      items: [
        PopupMenuItem<String>(
          value: '__all__',
            child: _menuRow(
            context,
            label: context.l10n.allGroups,
            isSelected: provider.selectedGroupId == null,
            onSurface: onSurface,
            primary: primary,
          ),
        ),
        ...groupProvider.groups.map(
          (group) => PopupMenuItem<String>(
            value: group.id.toString(),
            child: _menuRow(
              context,
              label: group.title,
              isSelected: provider.selectedGroupId == group.id.toString(),
              onSurface: onSurface,
              primary: primary,
            ),
          ),
        ),
      ],
    );

    if (!context.mounted || selected == null) return;

    if (selected == '__all__') {
      provider.setGroupFilter(null, context.l10n.vehicleStatusAll);
    } else {
      var selectedTitle = 'Group';
      for (final group in groupProvider.groups) {
        if (group.id.toString() == selected) {
          selectedTitle = group.title;
          break;
        }
      }
      provider.setGroupFilter(selected, selectedTitle);
    }
    provider.updateGroupModel(groupProvider.model);
  }

  Widget _menuRow(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Color onSurface,
    required Color primary,
  }) {
    return Row(
      children: [
        Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 17.sp,
          color: isSelected ? primary : onSurface.withOpacity(.42),
        ),
        SizedBox(width: 2.2.w),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              color: isSelected ? primary : onSurface.withOpacity(.82),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
