import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/get_devices_status_provider.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class MapForAllVehiclesScreen extends StatefulWidget {
  const MapForAllVehiclesScreen({super.key});

  @override
  State<MapForAllVehiclesScreen> createState() => _MapForAllVehiclesScreenState();
}

class _MapForAllVehiclesScreenState extends State<MapForAllVehiclesScreen> {
  late final VehicleMapProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = VehicleMapProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.startPeriodicRefresh(context);
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Widget _buildStatusBoxes(VehicleMapProvider provider, Color onSurface, Color cardColor) {
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
      padding: EdgeInsets.only(top: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 0.6.h,
            offset: Offset(0, 0.3.h),
          ),
        ],
      ),
      height: 14.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final statusItem = statuses[index];
          final count = provider.getStatusCount(statusItem.key);

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => provider.setSelectedStatus(statusItem.key),
            child: StatusBox(
              title: statusItem.title,
              count: count,
              color: statusItem.color,
              onSurface: onSurface,
              cardColor: cardColor,
              selectedKey: provider.selectedStatus,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;

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
                ),

                if (provider.isLoading)
                  Container(
                    color: Colors.white.withOpacity(0.85),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(height: 2.h),
                          Text('Loading devices...', style: TextStyle(fontSize: 16.sp)),
                        ],
                      ),
                    ),
                  ),

                if (provider.errorMessage != null)
                  Container(
                    color: Colors.white.withOpacity(0.85),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 6.h, color: Colors.red),
                          SizedBox(height: 2.h),
                          Text(provider.errorMessage!, style: TextStyle(fontSize: 15.sp), textAlign: TextAlign.center),
                          SizedBox(height: 2.h),
                          ElevatedButton(
                            onPressed: () => provider.fetchVehicleList(context: context),
                            child: Text("Retry", style: TextStyle(fontSize: 15.sp)),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (!provider.isLoading && provider.deviceMarkers.isEmpty)
                  Container(
                    color: Colors.white.withOpacity(0.85),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car_outlined, size: 12.h, color: Colors.grey[600]),
                          SizedBox(height: 2.h),
                          Text(
                            provider.deviceListModel == null
                                ? "No devices found."
                                : provider.selectedStatus == 'all'
                                ? "No vehicles found."
                                : "No ${provider.getSelectedStatusTitle()} vehicles found.",
                            style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 3.h),
                          ElevatedButton(
                            onPressed: provider.deviceListModel == null
                                ? () => provider.fetchVehicleList(context: context)
                                : () => provider.setSelectedStatus('all'),
                            child: Text(
                              provider.deviceListModel == null ? "Retry" : "Show All Vehicles",
                              style: TextStyle(fontSize: 15.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Top-right controls (Layers, Traffic, Labels)
                Positioned(
                  right: 3.w,
                  top: 18.h,
                  child: Column(
                    children: [
                      _mapFab(icon: Icons.layers, onTap: provider.toggleMapType),
                      verticalSpace(height: 1.5.h),
                      _mapFab(
                        icon: Icons.traffic,
                        bgColor: provider.enableTraffic ? Colors.green : Colors.white,
                        onTap: provider.toggleTraffic,
                      ),
                      verticalSpace(height: 1.5.h),
                      _mapFab(
                        icon: provider.showMarkerLabels ? Icons.label : Icons.label_off,
                        onTap: provider.toggleMarkerLabels,
                      ),
                      verticalSpace(height: 1.5.h),

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
                  right: 0,
                  top: 0,
                  child: _buildStatusBoxes(provider, onSurface, cardColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _mapFab({
    required IconData icon,
    required VoidCallback onTap,
    Color bgColor = Colors.white,
    Color iconColor = Colors.black54,
  }) {
    return SizedBox(
      width: 11.w,
      height: 11.w,
      child: FloatingActionButton(
        heroTag: icon.toString(),
        backgroundColor: bgColor,
        onPressed: onTap,
        child: Icon(icon, color: iconColor, size: 18.sp),
      ),
    );
  }
  Widget _sideZoom(BuildContext context, bool top, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.cardColor : AppColors.white;
    final shadow = isDark ? Colors.black26 : AppColors.grey.withOpacity(.5);
    final iconColor = isDark ? AppColors.white : AppColors.textBlack;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 5.h,
        width: 4.3.h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.vertical(
            top: top ? const Radius.circular(20) : Radius.zero,
            bottom: !top ? const Radius.circular(20) : Radius.zero,
          ),
          boxShadow: [
            BoxShadow(
              color: shadow,
              offset: const Offset(0, 5),
              spreadRadius: 3,
              blurRadius: 5,
            )
          ],
        ),
        child: Icon(icon, size: 3.h, color: iconColor),
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
      case 'All': return 'all';
      case 'Running': return 'running';
      case 'Stopped': return 'stopped';
      case 'Idle': return 'idle';
      case 'Offline': return 'offline';
      case 'No Data': return 'nodata';
      case 'Expired': return 'expired';
      default: return 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedKey == _statusKey;

    final countStr = count.toString();
    final digits = countStr.length;
    final baseCircleSize = 3.4.h;
    final circleSize = baseCircleSize + (digits > 3 ? (digits - 3) * 0.4.h : 0);
    final boxWidth = 15.5.w;
    final boxHeight = 3.5.h;

    return Padding(
      padding: EdgeInsets.only(right: 1.w),
      child: SizedBox(
        width: boxWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: circleSize / 2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: boxWidth,
                height: boxHeight,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.only(top: 1.6.h),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: (boxWidth - circleSize) / 2,
              child: Container(
                width: circleSize,
                height: circleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardColor,
                  border: Border.all(
                    color: isSelected ? color : color.withOpacity(0.5),
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  countStr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isSelected ? color : onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
