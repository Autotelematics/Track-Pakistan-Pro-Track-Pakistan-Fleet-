import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_analytics_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_history_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_info_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_notifications_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_report_type_screen.dart';
import 'package:trackerapp/view/single_vehicle_screens/single_vehicle_tracking_screen.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

class SingleVehicleAnalytics extends StatefulWidget {
  final List<Sensor> sensors;
  final int deviceId;
  final String deviceName;
  final bool isExpired;
  final bool isOffline;
  final int? lastStatusTimestamp;
  final int? lastAckTimestamp;
  final String? lastStatusTimeText;
  final String? initialKmPerLiter;
  final String? initialEngineType;
  final String? initialVehicleType;
  final double? initialLiveLat;
  final double? initialLiveLng;
  final String? initialLiveStatus;

  const SingleVehicleAnalytics({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.sensors,
    this.isExpired = false,
    this.isOffline = false,
    this.lastStatusTimestamp,
    this.lastAckTimestamp,
    this.lastStatusTimeText,
    this.initialKmPerLiter,
    this.initialEngineType,
    this.initialVehicleType,
    this.initialLiveLat,
    this.initialLiveLng,
    this.initialLiveStatus,
  });

  @override
  State<SingleVehicleAnalytics> createState() => _SingleVehicleAnalyticsState();
}

class _SingleVehicleAnalyticsState extends State<SingleVehicleAnalytics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _offlineDialogShown = false;
  final Map<String, dynamic> vehicleData = {
    'driverName': 'John Doe',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOfflineDialogIfNeeded();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showOfflineDialogIfNeeded() {
    if (!mounted || _offlineDialogShown) return;
    if (widget.isExpired || !widget.isOffline) return;
    _offlineDialogShown = true;

    final offlineSinceText = _formatOfflineSince(
      primaryTimestamp: widget.lastStatusTimestamp,
      fallbackTimestamp: widget.lastAckTimestamp,
      fallbackTimeText: widget.lastStatusTimeText,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final l10n = context.l10n;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final onSurface = theme.colorScheme.onSurface;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 9.w),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor:
              isDark ? theme.scaffoldBackgroundColor : Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.2.w, 1.8.h, 4.2.w, 1.3.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 4.8.h,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -.6.h,
                        right: -1.w,
                        child: Icon(
                          Icons.wifi_off_rounded,
                          color: AppColors.blueCyan
                              .withValues(alpha: isDark ? 0.22 : 0.16),
                          size: 6.2.h,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          l10n.vehicleOffline,
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: .45.h),
                Text(
                  l10n.vehicleOfflineSince(offlineSinceText),
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 13.4.sp,
                    color: onSurface.withValues(alpha: .82),
                  ),
                ),
                SizedBox(height: 1.35.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    text: l10n.ok,
                    height: 4.h,
                    width: 22.w,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatOfflineSince({
    int? primaryTimestamp,
    int? fallbackTimestamp,
    String? fallbackTimeText,
  }) {
    final l10n = context.l10n;
    final ts = _pickTimestamp(primaryTimestamp, fallbackTimestamp);
    final since = ts != null
        ? _dateTimeFromEpoch(ts)
        : _parseTimeTextToDateTime(fallbackTimeText);
    if (since == null) return l10n.unknownTime;
    Duration diff = DateTime.now().difference(since);
    if (diff.isNegative) diff = Duration.zero;

    int totalDays = diff.inDays;
    final years = totalDays ~/ 365;
    totalDays %= 365;
    final months = totalDays ~/ 30;
    final days = totalDays % 30;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    final parts = <String>[];
    if (years > 0) parts.add("${years}y");
    if (months > 0) parts.add("${months}m");
    if (days > 0) parts.add("${days}d");
    if (hours > 0) parts.add("${hours}h");
    if (minutes > 0) parts.add("${minutes}min");

    if (parts.isEmpty) {
      return "0min";
    }
    return parts.join(" ");
  }

  int? _pickTimestamp(int? primary, int? fallback) {
    if (primary != null && primary > 0) return primary;
    if (fallback != null && fallback > 0) return fallback;
    return null;
  }

  DateTime _dateTimeFromEpoch(int value) {
    if (value >= 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }

  DateTime? _parseTimeTextToDateTime(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty) return null;

    final lower = text.toLowerCase();
    if (lower == 'not connected' || lower == 'expired' || lower == 'n/a') {
      return null;
    }

    // Common absolute formats from APIs.
    const formats = [
      "dd-MM-yyyy hh:mm:ss a",
      "dd-MM-yyyy HH:mm:ss",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd hh:mm:ss a",
    ];
    for (final f in formats) {
      try {
        return DateFormat(f).parse(text, true).toLocal();
      } catch (_) {}
    }

    // ISO fallback.
    final iso = DateTime.tryParse(text);
    if (iso != null) return iso.toLocal();

    // Relative fallback, e.g. "2h 10min", "3 days 4 hours ago".
    final matches = RegExp(
            r'(\d+)\s*(years?|y|months?|mo|days?|d|hours?|h|minutes?|mins?|m|seconds?|secs?|s)')
        .allMatches(lower);
    if (matches.isEmpty) return null;

    int totalSeconds = 0;
    for (final m in matches) {
      final value = int.tryParse(m.group(1) ?? '') ?? 0;
      final unit = m.group(2) ?? '';
      if (value <= 0) continue;
      if (unit.startsWith('y')) {
        totalSeconds += value * 365 * 24 * 3600;
      } else if (unit.startsWith('mo')) {
        totalSeconds += value * 30 * 24 * 3600;
      } else if (unit.startsWith('d')) {
        totalSeconds += value * 24 * 3600;
      } else if (unit.startsWith('h')) {
        totalSeconds += value * 3600;
      } else if (unit.startsWith('m')) {
        totalSeconds += value * 60;
      } else {
        totalSeconds += value;
      }
    }
    if (totalSeconds <= 0) return null;
    return DateTime.now().subtract(Duration(seconds: totalSeconds));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.padding.top;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final physicalWidth = mediaQuery.size.width * mediaQuery.devicePixelRatio;
    final physicalHeight = mediaQuery.size.height * mediaQuery.devicePixelRatio;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isTallPortrait =
        isAndroid && !isLandscape && mediaQuery.size.height >= 820;
    final isVeryTallPortrait =
        isTallPortrait && (mediaQuery.size.height / mediaQuery.size.width) >= 2.0;
    final isHighResPortrait = isAndroid &&
        !isLandscape &&
        physicalHeight >= 3000 &&
        physicalWidth >= 1400;
    final isUltraWideLandscape =
        isLandscape && mediaQuery.size.width >= 1900;
    final isTallScreen = mediaQuery.size.height >= 850 && !isLandscape;
    final tabBarHeight = isUltraWideLandscape
        ? 66.0
        : (isLandscape
            ? 58.0
            : (isHighResPortrait
                ? 92.0
                : (isVeryTallPortrait ? 80.0 : (isTallPortrait ? 66.0 : 60.0))));
    final tabBarVerticalPadding = isLandscape ? 0.0 : .22.h;
    final tabBarTop =
        topInset +
            (isUltraWideLandscape
                ? 20.0
                : (isLandscape
                    ? 16.0
                    : (isHighResPortrait
                        ? 98.0
                        : (isVeryTallPortrait ? 82.0 : (isTallPortrait ? 64.0 : 54.0)))));
    final contentTop = tabBarTop + tabBarHeight + (isLandscape ? 8.0 : 10.0);
    final headerHeight = contentTop + (isLandscape ? 3.0 : 2.0);
    final headerTopPadding =
        topInset +
            (isUltraWideLandscape
                ? 7.0
                : (isLandscape
                    ? 3.0
                    : (isHighResPortrait
                        ? 12.0
                        : (isVeryTallPortrait ? 10.0 : (isTallPortrait ? 9.0 : 7.0)))));
    final tabIconSize = isUltraWideLandscape
        ? 19.0
        : (isLandscape
            ? 16.0
            : (isHighResPortrait
                ? 28.0
                : (isVeryTallPortrait
                ? 24.0
                : (isTallPortrait ? 22.0 : (isTallScreen ? 21.0 : 19.0)))));
    final tabTextSize = isUltraWideLandscape
        ? 10.5
        : (isLandscape
            ? 9.0
            : (isHighResPortrait
                ? 16.0.sp
                : (isVeryTallPortrait
                ? 14.0.sp
                : (isTallPortrait ? 13.0.sp : (isTallScreen ? 12.6.sp : 11.6.sp)))));
    final tabItemHeight = isUltraWideLandscape
        ? 58.0
        : (isLandscape
            ? 50.0
            : (isHighResPortrait
                ? 84.0
                : (isVeryTallPortrait ? 74.0 : (isTallPortrait ? 60.0 : null))));
    Tab buildCompactTab(IconData icon, String label) {
      return Tab(
        height: tabItemHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: tabIconSize),
            SizedBox(
              height: (isUltraWideLandscape || isVeryTallPortrait) ? 2 : 1,
            ),
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: tabTextSize,
                height: 1.0,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: contentTop),
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                KeepAliveWrapper(
                    child: VehicleTrackingScreen(
                  deviceId: widget.deviceId,
                  initialVehicleType: widget.initialVehicleType,
                  isExpired: widget.isExpired,
                )),
                KeepAliveWrapper(
                    child: SingleVehicleAnalyticsScreen(
                        deviceId: widget.deviceId,
                        vehicleName: widget.deviceName)),
                KeepAliveWrapper(
                    child: SingleReportTypesScreen(
                  deviceId: widget.deviceId,
                  deviceTitle: widget.deviceName,
                )),
                KeepAliveWrapper(
                  child: SingleVehicleHistoryScreen(
                    deviceId: widget.deviceId,
                    deviceTitle: widget.deviceName,
                    initialKmPerLiter: widget.initialKmPerLiter,
                    initialEngineType: widget.initialEngineType,
                    initialLivePosition: (widget.initialLiveLat != null &&
                            widget.initialLiveLng != null &&
                            widget.initialLiveLat != 0 &&
                            widget.initialLiveLng != 0)
                        ? LatLng(widget.initialLiveLat!, widget.initialLiveLng!)
                        : null,
                    initialLiveStatus: widget.initialLiveStatus,
                  ),
                ),
                KeepAliveWrapper(
                    child: SingleVehicleAlertScreen(
                  deviceId: widget.deviceId,
                )),
                KeepAliveWrapper(
                  child: SingleVehicleInfoScreen(
                    sensors: widget.sensors,
                    deviceId: widget.deviceId,
                    vehicleName: widget.deviceName,
                    initialKmPerLiter: widget.initialKmPerLiter,
                    initialEngineType: widget.initialEngineType,
                    initialVehicleType: widget.initialVehicleType,
                  ),
                ),
              ],
            ),
          ),

          // Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ConstantColor.secondaryColor,
                    ConstantColor.secondaryColor,
                    ConstantColor.secondaryColor.withValues(alpha: 0.5),
                    ConstantColor.secondaryColor.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(38),
                  bottomRight: Radius.circular(38),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    offset: const Offset(0, 4),
                    blurRadius: 20,
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: headerTopPadding),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                        size: 3.h,
                      ),
                    ),
                    horizontalSpace(width: 6.w),
                    Text(
                      widget.deviceName.length > 20
                          ? "${widget.deviceName.substring(0, 20)}..."
                          : widget.deviceName,
                      style: AppStyles.vehicleTitle(context).copyWith(
                        color: AppColors.white,
                        fontSize: isHighResPortrait
                            ? 19.0.sp
                            : (isVeryTallPortrait ? 20.0.sp : 18.sp),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // TabBar (Placed over header)
          Positioned(
            top: tabBarTop,
            left: 3.w,
            right: 3.w,
            child: Container(
              height: tabBarHeight,
              padding: EdgeInsets.symmetric(
                horizontal: 1.0.w,
                vertical: tabBarVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.cardColor.withValues(alpha: .92)
                    : AppColors.white.withValues(alpha: .94),
                borderRadius: BorderRadius.circular(14.px),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: .08)
                      : Colors.black.withValues(alpha: .08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .10),
                    offset: const Offset(0, 3),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabAlignment: TabAlignment.fill,
                  labelPadding: EdgeInsets.zero,
                  isScrollable: false,
                  dividerHeight: 0,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ConstantColor.primaryColor,
                        ConstantColor.primaryColor.withValues(alpha: .85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.px),
                    boxShadow: [
                      BoxShadow(
                        color:
                            ConstantColor.primaryColor.withValues(alpha: .30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelStyle: AppStyles.statusTitle(context).copyWith(
                    fontSize: tabTextSize,
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: AppStyles.statusTitle(context).copyWith(
                    fontSize: tabTextSize,
                    color: isDark ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    buildCompactTab(Icons.location_on_outlined, l10n.liveTab),
                    buildCompactTab(Icons.bar_chart, l10n.analyticsTab),
                    buildCompactTab(Icons.description_outlined, l10n.reportTab),
                    buildCompactTab(Icons.access_time, l10n.historyTab),
                    buildCompactTab(Icons.notifications_none, l10n.alertsTabLong),
                    buildCompactTab(Icons.info_outline_rounded, l10n.infoTab),
                  ],
                ),
              ),
            ),
          ),
          if (widget.isExpired) ...[
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.2.h),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16.px),
                      border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.35),
                        width: 1.1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.purple,
                          size: 24.sp,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          l10n.vehiclePlanExpired,
                          textAlign: TextAlign.center,
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: .8.h),
                        Text(
                          l10n.vehiclePlanExpiredMessage,
                          textAlign: TextAlign.center,
                          style: AppStyles.regularTextStyle(context).copyWith(
                            fontSize: 13.2.sp,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.75),
                          ),
                        ),
                        SizedBox(height: 1.8.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ConstantColor.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.px),
                              ),
                            ),
                            child: Text(
                              l10n.close,
                              style:
                                  AppStyles.semiboldTextStyle(context).copyWith(
                                fontSize: 13.5.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
