import 'dart:async';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_history_model.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class TopSpeedCard extends StatefulWidget {
  final GetDashboardHistoryModel? historyData;
  const TopSpeedCard({super.key,  this.historyData});
  @override
  State<TopSpeedCard> createState() => _TopSpeedCardState();
}

class _TopSpeedCardState extends State<TopSpeedCard> {
  late List<bool> _visibleBars;

  @override
  void initState() {
    super.initState();
    _visibleBars = List.generate(
      widget.historyData?.summary.topSpeeds.length ?? 0,  // ✅ Added ?
          (_) => false,
    );
    _animateBars();
  }

  void _animateBars() {
    for (int i = 0; i < (_visibleBars.length); i++) {
      Timer(Duration(milliseconds: i * 300), () {
        if (mounted) {
          setState(() => _visibleBars[i] = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (widget.historyData == null) {
      return Container(
        height: 17.h,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
        ),
      );
    }


    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final topSpeeds = widget.historyData!.summary.topSpeeds;
    if (topSpeeds.isEmpty) return const SizedBox.shrink();
    final maxSpeed = _getMaxSpeed(topSpeeds);
    final observedMaxSpeed = _getObservedMaxSpeed(topSpeeds);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.5.w),
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: isDark ? 14 : 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5.8.w,
                height: 5.8.w,
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
                  Icons.speed_rounded,
                  color: Colors.white,
                  size: 15.0.sp,
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: Text(
                  context.l10n.topSpeedingVehicles,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 12.8.sp,
                    fontWeight: FontWeight.w900,
                    color: onSurface.withValues(alpha: .92),
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(height: 1.4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 1.1.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: onSurface.withValues(alpha: 0.08)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.02),
                        Colors.white.withValues(alpha: 0.01),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.grey.shade50,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: List.generate(
                topSpeeds.length.clamp(0, 5),
                (i) => _speedRow(
                  context,
                  topSpeeds[i],
                  i,
                  maxSpeed,
                  observedMaxSpeed,
                  onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _speedRow(
    BuildContext context,
    dynamic item,
    int index,
    int maxSpeed,
    double observedMaxSpeed,
    Color onSurface,
  ) {
    final gradients = [
      [const Color(0xFF3B82F6), const Color(0xFF22D3EE)],
      [const Color(0xFF6366F1), const Color(0xFFA78BFA)],
      [const Color(0xFF10B981), const Color(0xFF34D399)],
      [const Color(0xFFF59E0B), const Color(0xFFF97316)],
      [const Color(0xFFEF4444), const Color(0xFFFB7185)],
    ];
    final speed = (item.topSpeedKph as num?)?.toDouble() ?? 0.0;
    final isHighest = (speed - observedMaxSpeed).abs() < 0.001;
    final gradient = isHighest
        ? [const Color(0xFFDC2626), const Color(0xFFF87171)]
        : gradients[index % gradients.length];
    double percent = speed / maxSpeed;
    percent = percent.clamp(0.08, 1.0);

    final rankText = '#${index + 1}';
    final deviceName = item.deviceName ?? context.l10n.vehicleFallback;

    return Container(
      margin: EdgeInsets.only(bottom: 1.15.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 2.5.h,
                width: 2.5.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gradient.first.withValues(alpha: 0.14),
                  border:
                      Border.all(color: gradient.first.withValues(alpha: 0.45)),
                ),
                child: Text(
                  rankText,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 11.sp,
                    color: gradient.first,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  _shortName(deviceName),
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: isHighest
                      ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                      : onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHighest
                        ? const Color(0xFFDC2626).withValues(alpha: 0.35)
                        : onSurface.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  '${speed.toStringAsFixed(0)} km/h',
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 11.5.sp,
                    color: isHighest ? const Color(0xFFB91C1C) : null,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(height: 0.7.h),
          LayoutBuilder(
            builder: (context, constraints) {
              // Prevent RangeError when index is out of range
              final bool isVisible =
                  index >= 0 &&
                      index < _visibleBars.length &&
                      _visibleBars[index];

              // Ensure gradient always has at least 2 colors
              final List<Color> safeGradient =
              gradient.length >= 2
                  ? gradient
                  : [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ];

              return Stack(
                children: [
                  Container(
                    height: 1.45.h,
                    decoration: BoxDecoration(
                      color: onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    height: 1.45.h,
                    width: isVisible
                        ? constraints.maxWidth * percent.clamp(0.0, 1.0)
                        : 0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: safeGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: safeGradient.last.withValues(alpha: 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  int _getMaxSpeed(List<dynamic> speeds) {
    if (speeds.isEmpty) return 200;
    final max = speeds
        .map((e) => (e.topSpeedKph as num?)?.toDouble() ?? 0.0)
        .reduce((a, b) => a > b ? a : b);
    if (max <= 0) return 200;
    return (max * 1.15).ceil();
  }

  double _getObservedMaxSpeed(List<dynamic> speeds) {
    if (speeds.isEmpty) return 0;
    return speeds
        .map((e) => (e.topSpeedKph as num?)?.toDouble() ?? 0.0)
        .reduce((a, b) => a > b ? a : b);
  }

  String _shortName(String name) =>
      name.length <= 18 ? name : "${name.substring(0, 18)}...";
}
