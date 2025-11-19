import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/providers/get_device_group_provider.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/filter_button.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/group_filter_item.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/search_bar.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/status_box.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/vehicle_card.dart';

class NewVehicleListDashBoard extends StatefulWidget {
  const NewVehicleListDashBoard({super.key});

  @override
  State<NewVehicleListDashBoard> createState() => _NewVehicleListDashBoardState();
}

class _NewVehicleListDashBoardState extends State<NewVehicleListDashBoard> {
  late final GetDevicesListProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<GetDevicesListProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<GetDevicesListProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              _buildMainContent(context, theme, onSurface, cardColor, primary, outline),
              // Group Filter Overlay (now real)
              _buildGroupFilterOverlay(provider, cardColor, primary, onSurface),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context,
      ThemeData theme,
      Color onSurface,
      Color cardColor,
      Color primary,
      Color outline,
      ) {
    return Consumer<GetDevicesListProvider>(
      builder: (context, provider, child) {
        if (provider.showLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _buildErrorState(provider, context);
        }

        if (provider.vehicleData == null) {
          return const Center(child: Text('No data available'));
        }

        return Column(
          children: [
            verticalSpace(height: 6.h),
            _buildStatusBoxes(provider, onSurface, cardColor),
            verticalSpace(height: 1.h),
            _buildSearchAndFilterRow(primary, onSurface, outline),
            _buildVehicleList(provider, theme),
          ],
        );
      },
    );
  }

  Widget _buildStatusBoxes(GetDevicesListProvider provider, Color onSurface, Color cardColor) {
    final statuses = [
      _StatusData(title: "All", count: provider.getCountForStatus('all'), color: Colors.blue),
      _StatusData(title: "Running", count: provider.getCountForStatus('running'), color: Colors.green),
      _StatusData(title: "Stopped", count: provider.getCountForStatus('stopped'), color: Colors.red),
      _StatusData(title: "Idle", count: provider.getCountForStatus('idle'), color: Colors.orange),
      _StatusData(title: "Offline", count: provider.getCountForStatus('offline'), color: Colors.cyan),
      _StatusData(title: "No Data", count: provider.getCountForStatus('nodata'), color: Colors.grey),
      _StatusData(title: "Expired", count: provider.getCountForStatus('expired'), color: Colors.purple),
    ];

    return SizedBox(
      height: 7.7.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
        itemCount: statuses.length,
        itemBuilder: (context, index) => StatusBox(
          title: statuses[index].title,
          count: statuses[index].count,
          color: statuses[index].color,
          onSurface: onSurface,
          cardColor: cardColor,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow(Color primary, Color onSurface, Color outline) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        children: [
          Expanded(
            child: SearchFiled(primary: primary, onSurface: onSurface, outline: outline),
          ),
          horizontalSpace(width: 3.w),
          FilterButton(onSurface: onSurface, primary: primary),
        ],
      ),
    );
  }

  Widget _buildVehicleList(GetDevicesListProvider provider, ThemeData theme) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0),
        itemCount: provider.filteredVehicles.length,
        itemBuilder: (_, i) {
          final item = provider.filteredVehicles[i];
          return VehicleCard(vehicle: item, theme: theme);
        },
      ),
    );
  }

  Widget _buildGroupFilterOverlay(
      GetDevicesListProvider provider,
      Color cardColor,
      Color primary,
      Color onSurface,
      ) {
    return Consumer<GetDeviceGroupProvider>(
      builder: (context, groupProvider, child) {
        // If filter is closed, show nothing
        if (!provider.isFilterOpen) return const SizedBox();

        final groups = groupProvider.groups;

        return Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Group",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  verticalSpace(height: 2.h),

                  // Loading state
                  if (groupProvider.isLoading)
                    const CircularProgressIndicator()

                  // Error state
                  else if (groupProvider.error != null)
                    Text(
                      "Error: ${groupProvider.error}",
                      style: TextStyle(color: Colors.red, fontSize: 16.sp),
                    )

                  // List of group items
                  else
                    ...[
                      // "All" option at the top
                      GroupFilterItem(
                        title: 'All',
                        primary: primary,
                        onSurface: onSurface,
                      ),
                      // Dynamically map groups
                      ...groups.map(
                            (group) => GroupFilterItem(
                          title: group.name ?? 'Unnamed Group',
                          primary: primary,
                          onSurface: onSurface,
                        ),
                      ),
                    ],

                  verticalSpace(height: 2.h),

                  // Close button
                  ElevatedButton(
                    onPressed: provider.toggleFilter,
                    child: const Text("Close"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(GetDevicesListProvider provider, BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${provider.error}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.error),
            ),
            verticalSpace(height: 2.h),
            ElevatedButton(onPressed: provider.fetchData, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _StatusData {
  final String title;
  final int count;
  final Color color;
  _StatusData({required this.title, required this.count, required this.color});
}