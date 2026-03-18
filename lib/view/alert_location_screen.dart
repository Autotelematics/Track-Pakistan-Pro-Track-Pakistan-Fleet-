import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_alerts_list_model.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertLocationScreen extends StatefulWidget {
  final Item alert;

  const AlertLocationScreen({super.key, required this.alert});

  @override
  State<AlertLocationScreen> createState() => _AlertLocationScreenState();
}

class _AlertLocationScreenState extends State<AlertLocationScreen> {
  final MapController _mapController = MapController();
  static const double _defaultZoom = 15.5;
  double _currentZoom = _defaultZoom;

  void _zoomBy(double delta) {
    final nextZoom = (_currentZoom + delta).clamp(3.0, 19.0).toDouble();
    setState(() => _currentZoom = nextZoom);
    _mapController.move(
      LatLng(widget.alert.latitude, widget.alert.longitude),
      nextZoom,
    );
  }

  void _recenter() {
    setState(() => _currentZoom = _defaultZoom);
    _mapController.move(
      LatLng(widget.alert.latitude, widget.alert.longitude),
      _defaultZoom,
    );
  }

  Future<void> _openInGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.alert.latitude},${widget.alert.longitude}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final alert = widget.alert;
    final point = LatLng(alert.latitude, alert.longitude);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Alert Location'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: point,
                      initialZoom: _defaultZoom,
                      onPositionChanged: (position, _) {
                        final z = position.zoom;
                        if (z != null && z != _currentZoom) {
                          setState(() => _currentZoom = z);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.trackerapp.mobile',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: point,
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.location_pin,
                              size: 46,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: 3.w,
                    top: 2.h,
                    child: Column(
                      children: [
                        _mapControlButton(
                          icon: Icons.add_rounded,
                          onTap: () => _zoomBy(1),
                        ),
                        SizedBox(height: .8.h),
                        _mapControlButton(
                          icon: Icons.remove_rounded,
                          onTap: () => _zoomBy(-1),
                        ),
                        SizedBox(height: .8.h),
                        _mapControlButton(
                          icon: Icons.my_location_rounded,
                          onTap: _recenter,
                        ),
                        SizedBox(height: .8.h),
                        _mapControlButton(
                          icon: Icons.open_in_new_rounded,
                          onTap: _openInGoogleMaps,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 2.h),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      colors: [
                        theme.cardColor,
                        theme.colorScheme.surface.withValues(alpha: 0.94),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white,
                        AppColors.scaffoldBg,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 9.w,
                      height: 9.w,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.notification_important_rounded,
                        color: Colors.redAccent,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 2.6.w),
                    Expanded(
                      child: Text(
                        alert.deviceName,
                        style: AppStyles.semiboldTextStyle(context).copyWith(
                          color: onSurface,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace(height: .8.h),
                Text(
                  alert.message,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    color: onSurface.withValues(alpha: 0.85),
                    fontSize: 14.sp,
                  ),
                ),
                verticalSpace(height: 1.h),
                _infoRow(
                  context,
                  icon: Icons.label_rounded,
                  label: 'Type',
                  value: alert.type,
                ),
                verticalSpace(height: .55.h),
                _infoRow(
                  context,
                  icon: Icons.schedule_rounded,
                  label: 'Time',
                  value: alert.time?.toLocal().toString().split(".").first ??
                      "No time",
                ),
                verticalSpace(height: .55.h),
                _infoRow(
                  context,
                  icon: Icons.place_rounded,
                  label: 'Location',
                  value:
                      '${alert.latitude.toStringAsFixed(6)}, ${alert.longitude.toStringAsFixed(6)}',
                ),
                if (alert.address.trim().isNotEmpty) ...[
                  verticalSpace(height: .55.h),
                  _infoRow(
                    context,
                    icon: Icons.route_rounded,
                    label: 'Address',
                    value: alert.address,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: onSurface.withValues(alpha: 0.6)),
        SizedBox(width: 1.8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: AppStyles.lightTextStyle(context).copyWith(
                    color: onSurface.withValues(alpha: 0.72),
                    fontSize: 13.sp,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppStyles.lightTextStyle(context).copyWith(
                    color: onSurface.withValues(alpha: 0.84),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          height: 4.6.h,
          width: 4.6.h,
          decoration: BoxDecoration(
            color: isDark
                ? theme.cardColor.withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.14),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.88),
          ),
        ),
      ),
    );
  }
}
