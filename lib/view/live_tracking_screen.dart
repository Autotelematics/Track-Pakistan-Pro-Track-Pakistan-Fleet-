import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/providers/live_tracking_provider.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:intl/intl.dart';

class NewLiveTrackingPage extends StatefulWidget {
  const NewLiveTrackingPage({super.key});

  @override
  State<NewLiveTrackingPage> createState() => _NewLiveTrackingPageState();
}

class _NewLiveTrackingPageState extends State<NewLiveTrackingPage> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return ChangeNotifierProvider(
      create: (_) => LiveTrackingProvider(),
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Column(
              children: [
                // Top Card Section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12.sp),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 30.w,
                            child: Transform.scale(
                              scale: 1.2,
                              child: Image.network(
                                "https://cdn.pixabay.com/photo/2013/07/13/11/50/car-158795_1280.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          horizontalSpace(width: 3.w),
                          Consumer<LiveTrackingProvider>(
                            builder: (context, provider, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSpeedometer(context, provider.speed),
                                  verticalSpace(height: 1.h),
                                  Text(
                                    "Updated: ${DateFormat('dd MMM yyyy, HH:mm:ss').format(provider.lastUpdated)}",
                                    style: AppStyles.regularTextStyle(context)
                                        .copyWith(
                                      color: onSurface.withOpacity(0.6),
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      verticalSpace(height: 2.h),
                      // Action Buttons Row
                      Consumer<LiveTrackingProvider>(
                        builder: (context, provider, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionButton(
                                context: context,
                                icon: provider.isLocked
                                    ? Icons.lock
                                    : Icons.lock_open,
                                label:
                                    provider.isLocked ? "Locked" : "Unlocked",
                                color: provider.isLocked
                                    ? AppColors.red
                                    : AppColors.green,
                                onTap: provider.toggleLock,
                              ),
                              horizontalSpace(width: 3.w),
                              _buildActionButton(
                                context: context,
                                icon: provider.isStopped
                                    ? Icons.play_arrow
                                    : Icons.stop,
                                label: provider.isStopped ? "Start" : "Stop",
                                color: provider.isStopped
                                    ? AppColors.green
                                    : AppColors.red,
                                onTap: provider.toggleStopStart,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Google Map
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.sp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.sp),
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(24.849269, 67.005017),
                          zoom: 14,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        markers: {
                          Marker(
                            markerId: MarkerId('vehicle'),
                            position: LatLng(24.849269, 67.005017),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue),
                          ),
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Speedometer Widget
  Widget _buildSpeedometer(BuildContext context, double speed) {
    return Container(
      width: 30.w,
      height: 32.w,
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.lerp(AppColors.green, Colors.white, 0.9)!,
            const Color.fromARGB(255, 255, 255, 255),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: 150,
            radiusFactor: 0.95,
            interval: 20,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.08,
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            majorTickStyle: const MajorTickStyle(
              length: 8,
              thickness: 2,
              color: Colors.black54,
            ),
            minorTickStyle: const MinorTickStyle(
              length: 4,
              thickness: 1,
              color: Colors.black54,
            ),
            showLabels: true,
            axisLabelStyle: GaugeTextStyle(fontSize: 11.sp),
            labelOffset: 10,
            ranges: [
              GaugeRange(
                startValue: 0,
                endValue: 50,
                color: Colors.green[400],
              ),
              GaugeRange(
                startValue: 50,
                endValue: 100,
                color: Colors.orange[400],
              ),
              GaugeRange(
                startValue: 100,
                endValue: 150,
                color: Colors.red[400],
              ),
            ],
            pointers: const [
              NeedlePointer(
                value: 65, // Dummy speed
                needleColor: Colors.black87,
                needleStartWidth: 1,
                needleEndWidth: 5,
                needleLength: 0.5,
                knobStyle: KnobStyle(
                  color: Colors.redAccent,
                  borderWidth: 0.05,
                  borderColor: Colors.black54,
                  sizeUnit: GaugeSizeUnit.factor,
                  knobRadius: 0.08,
                ),
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: const Text(
                  '65 km/h', // Dummy speed
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                angle: 90,
                positionFactor: 0.8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable Action Button Widget
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: label == "Stop" || label == "Start" ? 8.w : 5.w,
          vertical: 0.6.h,
        ),
        height: 5.h,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 3.2.h, color: color),
            horizontalSpace(width: 1.w),
            Text(
              label,
              style: AppStyles.statusTitle(context).copyWith(
                color: color,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
