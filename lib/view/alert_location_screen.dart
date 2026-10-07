import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_alerts_list_model.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertLocationScreen extends StatefulWidget {
  final Item alert;

  const AlertLocationScreen({super.key, required this.alert});

  @override
  State<AlertLocationScreen> createState() => _AlertLocationScreenState();
}

class _AlertLocationScreenState extends State<AlertLocationScreen> {
  GoogleMapController? _mapController;
  static const double _defaultZoom = 16.0;
  String? _googleMapStyle;
  Brightness? _appliedMapBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_appliedMapBrightness != brightness) {
      unawaited(_applyMapStyleForTheme());
    }
  }

  Future<void> _applyMapStyleForTheme() async {
    final brightness = Theme.of(context).brightness;
    String? nextStyle;
    if (brightness == Brightness.dark) {
      try {
        nextStyle = await rootBundle.loadString('assets/map_styles/google_dark.json');
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _googleMapStyle = nextStyle;
      _appliedMapBrightness = brightness;
    });
  }

  void _recenter() {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.alert.latitude, widget.alert.longitude),
          zoom: _defaultZoom,
        ),
      ),
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
    final softRed = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444);
    final softRedBg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
    final alert = widget.alert;
    final point = LatLng(alert.latitude, alert.longitude);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Alert Location',
          style: AppStyles.semiboldTextStyle(context).copyWith(
            fontSize: 16.5.sp,
            color: onSurface,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            style: _googleMapStyle,
            initialCameraPosition: CameraPosition(
              target: point,
              zoom: _defaultZoom,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: point, zoom: _defaultZoom),
                ),
              );
            },
            markers: {
              Marker(
                markerId: const MarkerId('alert_marker'),
                position: point,
                infoWindow: InfoWindow(
                  title: alert.deviceName,
                  snippet: alert.message,
                ),
              ),
            },
          ),
          Positioned(
            right: 4.w,
            top: 2.h,
            child: Column(
              children: [
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 1.8.h, 4.w, 2.4.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 10.w,
                      height: 0.45.h,
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  verticalSpace(height: 1.2.h),
                  Row(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: softRedBg.withValues(alpha: isDark ? 0.5 : 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: softRed.withValues(alpha: .35),
                          ),
                        ),
                        child: Icon(
                          Icons.notification_important_rounded,
                          color: softRed,
                          size: 19.sp,
                        ),
                      ),
                      SizedBox(width: 2.6.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ALERT',
                              style: AppStyles.semiboldTextStyle(context).copyWith(
                                color: softRed,
                                fontSize: 15.8.sp,
                                letterSpacing: .4,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              alert.deviceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.semiboldTextStyle(context).copyWith(
                                color: onSurface,
                                fontSize: 14.8.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(height: 1.0.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: softRedBg.withValues(alpha: isDark ? .22 : .55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: softRed.withValues(alpha: .30),
                      ),
                    ),
                    child: Text(
                      alert.message,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        color: onSurface.withValues(alpha: 0.94),
                        fontSize: 14.5.sp,
                        height: 1.25,
                      ),
                    ),
                  ),
                  verticalSpace(height: 1.0.h),
                  _detailTile(
                    context,
                    icon: Icons.label_rounded,
                    label: 'Type',
                    value: alert.type,
                  ),
                  verticalSpace(height: .7.h),
                  _detailTile(
                    context,
                    icon: Icons.schedule_rounded,
                    label: 'Time',
                    value: alert.time != null
                        ? DateFormat('dd-MM-yyyy hh:mm:ss a').format(alert.time!.toLocal())
                        : "No time",
                  ),
                  verticalSpace(height: .7.h),
                  _detailTile(
                    context,
                    icon: Icons.place_rounded,
                    label: 'Location',
                    value: '${alert.latitude.toStringAsFixed(6)}, ${alert.longitude.toStringAsFixed(6)}',
                  ),
                  if (alert.address.trim().isNotEmpty) ...[
                    verticalSpace(height: .7.h),
                    _detailTile(
                      context,
                      icon: Icons.route_rounded,
                      label: 'Address',
                      value: alert.address,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final tileBg =
        isDark ? Colors.white.withValues(alpha: .04) : const Color(0xFFF4F6FB);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .85.h),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .06)
              : Colors.black.withValues(alpha: .05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.2.sp, color: onSurface.withValues(alpha: 0.72)),
          SizedBox(width: 2.2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    color: onSurface.withValues(alpha: 0.58),
                    fontSize: 11.2.sp,
                    letterSpacing: .3,
                  ),
                ),
                SizedBox(height: .12.h),
                Text(
                  value,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    color: onSurface.withValues(alpha: 0.93),
                    fontSize: 13.4.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
