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
    final isCompactPhone = MediaQuery.sizeOf(context).width <= 360;
    final alertsProvider = context.watch<AlertsProvider>();
    final alertTypeCounts = alertsProvider.alertTypeCounts;
    final dynamicAlerts = alertTypeCounts.entries
        .where(
      (e) => !_isAllType(e.key) && !_isCustomType(e.key),
    )
        .map((entry) {
      final rawType = entry.key;
      return {
        'icon': _iconForType(rawType),
        'name': _displayNameForType(rawType),
        'alertType': rawType,
        'unit': 'Times',
        'value': entry.value.toString(),
        'bgColor': _colorForType(rawType),
        'isCritical': _isCriticalType(rawType),
      };
    }).toList(growable: false);

    final fallbackAlerts = [
      {
        'icon': Icons.speed,
        'name': 'Over Speed',
        'alertType': 'Over Speed',
        'unit': 'Times',
        'value': data.alertsSummary.overSpeed.toString(),
        'bgColor': const Color(0xFFFFC107),
        'isCritical': true,
      },
      {
        'icon': Icons.timer_outlined,
        'name': 'Idle Duration',
        'alertType': 'Idle Duration',
        'unit': 'Times',
        'value': data.alertsSummary.idleDuration.toString(),
        'bgColor': const Color(0xFFFF9800),
        'isCritical': false,
      },
      {
        'icon': Icons.power_settings_new,
        'name': 'Ignition duration',
        'alertType': 'Ignition duration',
        'unit': 'Times',
        'value': data.alertsSummary.ignitionDuration.toString(),
        'bgColor': const Color(0xFFEF5350),
        'isCritical': false,
      },
      {
        'icon': Icons.directions_car,
        'name': 'Move Start',
        'alertType': 'Move Start',
        'unit': 'Times',
        'value': data.alertsSummary.moveStart.toString(),
        'bgColor': const Color(0xFF4CAF50),
        'isCritical': false,
      },
      {
        'icon': Icons.signal_wifi_off,
        'name': 'Offline duration',
        'alertType': 'Offline duration',
        'unit': 'Times',
        'value': data.alertsSummary.offlineDuration.toString(),
        'bgColor': const Color(0xFF009688),
        'isCritical': false,
      },
      {
        'icon': Icons.local_parking,
        'name': 'Over Parking',
        'alertType': 'Over Parking',
        'unit': 'Times',
        'value': data.alertsSummary.overParking.toString(),
        'bgColor': const Color(0xFF6A1B9A),
        'isCritical': true,
      },
      {
        'icon': Icons.login_rounded,
        'name': 'Zone in',
        'alertType': 'Zone in',
        'unit': 'Times',
        'value': data.alertsSummary.zoneIn.toString(),
        'bgColor': const Color(0xFF0EA5E9),
        'isCritical': false,
      },
      {
        'icon': Icons.logout_rounded,
        'name': 'Zone out',
        'alertType': 'Zone out',
        'unit': 'Times',
        'value': data.alertsSummary.zoneOut.toString(),
        'bgColor': const Color(0xFF2563EB),
        'isCritical': false,
      },
    ];
    final alerts = dynamicAlerts.isNotEmpty ? dynamicAlerts : fallbackAlerts;
    final totalCount = data.alertsSummary.total;

    if (dynamicAlerts.isEmpty &&
        alertsProvider.model == null &&
        !alertsProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final provider = context.read<AlertsProvider>();
        if (provider.model == null && !provider.isLoading) {
          provider.fetchAlerts(isRefresh: true, context: context);
        }
      });
    }

    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: _aW(context, phone: 5, compact: 4)),
      padding: EdgeInsets.symmetric(
        horizontal: _aW(context, phone: 3.5, compact: 3.0),
        vertical: _aH(context, phone: 1.2, compact: 1.05),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[
                  cardColor.withValues(alpha: .98),
                  cardColor.withValues(alpha: .92),
                ]
              : <Color>[
                  Colors.white,
                  const Color(0xFFF6FBFF),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withValues(alpha: isDark ? .24 : .14),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : const Color(0xFF0284C7).withValues(alpha: 0.10),
            blurRadius: isDark ? 16 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _alertFilterRow(context, totalCount, isDark),
          verticalSpace(height: .7.h),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isCompactPhone ? 2 : 3,
              crossAxisSpacing: 2.2.w,
              mainAxisSpacing: .9.h,
              childAspectRatio: isCompactPhone ? 1.33 : 1.22,
            ),
            itemBuilder: (context, index) {
              final item = alerts[index];
              return _AlertTile(
                index: index,
                item: item,
                cardColor: cardColor,
                onSurface: onSurface,
                isDark: isDark,
                onTap: () => _openAlertsByType(
                  context,
                  item['alertType'] as String,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _alertFilterRow(BuildContext context, int totalCount, bool isDark) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Container(
          width: _aW(context, phone: 5.8, compact: 6.6),
          height: _aW(context, phone: 5.8, compact: 6.6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xFF22D3EE),
                Color(0xFF0284C7),
              ],
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            Icons.notification_important_rounded,
            color: Colors.white,
            size: _aSp(context, phone: 15.0),
          ),
        ),
        horizontalSpace(width: 2.w),
        Expanded(
          child: Text(
            context.l10n.alertsCount,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: _aSp(context, phone: 12.8),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => _openAllAlerts(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _aW(context, phone: 2.2, compact: 2.0),
              vertical: _aH(context, phone: .35, compact: .3),
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: .08)
                  : const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: .18)
                    : const Color(0xFF7DD3FC),
              ),
            ),
            child: Text(
              context.l10n.totalLabel(totalCount),
              style: AppStyles.semiboldTextStyle(context).copyWith(
                fontSize: _aSp(context, phone: 12.0),
                color: isDark
                    ? onSurface.withValues(alpha: .9)
                    : const Color(0xFF075985),
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

  static bool _isAllType(String type) => type.trim().toLowerCase() == 'all';

  static bool _isCustomType(String type) {
    final t = _normalized(type);
    return t == 'custom' || t.contains('customalert');
  }

  static String _normalized(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static String _displayNameForType(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return raw;
    final withSpaces = text
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');
    return withSpaces
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static bool _isCriticalType(String rawType) {
    final type = _normalized(rawType);
    return type.contains('overspeed') ||
        type.contains('overparking') ||
        type.contains('panic') ||
        type.contains('sos');
  }

  static IconData _iconForType(String rawType) {
    final type = _normalized(rawType);
    if (type.contains('overspeed')) return Icons.speed;
    if (type.contains('idle')) return Icons.timer_outlined;
    if (type.contains('ignition')) return Icons.power_settings_new;
    if (type.contains('movestart') || type.contains('move')) {
      return Icons.directions_car;
    }
    if (type.contains('offline')) return Icons.signal_wifi_off;
    if (type.contains('overparking') || type.contains('parking')) {
      return Icons.local_parking;
    }
    if (type.contains('zonein') || type.contains('geofencein')) {
      return Icons.login_rounded;
    }
    if (type.contains('zoneout') || type.contains('geofenceout')) {
      return Icons.logout_rounded;
    }
    if (type.contains('sos') || type.contains('panic')) {
      return Icons.warning_amber_rounded;
    }
    if (type.contains('battery')) return Icons.battery_alert_rounded;
    return Icons.notifications_active_rounded;
  }

  static Color _colorForType(String rawType) {
    final type = _normalized(rawType);
    if (type.contains('overspeed')) return const Color(0xFFFFC107);
    if (type.contains('idle')) return const Color(0xFFFF9800);
    if (type.contains('ignition')) return const Color(0xFFEF5350);
    if (type.contains('movestart') || type.contains('move')) {
      return const Color(0xFF4CAF50);
    }
    if (type.contains('offline')) return const Color(0xFF009688);
    if (type.contains('overparking') || type.contains('parking')) {
      return const Color(0xFF6A1B9A);
    }
    if (type.contains('zonein') || type.contains('geofencein')) {
      return const Color(0xFF0EA5E9);
    }
    if (type.contains('zoneout') || type.contains('geofenceout')) {
      return const Color(0xFF2563EB);
    }
    if (type.contains('sos') || type.contains('panic')) {
      return const Color(0xFFE53935);
    }
    if (type.contains('battery')) return const Color(0xFF22C55E);
    return const Color(0xFF3B82F6);
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
                  vertical: _aH(context, phone: .72, compact: .65),
                  horizontal: _aW(context, phone: 2.3, compact: 2.1),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.px),
                  border: Border.all(
                      color: widget.onSurface.withValues(alpha: 0.10)),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isDark
                          ? Colors.black
                              .withValues(alpha: _pressed ? 0.18 : 0.30)
                          : Colors.black
                              .withValues(alpha: _pressed ? 0.025 : 0.05),
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
                        size: _aH(context, phone: 4.8, compact: 4.4),
                        color: bgColor.withValues(alpha: 0.22),
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
                                textAlign: TextAlign.left,
                                style: AppStyles.regularTextStyle(context)
                                    .copyWith(
                                  fontSize: _aSp(context, phone: 13.0),
                                  fontWeight: FontWeight.w700,
                                ),
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
                                  fontSize: _aSp(context, phone: 13.2),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: '  ${widget.item['unit']}',
                                style: AppStyles.regularTextStyle(context)
                                    .copyWith(
                                        fontSize: _aSp(context, phone: 12.6)),
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

double _aSp(
  BuildContext context, {
  required double phone,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360) return (phone * 1.08).sp;
  if (width <= 393) return (phone * 1.10).sp;
  if (width <= 430) return (phone * 1.06).sp;
  return (phone * 1.03).sp;
}

double _aW(
  BuildContext context, {
  required double phone,
  double? compact,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360 && compact != null) return compact.w;
  return phone.w;
}

double _aH(
  BuildContext context, {
  required double phone,
  double? compact,
  double min = 0,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final value = (width <= 360 && compact != null ? compact : phone).h;
  if (min <= 0) return value;
  return value < min ? min : value;
}
