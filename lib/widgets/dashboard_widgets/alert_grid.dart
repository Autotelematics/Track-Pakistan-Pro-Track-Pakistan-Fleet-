import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/providers/alerts_provider.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class AlertGrid extends StatelessWidget {
  final GetDashboardModel data;

  const AlertGrid({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final alerts = [
      {
        'icon': Icons.speed,
        'name': 'Over Speed',
        'unit': 'Times',
        'value': data.alertsSummary.overSpeed.toString(),
        'bgColor': const Color(0xFFFFC107),
        'isCritical': true,
      },
      {
        'icon': Icons.timer_outlined,
        'name': 'Idle Duration',
        'unit': 'Times',
        'value': data.alertsSummary.idleDuration.toString(),
        'bgColor': const Color(0xFFFF9800),
        'isCritical': false,
      },
      {
        'icon': Icons.power_settings_new,
        'name': 'Ignition duration',
        'unit': 'Times',
        'value': data.alertsSummary.ignitionDuration.toString(),
        'bgColor': const Color(0xFFEF5350),
        'isCritical': false,
      },
      {
        'icon': Icons.directions_car,
        'name': 'Move Start',
        'unit': 'Times',
        'value': data.alertsSummary.moveStart.toString(),
        'bgColor': const Color(0xFF4CAF50),
        'isCritical': false,
      },
      {
        'icon': Icons.signal_wifi_off,
        'name': 'Offline duration',
        'unit': 'Times',
        'value': data.alertsSummary.offlineDuration.toString(),
        'bgColor': const Color(0xFF009688),
        'isCritical': false,
      },
      {
        'icon': Icons.local_parking,
        'name': 'Over Parking',
        'unit': 'Times',
        'value': data.alertsSummary.overParking.toString(),
        'bgColor': const Color(0xFF6A1B9A),
        'isCritical': true,
      },
      {
        'icon': Icons.tune_rounded,
        'name': 'Custom',
        'unit': 'Times',
        'value': data.alertsSummary.custom.toString(),
        'bgColor': const Color(0xFF2196F3),
        'isCritical': false,
      },
      {
        'icon': Icons.login_rounded,
        'name': 'Zone in',
        'unit': 'Times',
        'value': data.alertsSummary.zoneIn.toString(),
        'bgColor': const Color(0xFF0EA5E9),
        'isCritical': false,
      },
      {
        'icon': Icons.logout_rounded,
        'name': 'Zone out',
        'unit': 'Times',
        'value': data.alertsSummary.zoneOut.toString(),
        'bgColor': const Color(0xFF2563EB),
        'isCritical': false,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: isDark ? 14 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _alertFilterRow(context),
          verticalSpace(height: .7.h),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.2.w,
              mainAxisSpacing: .9.h,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final item = alerts[index];
              return _AlertTile(
                index: index,
                item: item,
                cardColor: cardColor,
                onSurface: onSurface,
                isDark: isDark,
                onTap: () => _openAlertsByType(context, item['name'] as String),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _alertFilterRow(BuildContext context) {
    return Row(
      children: [
        Text(
          context.l10n.alertsCount,
          style: AppStyles.semiboldTextStyle(context).copyWith(fontSize: 15.sp),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _openAllAlerts(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: .6.w, vertical: .2.h),
            child: Text(
              context.l10n.totalLabel(data.alertsSummary.total),
              style: AppStyles.semiboldTextStyle(context).copyWith(
                fontSize: 13.2.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openAlertsByType(BuildContext context, String alertType) {
    final alertsProvider = context.read<AlertsProvider>();
    alertsProvider.setPendingAlertTypeLabel(alertType);
    alertsProvider.setDeviceFilter(null);
    alertsProvider.setSearchQuery('');
    alertsProvider.setAlertTypeFilter(alertType);
    alertsProvider.fetchAlerts(isRefresh: true, context: context);
    context.read<MotionBottomBarProvider>().setIndex(3);
  }

  void _openAllAlerts(BuildContext context) {
    final alertsProvider = context.read<AlertsProvider>();
    alertsProvider.clearPendingAlertTypeLabel();
    alertsProvider.setDeviceFilter(null);
    alertsProvider.setAlertTypeFilter(null);
    alertsProvider.setSearchQuery('');
    alertsProvider.fetchAlerts(isRefresh: true, context: context);
    context.read<MotionBottomBarProvider>().setIndex(3);
  }
}

class _AlertTile extends StatefulWidget {
  final int index;
  final Map<String, Object> item;
  final Color cardColor;
  final Color onSurface;
  final bool isDark;
  final VoidCallback onTap;

  const _AlertTile({
    required this.index,
    required this.item,
    required this.cardColor,
    required this.onSurface,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_AlertTile> createState() => _AlertTileState();
}

class _AlertTileState extends State<_AlertTile> {
  bool _visible = false;
  bool _pressed = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 70 * widget.index), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.item['bgColor'] as Color;
    final tintStrength = widget.isDark ? 0.18 : 0.09;
    final tileColor = Color.lerp(widget.cardColor, bgColor, tintStrength)!;
    final isCritical = (widget.item['isCritical'] as bool?) ?? false;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : const Offset(0, 0.08),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        opacity: _visible ? 1 : 0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutCubic,
          scale: _pressed ? 0.965 : 1,
          child: Material(
            color: tileColor,
            borderRadius: BorderRadius.circular(16.px),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.px),
              splashColor: bgColor.withValues(alpha: 0.20),
              highlightColor: bgColor.withValues(alpha: 0.10),
              onHighlightChanged: (v) => setState(() => _pressed = v),
              onTap: () async {
                if (_isNavigating) return;
                _isNavigating = true;
                setState(() => _pressed = true);
                await Future.delayed(const Duration(milliseconds: 130));
                if (mounted) {
                  setState(() => _pressed = false);
                }
                widget.onTap();
                _isNavigating = false;
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: .75.h,
                  horizontal: 2.3.w,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.px),
                  border: Border.all(color: widget.onSurface.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isDark
                          ? Colors.black.withValues(alpha: _pressed ? 0.18 : 0.30)
                          : Colors.black.withValues(alpha: _pressed ? 0.025 : 0.05),
                      blurRadius: _pressed ? 2 : 6,
                      offset: Offset(0, _pressed ? 1 : 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      right: -5,
                      child: Icon(
                        widget.item['icon'] as IconData,
                        size: 5.2.h,
                        color: bgColor.withValues(alpha: 0.20),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item['name'] as String,
                                maxLines: 2,
                                textAlign: TextAlign.right,
                                style: AppStyles.regularTextStyle(context)
                                    .copyWith(fontSize: 12.4.sp),
                              ),
                            ),
                            if (isCritical) ...[
                              horizontalSpace(width: .6.w),
                              Container(
                                margin: EdgeInsets.only(top: .2.h),
                                height: .7.h,
                                width: .7.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDC2626)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${widget.item['value']}',
                                style: AppStyles.semiboldTextStyle(context)
                                    .copyWith(
                                  fontSize: 13.6.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: '  ${widget.item['unit']}',
                                style: AppStyles.regularTextStyle(context)
                                    .copyWith(fontSize: 10.8.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
