import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/providers/get_devices_status_provider.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_detail_screen.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class MapForAllVehiclesScreen extends StatefulWidget {
  const MapForAllVehiclesScreen({super.key});

  @override
  State<MapForAllVehiclesScreen> createState() =>
      _MapForAllVehiclesScreenState();
}

class _MapForAllVehiclesScreenState extends State<MapForAllVehiclesScreen>
    with WidgetsBindingObserver {
  late final VehicleMapProvider _provider;
  Timer? _liveTicker;
  bool _showStatusRail = true;

  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _provider = VehicleMapProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.startPeriodicRefresh(context);
    });
    _liveTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveTicker?.cancel();
    _provider.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _provider.fetchVehicleList(context: context);
      });
    }
  }

  int _secondsSinceLastRefresh(VehicleMapProvider provider) {
    final t = provider.lastRefreshAt;
    if (t == null) return 0;
    final secs = DateTime.now().difference(t).inSeconds;
    return secs < 0 ? 0 : secs;
  }

  Future<void> _openVehicleSearch(
      BuildContext context, VehicleMapProvider provider) async {
    final controller = TextEditingController();
    String query = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final results = provider.searchVehiclesByName(query);
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.5.h),
                child: SizedBox(
                  height: 58.h,
                  child: Column(
                    children: [
                      Container(
                        width: 11.w,
                        height: .5.h,
                        margin: EdgeInsets.only(bottom: 1.1.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: .35),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      TextField(
                        controller: controller,
                        onChanged: (v) {
                          setSheetState(() => query = v);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search vehicle by name',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: query.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    controller.clear();
                                    setSheetState(() => query = '');
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                      ),
                      SizedBox(height: 1.0.h),
                      Expanded(
                        child: results.isEmpty
                            ? Center(
                                child: Text(
                                  'No vehicle found',
                                  style: AppStyles.regularTextStyle(context)
                                      .copyWith(fontSize: 13.sp),
                                ),
                              )
                            : ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (_, i) {
                                  final item = results[i];
                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 1.w,
                                      vertical: .2.h,
                                    ),
                                    leading: Icon(
                                      Icons.directions_car_rounded,
                                      size: 18.sp,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    title: Text(
                                      item.name ?? 'Unknown',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          AppStyles.semiboldTextStyle(context)
                                              .copyWith(fontSize: 13.sp),
                                    ),
                                    subtitle: Text(
                                      '${item.speed ?? 0} km/h • ${item.online ?? 'Unknown'}',
                                      style: AppStyles.regularTextStyle(context)
                                          .copyWith(fontSize: 11.sp),
                                    ),
                                    onTap: () async {
                                      Navigator.of(ctx).pop();
                                      await provider.focusOnVehicle(item);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _mapStyleToggle(VehicleMapProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final selected =
        provider.currentMapType == MapType.hybrid ? 'satellite' : 'default';
    return Container(
      padding: EdgeInsets.all(.35.h),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: isDark ? .96 : .93),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: onSurface.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .28 : .14),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _styleChip(
            label: 'Default',
            isSelected: selected == 'default',
            onTap: () => provider.setMapType(MapType.normal),
          ),
          SizedBox(width: .8.w),
          _styleChip(
            label: 'Satellite',
            isSelected: selected == 'satellite',
            onTap: () => provider.setMapType(MapType.hybrid),
          ),
        ],
      ),
    );
  }

  Widget _styleChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: .45.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: .22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 12.8.sp,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .75),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBoxes(
    VehicleMapProvider provider,
    Color onSurface,
    Color cardColor,
    double topInset,
  ) {
    final List<_StatusItem> statuses = [
      _StatusItem(title: "All", key: "all", color: Colors.blue),
      _StatusItem(title: "Running", key: "running", color: Colors.green),
      _StatusItem(title: "Stopped", key: "stopped", color: Colors.red),
      _StatusItem(title: "Idle", key: "idle", color: Colors.orange),
      _StatusItem(title: "Offline", key: "offline", color: Colors.cyan),
      _StatusItem(title: "No Data", key: "nodata", color: Colors.grey),
      _StatusItem(title: "Expired", key: "expired", color: Colors.purple),
    ];

    return Container(
      width: 20.5.w,
      margin: EdgeInsets.only(top: topInset + 4.9.h, left: 1.4.w),
      padding: EdgeInsets.symmetric(horizontal: .9.w, vertical: .6.h),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: onSurface.withValues(alpha: 0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .16),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 50.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (final statusItem in statuses)
                Padding(
                  padding: EdgeInsets.only(bottom: .45.h),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => provider.setSelectedStatus(statusItem.key),
                    child: StatusBox(
                      title: statusItem.title,
                      count: provider.getStatusCount(statusItem.key),
                      color: statusItem.color,
                      onSurface: onSurface,
                      cardColor: cardColor,
                      selectedKey: provider.selectedStatus,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topInset = MediaQuery.of(context).padding.top;
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final controlBg = cardColor.withValues(alpha: isDark ? .96 : .93);
    final controlIcon = onSurface.withValues(alpha: isDark ? .9 : .78);

    return Scaffold(
      body: ChangeNotifierProvider<VehicleMapProvider>.value(
        value: _provider,
        child: Consumer<VehicleMapProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(30.229696, 69.982138),
                    zoom: 5,
                  ),
                  mapType: provider.currentMapType,
                  trafficEnabled: provider.enableTraffic,
                  markers: provider.deviceMarkers,
                  zoomControlsEnabled: false, // Hidden default buttons
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: true,
                  onMapCreated: provider.setMapController,
                  onCameraIdle: provider.onCameraIdle,
                  onTap: (_) => provider.clearSelectedVehicle(),
                ),

                if (provider.isLoading)
                  Container(
                    color: (isDark ? Colors.black : Colors.white)
                        .withValues(alpha: 0.82),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(height: 2.h),
                          Text(
                            'Loading devices...',
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 14.sp,
                              color: onSurface.withValues(alpha: .82),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (provider.errorMessage != null)
                  Container(
                    color: (isDark ? Colors.black : Colors.white)
                        .withValues(alpha: 0.82),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 6.h, color: Colors.red),
                          SizedBox(height: 2.h),
                          Text(
                            provider.errorMessage!,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.6.sp,
                              color: onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2.h),
                          ElevatedButton(
                            onPressed: () =>
                                provider.fetchVehicleList(context: context),
                            child: Text("Retry",
                                style: TextStyle(fontSize: 13.6.sp)),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (!provider.isLoading && provider.deviceMarkers.isEmpty)
                  Container(
                    color: (isDark ? Colors.black : Colors.white)
                        .withValues(alpha: 0.82),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car_outlined,
                              size: 12.h, color: Colors.grey[600]),
                          SizedBox(height: 2.h),
                          Text(
                            provider.deviceListModel == null
                                ? "No devices found."
                                : provider.selectedStatus == 'all'
                                    ? "No vehicles found."
                                    : "No ${provider.getSelectedStatusTitle()} vehicles found.",
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 14.sp,
                              color: onSurface.withValues(alpha: .7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 3.h),
                          ElevatedButton(
                            onPressed: provider.deviceListModel == null
                                ? () =>
                                    provider.fetchVehicleList(context: context)
                                : () {
                                    provider.clearSelectedVehicle();
                                    provider.setSelectedStatus('all');
                                  },
                            child: Text(
                              provider.deviceListModel == null
                                  ? "Retry"
                                  : "Show All Vehicles",
                              style: TextStyle(fontSize: 13.8.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Top-right controls (Layers, Traffic, Labels)
                Positioned(
                  right: 3.w,
                  top: topInset + 5.0.h,
                  child: Column(
                    children: [
                      _mapFab(
                        icon: Icons.center_focus_strong_rounded,
                        bgColor: controlBg,
                        iconColor: controlIcon,
                        onTap: provider.fitAllVehicles,
                      ),
                      verticalSpace(height: 1.2.h),
                      _mapFab(
                        icon: Icons.search_rounded,
                        bgColor: controlBg,
                        iconColor: controlIcon,
                        onTap: () => _openVehicleSearch(context, provider),
                      ),
                      verticalSpace(height: 1.2.h),
                      _mapFab(
                        icon: provider.enableClusterMode
                            ? Icons.hub
                            : Icons.hub_outlined,
                        bgColor: provider.enableClusterMode
                            ? Colors.orange
                            : controlBg,
                        iconColor: provider.enableClusterMode
                            ? Colors.white
                            : controlIcon,
                        onTap: () => provider
                            .setClusterMode(!provider.enableClusterMode),
                      ),
                      verticalSpace(height: 1.2.h),
                      _mapFab(
                        icon: Icons.traffic,
                        bgColor: provider.enableTraffic
                            ? AppColors.green
                            : controlBg,
                        iconColor:
                            provider.enableTraffic ? Colors.white : controlIcon,
                        onTap: provider.toggleTraffic,
                      ),
                      verticalSpace(height: 1.2.h),
                      _mapFab(
                        icon: provider.showMarkerLabels
                            ? Icons.label
                            : Icons.label_off,
                        bgColor: provider.showMarkerLabels
                            ? AppColors.blueCyan
                            : controlBg,
                        iconColor: provider.showMarkerLabels
                            ? Colors.white
                            : controlIcon,
                        onTap: provider.toggleMarkerLabels,
                      ),
                      verticalSpace(height: 1.2.h),
                      _sideZoom(
                        context,
                        true,
                        Icons.add,
                        provider.zoomIn,
                      ),
                      verticalSpace(height: .3.h),
                      _sideZoom(
                        context,
                        false,
                        Icons.remove,
                        provider.zoomOut,
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _showStatusRail
                        ? _buildStatusBoxes(
                            provider,
                            onSurface,
                            cardColor,
                            topInset,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                Positioned(
                  left: 1.4.w,
                  top: topInset + 1.0.h,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () {
                      setState(() => _showStatusRail = !_showStatusRail);
                    },
                    child: SizedBox(
                      width: 20.5.w,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 3.2.h,
                          width: 9.2.w,
                          decoration: BoxDecoration(
                            color: cardColor.withValues(alpha: .95),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: onSurface.withValues(alpha: .14),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _showStatusRail
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 17.sp,
                            color: onSurface.withValues(alpha: .78),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 3.w,
                  top: topInset + 1.2.h,
                  child: _mapStyleToggle(provider),
                ),
                Positioned(
                  top: topInset + 1.3.h,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.2.w, vertical: .55.h),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: .96),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: onSurface.withValues(alpha: .14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Updated • ${_secondsSinceLastRefresh(provider)}s ago',
                          style: AppStyles.regularTextStyle(context).copyWith(
                            fontSize: 12.8.sp,
                            color: onSurface.withValues(alpha: .9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (provider.selectedVehicle != null)
                  Positioned(
                    left: 3.w,
                    right: 3.w,
                    bottom: 2.2.h,
                    child: _miniVehicleCard(provider.selectedVehicle!),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _miniVehicleCard(Item vehicle) {
    final actionColor = _vehicleStatusColor(vehicle);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.0.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: .97),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: .12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .16),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vehicle.name ?? 'Unknown Vehicle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 13.2.sp,
                    ),
                  ),
                  SizedBox(height: .4.h),
                  Text(
                    'Speed: ${vehicle.speed ?? 0} km/h',
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: .15.h),
                  Text(
                    'Update: ${vehicle.time ?? 'N/A'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 11.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .72),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.2.w),
            ElevatedButton(
              onPressed: () {
                final id = vehicle.id ?? 0;
                final lat = _parseCoordinate(vehicle.lat);
                final lng = _parseCoordinate(vehicle.lng);
                final online = (vehicle.online ?? '').toLowerCase().trim();
                final time = (vehicle.time ?? '').toLowerCase().trim();
                final isExpired = online == 'expired' ||
                    (online == 'offline' && time == 'expired');
                final isOffline = online == 'offline' &&
                    time != 'expired' &&
                    time != 'not connected';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SingleVehicleAnalytics(
                      deviceId: id,
                      deviceName: vehicle.name ?? '',
                      sensors: vehicle.sensors ?? [],
                      isExpired: isExpired,
                      isOffline: isOffline,
                      lastStatusTimestamp: vehicle.timestamp,
                      lastAckTimestamp: vehicle.acktimestamp,
                      lastStatusTimeText: vehicle.time,
                      initialVehicleType: vehicle.vehicleType,
                      initialLiveLat: lat,
                      initialLiveLng: lng,
                      initialLiveStatus: vehicle.online,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor.withValues(alpha: .16),
                foregroundColor: actionColor,
                elevation: 0,
                padding:
                    EdgeInsets.symmetric(horizontal: 3.0.w, vertical: .9.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: actionColor.withValues(alpha: .35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Open details',
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 10.6.sp,
                      color: actionColor,
                    ),
                  ),
                  SizedBox(width: 1.1.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12.sp,
                    color: actionColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _vehicleStatusColor(Item vehicle) {
    final online = (vehicle.online ?? '').toLowerCase().trim();
    final time = (vehicle.time ?? '').toLowerCase().trim();
    if (online == 'online' || online == 'running' || online == 'moving') {
      return AppColors.green;
    }
    if (online == 'ack' || online == 'stopped' || online == 'parking') {
      return AppColors.red;
    }
    if (online == 'idle' || online == 'engine') return Colors.orange;
    if (online == 'offline' && time == 'expired') return Colors.purple;
    if (online == 'offline' && time == 'not connected') return Colors.grey;
    return Colors.blue;
  }

  Widget _mapFab({
    required IconData icon,
    required VoidCallback onTap,
    Color? bgColor,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = bgColor ?? theme.cardColor.withValues(alpha: isDark ? .96 : .93);
    final iconTint =
        iconColor ?? theme.colorScheme.onSurface.withValues(alpha: .82);
    return SizedBox(
      width: 9.8.w,
      height: 9.8.w,
      child: FloatingActionButton(
        heroTag: icon.toString(),
        backgroundColor: bg,
        onPressed: onTap,
        elevation: 2,
        child: Icon(icon, color: iconTint, size: 16.5.sp),
      ),
    );
  }

  Widget _sideZoom(
      BuildContext context, bool top, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.cardColor : AppColors.white;
    final shadow =
        isDark ? Colors.black26 : AppColors.grey.withValues(alpha: .5);
    final iconColor = isDark ? AppColors.white : AppColors.textBlack;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 4.4.h,
        width: 4.0.h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.vertical(
            top: top ? const Radius.circular(16) : Radius.zero,
            bottom: !top ? const Radius.circular(16) : Radius.zero,
          ),
          boxShadow: [
            BoxShadow(
              color: shadow,
              offset: const Offset(0, 5),
              spreadRadius: 1,
              blurRadius: 4,
            )
          ],
        ),
        child: Icon(icon, size: 2.6.h, color: iconColor),
      ),
    );
  }
}

class _StatusItem {
  final String title;
  final String key;
  final Color color;
  _StatusItem({required this.title, required this.key, required this.color});
}

class StatusBox extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final Color onSurface;
  final Color cardColor;
  final String selectedKey;

  const StatusBox({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.onSurface,
    required this.cardColor,
    required this.selectedKey,
  });

  String get _statusKey {
    switch (title) {
      case 'All':
        return 'all';
      case 'Running':
        return 'running';
      case 'Stopped':
        return 'stopped';
      case 'Idle':
        return 'idle';
      case 'Offline':
        return 'offline';
      case 'No Data':
        return 'nodata';
      case 'Expired':
        return 'expired';
      default:
        return 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedKey == _statusKey;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 18.3.w,
      height: 3.8.h,
      padding: EdgeInsets.symmetric(horizontal: 1.1.w),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.2)
            : cardColor.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isSelected
              ? color.withValues(alpha: 0.9)
              : onSurface.withValues(alpha: 0.16),
          width: isSelected ? 1.2 : 0.9,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: .90.h,
            height: .90.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          SizedBox(width: .9.w),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : onSurface.withValues(alpha: .85),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: .85.w, vertical: .03.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.18)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: AppStyles.semiboldTextStyle(context).copyWith(
                fontSize: 13.0.sp,
                color: isSelected ? color : onSurface.withValues(alpha: .82),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
