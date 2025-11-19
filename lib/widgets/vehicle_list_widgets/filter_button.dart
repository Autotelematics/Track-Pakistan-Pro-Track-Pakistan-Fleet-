import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/providers/get_device_group_provider.dart';
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
    print("Filter Button open");
    return Consumer<GetDevicesListProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () {
            provider.toggleFilter();
            print("Filter toggled: ${provider.isFilterOpen}");

            if (provider.isFilterOpen) {
              print("Filter opened → API call starting...");
              final groupProvider = Provider.of<GetDeviceGroupProvider>(context, listen: false);
              groupProvider.fetchDeviceGroups(isRefresh: true,context: context);
            } else {
              print("Filter closed → No API call");
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
}