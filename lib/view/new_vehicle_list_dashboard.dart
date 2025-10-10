import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_verticle_space.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/filter_button.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/group_filter_item.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/search_bar.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/status_box.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/vehicle_card.dart';
class NewVehicleListDashBoard extends StatelessWidget {
  const NewVehicleListDashBoard({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Consumer<VehicleListProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${provider.error}'),
                      ElevatedButton(
                        onPressed: () => provider.fetchData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (provider.vehicleData != null) {
                final data = provider.vehicleData!;
                return Column(
                  children: [
                    verticalSpace(height: 6.h),
                    // Status Boxes
                    SizedBox(
                      height: 7.7.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding:
                        EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                        itemCount: data.statuses.length,
                        itemBuilder: (context, index) => StatusBox(
                          status: data.statuses[index],
                          onSurface: onSurface,
                          cardColor: cardColor,
                        ),
                      ),
                    ),
                    verticalSpace(height: 1.h),
                    // Search + Filter Row
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: SearchFiled(
                              primary: primary,
                              onSurface: onSurface,
                              outline: outline,
                            ),
                          ),
                          horizontalSpace(width: 3.w),
                          FilterButton(
                            onSurface: onSurface,
                            primary: primary,
                          ),
                        ],
                      ),
                    ),
                    // Vehicle List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        itemCount: provider.filteredVehicles.length,
                        itemBuilder: (_, i) => VehicleCard(
                          vehicle: provider.filteredVehicles[i],
                          theme: theme,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: Text('No data available'));
              }
            },
          ),
          // Overlay Filter Menu
          Consumer<VehicleListProvider>(
            builder: (context, provider, child) {
              if (!provider.isFilterOpen) return const SizedBox.shrink();
              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => provider.toggleFilter(),
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  ),
                  Positioned(
                    top: 19.h,
                    right: 5.w,
                    left: 25.w,
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: ["Group A", "Group B", "Group C", "Group D"]
                            .map(
                              (title) => GroupFilterItem(
                            title: title,
                            primary: primary,
                            onSurface: onSurface,
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}