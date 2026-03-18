import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/get_device_group_provider.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_detail_screen.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/filter_button.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/group_filter_item.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/search_bar.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/status_box.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/vehicle_card.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/vehicle_list_scale.dart';

class NewVehicleListDashBoard extends StatefulWidget {
  const NewVehicleListDashBoard({super.key});

  @override
  State<NewVehicleListDashBoard> createState() =>
      _NewVehicleListDashBoardState();
}

class _NewVehicleListDashBoardState extends State<NewVehicleListDashBoard>
    with WidgetsBindingObserver {
  late final GetDevicesListProvider _provider;
  bool _hasSyncedGroups = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _provider = Provider.of<GetDevicesListProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.init(context);
      final groupProvider =
          Provider.of<GetDeviceGroupProvider>(context, listen: false);
      groupProvider.fetchDeviceGroups(isRefresh: true, context: context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _provider.fetchData(isPeriodic: true);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      body: Consumer2<GetDevicesListProvider, GetDeviceGroupProvider>(
        builder: (context, provider, groupProvider, child) {
          if (groupProvider.model != null &&
              !provider.hasGroups &&
              !_hasSyncedGroups) {
            _hasSyncedGroups = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.updateGroupModel(groupProvider.model);
            });
          }
          return Stack(
            children: [
              _buildMainContent(
                  context, theme, onSurface, cardColor, primary, outline),
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
          return _buildShimmer(theme, onSurface, cardColor);
        }
        if (provider.error != null) {
          return _buildErrorState(provider, context);
        }
        if (provider.vehicleData == null ||
            provider.vehicleData!.items == null ||
            provider.vehicleData!.items!.isEmpty) {
          return _buildEmptyState(context);
        }
        return Column(
          children: [
            verticalSpace(height: 5.2.h),
            _buildStatusBoxes(provider, onSurface, cardColor),
            verticalSpace(height: .2.h),
            _buildSearchAndFilterRow(primary, onSurface, outline),
            verticalSpace(height: 1.h),
            _buildVehicleList(provider, theme),
          ],
        );
      },
    );
  }

  Widget _buildShimmer(ThemeData theme, Color onSurface, Color cardColor) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          verticalSpace(height: 5.2.h),
          SizedBox(
            height: 7.1.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: .75.h),
              itemCount: 7,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Container(
                  width: 20.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          verticalSpace(height: .8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.6.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                horizontalSpace(width: 2.w),
                Container(
                  height: 5.h,
                  width: 5.h,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          verticalSpace(height: .8.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 0),
              itemCount: 5,
              itemBuilder: (_, i) => Container(
                margin: EdgeInsets.symmetric(vertical: 1.h),
                height: 20.h,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final provider =
        Provider.of<GetDevicesListProvider>(context, listen: false);
    final textScale = vehicleListTextScale(context);
    final iconScale = vehicleListIconScale(context);
    final message =
        provider.filterStatus == 'all' && provider.selectedGroupId == null
            ? 'No vehicles available.'
            : provider.selectedGroupId == null
                ? 'No vehicles are currently ${provider.filterStatus}.'
                : 'No vehicles available in the selected group.';
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: (48 * iconScale).sp,
              color: Colors.grey[600],
            ),
            verticalSpace(height: 2.h),
            Text(
              message,
              style: TextStyle(
                  fontSize: (14.4 * textScale).sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            verticalSpace(height: 2.h),
            ElevatedButton(
              onPressed: () {
                provider.setGroupFilter(null, 'All');
                provider.setFilter('all');
                provider.updateSearchQuery('');
              },
              child: const Text('View All Vehicles'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBoxes(
      GetDevicesListProvider provider, Color onSurface, Color cardColor) {
    final statuses = [
      _StatusData(
          title: "All",
          count: provider.getCountForStatus('all'),
          color: AppColors.brownMain),
      _StatusData(
          title: "Running",
          count: provider.getCountForStatus('running'),
          color: AppColors.green),
      _StatusData(
          title: "Stopped",
          count: provider.getCountForStatus('stopped'),
          color: AppColors.red),
      _StatusData(
          title: "Idle",
          count: provider.getCountForStatus('idle'),
          color: AppColors.yellow),
      _StatusData(
          title: "Offline",
          count: provider.getCountForStatus('offline'),
          color: AppColors.blueCyan),
      _StatusData(
          title: "No Data",
          count: provider.getCountForStatus('nodata'),
          color: AppColors.grey),
      _StatusData(
          title: "Expired",
          count: provider.getCountForStatus('expired'),
          color: AppColors.brown),
    ];

    return SizedBox(
      height: 6.9.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: .8.h),
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

  Widget _buildSearchAndFilterRow(
      Color primary, Color onSurface, Color outline) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.6.w),
      child: Row(
        children: [
          Expanded(
            child: SearchFiled(
                primary: primary, onSurface: onSurface, outline: outline),
          ),
          horizontalSpace(width: 2.w),
          FilterButton(onSurface: onSurface, primary: primary),
        ],
      ),
    );
  }

  Widget _buildVehicleList(GetDevicesListProvider provider, ThemeData theme) {
    if (provider.filteredVehicles.isEmpty) {
      return _buildEmptyState(context);
    }
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 0),
        itemCount: provider.filteredVehicles.length,
        itemBuilder: (_, i) {
          final item = provider.filteredVehicles[i];
          return GestureDetector(
              onTap: () {
                final lat = _parseCoordinate(item.lat);
                final lng = _parseCoordinate(item.lng);
                final online = (item.online ?? '').toLowerCase().trim();
                final time = (item.time ?? '').toLowerCase().trim();
                final isExpired = online == 'expired' ||
                    (online == 'offline' && time == 'expired');
                final isOffline = online == 'offline' &&
                    time != 'expired' &&
                    time != 'not connected';
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            SingleVehicleAnalytics(
                              deviceId: provider.filteredVehicles[i].id ?? 0,
                              deviceName:
                                  provider.filteredVehicles[i].name ?? "",
                              sensors: item.sensors ?? [],
                              isExpired: isExpired,
                              isOffline: isOffline,
                              lastStatusTimestamp: item.timestamp,
                              lastAckTimestamp: item.acktimestamp,
                              lastStatusTimeText: item.time,
                              initialVehicleType: item.vehicleType,
                              initialLiveLat: lat,
                              initialLiveLng: lng,
                              initialLiveStatus: item.online,
                            )));
              },
              child: VehicleCard(vehicle: item, theme: theme));
        },
      ),
    );
  }

  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Widget _buildGroupFilterOverlay(
    GetDevicesListProvider provider,
    Color cardColor,
    Color primary,
    Color onSurface,
  ) {
    return Consumer<GetDeviceGroupProvider>(
      builder: (context, groupProvider, child) {
        if (!provider.isFilterOpen) return const SizedBox();
        final groups = groupProvider.groups;
        return AnimatedOpacity(
          opacity: provider.isFilterOpen ? 1 : 0,
          duration: const Duration(milliseconds: 240),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            color: Colors.black.withOpacity(0.50),
            child: Center(
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.85, end: 1),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                builder: (context, scale, _) {
                  return Transform.scale(
                    scale: scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (groupProvider.isLoading)
                          Column(
                            children: List.generate(
                              6,
                              (_) => groupItemShimmer(
                                primary,
                                primary.withOpacity(0.4),
                              ),
                            ),
                          )
                        else if (groupProvider.error != null)
                          Center(
                            child: Text(
                              "Error: ${groupProvider.error}",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14.4.sp,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              GroupFilterItem(
                                title: 'All',
                                groupId: null,
                              ),
                              ...groups.map(
                                (group) => GroupFilterItem(
                                  title: group.title,
                                  groupId: group.id,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget groupItemShimmer(Color baseColor, Color highlightColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.3.h, horizontal: 4.w),
      margin: EdgeInsets.symmetric(vertical: 0.45.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: baseColor.withOpacity(0.10),
        border: Border.all(
          color: baseColor.withOpacity(0.40),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 12.4.sp,
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(
      GetDevicesListProvider provider, BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${provider.error}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14.4.sp,
                  color: Theme.of(context).colorScheme.error),
            ),
            verticalSpace(height: 2.h),
            ElevatedButton(
                onPressed: provider.fetchData, child: const Text('Retry')),
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
