import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/vehicle_tracking_provider.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/single_vehicle_tracking_widget/tracking_scale.dart';

class RightSideButtons extends StatefulWidget {
  final String status;
  final VoidCallback? onToggleMap;
  final VoidCallback? onToggleTraffic;
  final VoidCallback? onToggleFollow;
  final VoidCallback? onResetNorth;
  final VoidCallback? onToggleRuler;
  final VoidCallback? onLocateUser;
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
    this.onToggleFollow,
    this.onResetNorth,
    this.onToggleRuler,
    this.onLocateUser,
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
  Widget _controlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
    Color? iconColorOverride,
    Color? bgColorOverride,
    EdgeInsetsGeometry? margin,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconScale = trackingIconScale(context);
    final bg = bgColorOverride ??
        (isDark
            ? theme.cardColor.withValues(alpha: .9)
            : AppColors.white.withValues(alpha: .94));
    final iconColor =
        iconColorOverride ?? (isDark ? AppColors.white : AppColors.textBlack);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .28 : .14),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            height: (4.4 * iconScale).h,
            width: (4.4 * iconScale).h,
            child: Icon(icon, size: (1.9 * iconScale).h, color: iconColor),
          ),
        ),
      ),
    );
  }

  Widget _circle(BuildContext context, IconData icon, VoidCallback? onTap,
      {Color? iconColorOverride, Color? bgColorOverride}) {
    return _controlButton(
      context,
      icon: icon,
      onTap: onTap,
      iconColorOverride: iconColorOverride,
      bgColorOverride: bgColorOverride,
    );
  }

  Widget _sideZoom(
      BuildContext context, bool top, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconScale = trackingIconScale(context);
    final bg = isDark
        ? theme.cardColor.withValues(alpha: .92)
        : AppColors.white.withValues(alpha: .95);
    final iconColor = isDark ? AppColors.white : AppColors.textBlack;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .26 : .13),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.vertical(
          top: top ? const Radius.circular(16) : Radius.zero,
          bottom: !top ? const Radius.circular(16) : Radius.zero,
        ),
        child: InkWell(
          borderRadius: BorderRadius.vertical(
            top: top ? const Radius.circular(16) : Radius.zero,
            bottom: !top ? const Radius.circular(16) : Radius.zero,
          ),
          onTap: onTap,
          child: SizedBox(
            height: (3.6 * iconScale).h,
            width: (3.4 * iconScale).h,
            child: Icon(icon, size: (2.0 * iconScale).h, color: iconColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleTrackingProvider>(
      builder: (context, provider, child) {
        final controls = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _circle(
              context,
              Icons.share,
              widget.onShare ??
                  () => _shareLocation(provider.latitude, provider.longitude),
            ),
            verticalSpace(height: .95.h),
            _circle(
              context,
              provider.followVehicle
                  ? Icons.navigation
                  : Icons.navigation_outlined,
              widget.onToggleFollow ?? provider.toggleFollowVehicle,
              iconColorOverride: provider.followVehicle
                  ? AppColors.white
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.textBlack),
              bgColorOverride: provider.followVehicle ? AppColors.green : null,
            ),
            verticalSpace(height: .95.h),
            _circle(
              context,
              provider.currentMapType == MapType.normal
                  ? Icons.map_outlined
                  : Icons.layers,
              widget.onToggleMap ?? provider.toggleMapType,
            ),
            verticalSpace(height: .95.h),
            _circle(
              context,
              Icons.explore_outlined,
              widget.onResetNorth,
            ),
            verticalSpace(height: .95.h),
            _circle(
              context,
              provider.rulerMode
                  ? Icons.straighten_rounded
                  : Icons.straighten_outlined,
              widget.onToggleRuler ?? provider.toggleRulerMode,
              iconColorOverride: provider.rulerMode
                  ? AppColors.white
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.textBlack),
              bgColorOverride: provider.rulerMode ? AppColors.blueCyan : null,
            ),
            verticalSpace(height: .95.h),
            _circle(
              context,
              provider.enableTraffic ? Icons.traffic : Icons.traffic_outlined,
              widget.onToggleTraffic ?? provider.toggleTraffic,
            ),
            verticalSpace(height: .95.h),
            _circle(
              context,
              Icons.my_location_outlined,
              widget.onLocateUser,
              iconColorOverride: provider.isLocatingUser
                  ? AppColors.white
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.textBlack),
              bgColorOverride:
                  provider.isLocatingUser ? AppColors.blueCyan : null,
            ),
            verticalSpace(height: .95.h),
            _circle(
              context,
              Icons.directions_outlined,
              widget.onLaunch,
            ),
            // _circle(
            //   context,
            //   Icons.my_location_outlined,
            //   widget.onCenter ?? provider.centerOnVehicle,
            // ),
            verticalSpace(height: .95.h),
            _sideZoom(
              context,
              true,
              Icons.add,
              widget.onZoomIn ??
                  () => provider.adjustZoom(provider.currentZoom + 1),
            ),
            verticalSpace(height: .3.h),
            // Zoom Out
            _sideZoom(
              context,
              false,
              Icons.remove,
              widget.onZoomOut ??
                  () => provider.adjustZoom(provider.currentZoom - 1),
            ),
          ],
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            if (!constraints.hasBoundedHeight) return controls;
            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: controls,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _shareLocation(double lat, double lng) {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    SharePlus.instance.share(ShareParams(text: 'Vehicle Location: $url'));
  }
}
