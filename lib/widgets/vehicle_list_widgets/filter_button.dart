import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/get_device_group_provider.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

import 'group_filter_item.dart';

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
        return GestureDetector(
          onTap: () {
            _showFilterSheet(context, primary, onSurface);
            if (provider.isFilterOpen) {
              final groupProvider =
                  Provider.of<GetDeviceGroupProvider>(context, listen: false);
              groupProvider.fetchDeviceGroups(
                  isRefresh: true, context: context);
            } else {
              if (kDebugMode) {
                print("Filter closed → No API call");
              }
            }
          },
          child: Container(
            height: 5.h,
            width: 5.h,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset("assets/images/filter.png"),
          ),
        );
      },
    );
  }

  void _showFilterSheet(
      BuildContext context, Color primary, Color onSurface) async {
    final provider =
        Provider.of<GetDevicesListProvider>(context, listen: false);
    final groupProvider =
        Provider.of<GetDeviceGroupProvider>(context, listen: false);
    groupProvider.fetchDeviceGroups(isRefresh: true, context: context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border.all(color: primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.35),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: DraggableScrollableSheet(
              expand: false,
              builder: (_, controller) {
                return Consumer<GetDeviceGroupProvider>(
                  builder: (context, groupProvider, child) {
                    return Padding(
                      padding: EdgeInsets.only(left: 5.w,right: 5.w,top:1.h ,bottom: 3.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Filter",
                                style:AppStyles.appTitleTextStyle.copyWith(
                                  fontSize: 18.sp
                                )
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, size: 26),
                              ),
                            ],
                          ),
                          if (groupProvider.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            Expanded(
                              child: ListView(
                                padding: EdgeInsets.zero,
                                controller: controller,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 3.h,top: 1.h),
                                    child: GroupFilterItem(
                                      title: 'All',
                                      groupId: null,
                                    ),
                                  ),
                                  ...groupProvider.groups.map(
                                    (group) => Padding(
                                      padding: EdgeInsets.only(bottom: 3.h),
                                      child: GroupFilterItem(
                                        title: group.title,
                                        groupId: group.id,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: "Reset",
                                  textColor: AppColors.textBlack,
                                  onPressed: () {
                                    provider.setGroupFilter(null, 'All');
                                    Navigator.pop(context);
                                  },
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              horizontalSpace(width: 6.w),
                              Expanded(
                                child: CustomButton(
                                  height: 4.5.h,
                                  text: "Apply",
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  backgroundColor: AppColors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
