import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/vehicle_tracking_provider.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class RightSideButtons extends StatefulWidget {
  final String status;
  final VoidCallback? onToggleMap;
  final VoidCallback? onToggleTraffic;
  final VoidCallback? onCenter;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onShare;
  final VoidCallback? onLaunch;

  const RightSideButtons({
    super.key,
    required this.status,
    this.onToggleMap,
    this.onToggleTraffic,
    this.onCenter,
    this.onZoomIn,
    this.onZoomOut,
    this.onShare,
    this.onLaunch,
  });

  @override
  State<RightSideButtons> createState() => _RightSideButtonsState();
}

class _RightSideButtonsState extends State<RightSideButtons> {
  Widget _circle(
      BuildContext context, IconData icon, VoidCallback? onTap, {Color? iconColorOverride}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.cardColor : AppColors.white;
    final shadow = isDark ? Colors.black26 : AppColors.grey.withOpacity(.5);
    final iconColor = iconColorOverride ?? (isDark ? AppColors.white : AppColors.textBlack);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 5.h,
        width: 5.h,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadow,
              offset: const Offset(0, 5),
              spreadRadius: 3,
              blurRadius: 5,
            )
          ],
        ),
        child: Icon(icon, size: 2.2.h, color: iconColor),
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
        height: 4.h,
        width: 3.6.h,
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
        child: Icon(icon, size: 2.6.h, color: iconColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleTrackingProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _circle(
              context,
              Icons.share,
              widget.onShare ?? () => _shareLocation(provider.latitude, provider.longitude),
            ),
            verticalSpace(height: 1.5.h),
            _circle(
              context,
              provider.currentMapType == MapType.normal ? Icons.map_outlined : Icons.layers,
              widget.onToggleMap ?? provider.toggleMapType,
            ),
            verticalSpace(height: 1.5.h),
            _circle(
              context,
              provider.enableTraffic ? Icons.traffic : Icons.traffic_outlined,
              widget.onToggleTraffic ?? provider.toggleTraffic,
            ),
            // _circle(
            //   context,
            //   Icons.my_location_outlined,
            //   widget.onCenter ?? provider.centerOnVehicle,
            // ),
            verticalSpace(height: 1.5.h),
            _sideZoom(
              context,
              true,
              Icons.add,
              widget.onZoomIn ?? () => provider.adjustZoom(provider.currentZoom + 1),
            ),
            verticalSpace(height: .3.h),
            // Zoom Out
            _sideZoom(
              context,
              false,
              Icons.remove,
              widget.onZoomOut ?? () => provider.adjustZoom(provider.currentZoom - 1),
            ),
          ],
        );
      },
    );
  }

  void _shareLocation(double lat, double lng) {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    Share.share('Vehicle Location: $url');
  }
}