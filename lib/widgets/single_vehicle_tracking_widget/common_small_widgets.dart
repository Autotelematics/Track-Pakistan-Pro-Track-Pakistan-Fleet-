import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/app/theme/popups.dart';
import 'package:trackerapp/data/models/get_device_live_tracking_model.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class MovingChip extends StatelessWidget {
  final String text;
  final Color? color;
  const MovingChip({
    super.key,
    this.text = "Moving",
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMoving = text.toLowerCase() == "moving" ||
        text == context.l10n.moving;
    final statusColor = color ?? (isMoving ? AppColors.green : AppColors.red);
    final bg = isDark ? Colors.grey.shade900.withValues(alpha: .85) : AppColors.white;
    final textColor = isDark ? AppColors.white : AppColors.textBlack;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .55.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bg,
            isDark
                ? Colors.grey.shade800.withValues(alpha: .75)
                : Colors.grey.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.px),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: .8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .22 : .08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(.55.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_upward_rounded,
                size: 1.58.h, color: statusColor),
          ),
          horizontalSpace(width: 1.8.w),
          Text(
            text,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 14.4.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const InfoTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tileColor = isDark ? Colors.grey.shade900 : Colors.white;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final shadowColor = isDark ? Colors.black45 : Colors.grey.shade200;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 2.6.h,
            color: isDark ? Colors.white : Colors.blue.shade700,
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          verticalSpace(height: 0.4.h),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleBasicInfo extends StatefulWidget {
  final String deviceName;
  final String? licensePlate;
  final String deviceAddress;
  final String deviceLatestUpdate;
  final int deviceSpeed;
  final List<Sensor>? sensors;
  final double fallbackOdometer;

  const VehicleBasicInfo({
    super.key,
    required this.deviceName,
    this.licensePlate,
    required this.deviceSpeed,
    required this.deviceLatestUpdate,
    required this.deviceAddress,
    this.sensors,
    required this.fallbackOdometer,
  });

  @override
  State<VehicleBasicInfo> createState() => _VehicleBasicInfoState();
}

class _VehicleBasicInfoState extends State<VehicleBasicInfo>
    with TickerProviderStateMixin {
  late final AnimationController _speedController;
  late final AnimationController _liveController;
  Animation<double>? _speedAnimation;

  double _animatedSpeed = 0;
  double _targetSpeed = 0;

  static const double _maxGaugeSpeed = 180;

  @override
  void initState() {
    super.initState();
    _targetSpeed = _clampSpeed(widget.deviceSpeed.toDouble());
    _animatedSpeed = _targetSpeed;

    _speedController = AnimationController(vsync: this)
      ..addListener(() {
        final animation = _speedAnimation;
        if (animation == null) return;
        setState(() {
          _animatedSpeed = animation.value;
        });
      });

    _liveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )
      ..addListener(() {
        setState(() {});
      })
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant VehicleBasicInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceSpeed == widget.deviceSpeed) return;
    _animateToSpeed(_clampSpeed(widget.deviceSpeed.toDouble()));
  }

  @override
  void dispose() {
    _speedController.dispose();
    _liveController.dispose();
    super.dispose();
  }

  double _clampSpeed(double value) => value.clamp(0, _maxGaugeSpeed).toDouble();

  Color _speedBandColor(double speed) {
    if (speed < 60) return Colors.green;
    if (speed < 110) return Colors.orange;
    return Colors.red;
  }

  void _animateToSpeed(double newTarget) {
    _targetSpeed = newTarget;
    final start = _animatedSpeed;
    final delta = (newTarget - start).abs();
    final durationMs = (380 + (delta * 13)).clamp(450, 1800).round();

    _speedAnimation = Tween<double>(
      begin: start,
      end: newTarget,
    ).animate(
      CurvedAnimation(
        parent: _speedController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _speedController.duration = Duration(milliseconds: durationMs);
    _speedController.forward(from: 0);
  }

  double _liveNeedleValue() {
    final isTransitioning = _speedController.isAnimating;
    final baseAmplitude =
        isTransitioning ? 0.18 : (_targetSpeed < 2 ? 0.1 : 0.55);
    final oscillation = math.sin(_liveController.value * math.pi * 2);
    final liveOffset = oscillation * baseAmplitude;
    return _clampSpeed(_animatedSpeed + liveOffset);
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(raw);
    if (match == null) return null;
    return double.tryParse(match.group(0)!);
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  bool _isVirtualOdometerName(String? name) {
    if (name == null || name.trim().isEmpty) return false;
    final normalized = _normalize(name);
    if (normalized == 'virtualodometer') return true;
    return normalized.contains('virtual') &&
        (normalized.contains('odometer') || normalized.contains('odomet'));
  }

  double? _resolveBatteryPercent() {
    final sensors = widget.sensors ?? const <Sensor>[];
    for (final sensor in sensors) {
      if ((sensor.type ?? '').toLowerCase() != 'battery') continue;
      final fromVal = _toDouble(sensor.val);
      if (fromVal != null) return fromVal.clamp(0, 100).toDouble();
      final fromValue = _toDouble(sensor.value);
      if (fromValue != null) return fromValue.clamp(0, 100).toDouble();
      return null;
    }
    return null;
  }

  IconData _batteryIcon(double percent) {
    if (percent <= 5) return Icons.battery_0_bar;
    if (percent <= 18) return Icons.battery_1_bar;
    if (percent <= 34) return Icons.battery_2_bar;
    if (percent <= 50) return Icons.battery_3_bar;
    if (percent <= 66) return Icons.battery_4_bar;
    if (percent <= 82) return Icons.battery_5_bar;
    return Icons.battery_full;
  }

  Sensor? _sensorByType(String type) {
    final sensors = widget.sensors ?? const <Sensor>[];
    for (final sensor in sensors) {
      if ((sensor.type ?? '').toLowerCase() == type.toLowerCase()) {
        return sensor;
      }
    }
    return null;
  }

  Sensor? _sensorByTypes(List<String> types) {
    final sensors = widget.sensors ?? const <Sensor>[];
    final normalizedTypes = types.map((e) => e.toLowerCase()).toSet();
    for (final sensor in sensors) {
      if (normalizedTypes.contains((sensor.type ?? '').toLowerCase())) {
        return sensor;
      }
    }
    return null;
  }

  bool _hasSensorType(String type) => _sensorByType(type) != null;

  Widget _withMissingCross({
    required Widget child,
    required bool showCross,
  }) {
    if (!showCross) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -0.55.h,
          right: -1.0.w,
          child: Icon(
            Icons.close_rounded,
            size: 1.35.h,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  int? _resolveGsmBars() {
    final gsm = _sensorByType('gsm');
    if (gsm == null) return null;
    if (gsm.scaleValue != null) {
      return gsm.scaleValue!.clamp(0, 5);
    }
    final numeric = _toDouble(gsm.val) ?? _toDouble(gsm.value);
    if (numeric == null) return null;
    if (numeric <= 0) return 0;
    if (numeric <= 20) return 1;
    if (numeric <= 40) return 2;
    if (numeric <= 60) return 3;
    if (numeric <= 80) return 4;
    return 5;
  }

  Widget _buildGsmBars({
    required int? bars,
    required Color color,
    required bool isDark,
  }) {
    final level = (bars ?? 0).clamp(0, 5);
    final litBars = level <= 0
        ? 0
        : level <= 2
            ? 1
            : level == 3
                ? 2
                : level == 4
                    ? 3
                    : 4;
    final inactiveColor = isDark ? Colors.white24 : Colors.black26;
    const heights = [0.35, 0.55, 0.75, 1.0];

    return SizedBox(
      width: 5.2.w,
      height: 1.6.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (index) {
          return Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: .12.w),
                height: (1.95.h) * heights[index],
                decoration: BoxDecoration(
                  color: index < litBars ? color : inactiveColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  int? _resolveGpsSatellites() {
    final gps = _sensorByType('satellites');
    if (gps == null) return null;
    final numeric = _toDouble(gps.val) ?? _toDouble(gps.value);
    if (numeric == null) return null;
    return numeric.round();
  }

  bool? _resolveIgnitionOn() {
    final ignition = _sensorByTypes(const ['acc', 'ignition']);
    if (ignition == null) return null;

    final rawVal = ignition.val;
    if (rawVal is bool) return rawVal;
    if (rawVal is num) return rawVal > 0;
    final text = (rawVal ?? ignition.value)?.toString().trim().toLowerCase();
    if (text == null || text.isEmpty) return null;
    if (text == 'on' || text == 'true' || text == '1') return true;
    if (text == 'off' || text == 'false' || text == '0') return false;
    return null;
  }

  double _resolveVehicleOdometer() {
    final sensors = widget.sensors ?? const <Sensor>[];
    for (final sensor in sensors) {
      if ((sensor.type ?? '').toLowerCase() != 'odometer') continue;
      if (!_isVirtualOdometerName(sensor.name)) continue;
      final fromVal = _toDouble(sensor.val);
      if (fromVal != null) return fromVal;
    }
    return widget.fallbackOdometer;
  }

  Widget _buildOdometerSlots(BuildContext context, double value, bool isDark) {
    final wholePart = value.floor().toString().padLeft(8, '0');
    final digits = <String>[...wholePart.split('')];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: .38.w, vertical: .22.h),
      decoration: BoxDecoration(
        color: const Color.fromARGB(54, 2, 2, 2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDark ? Colors.white24 : const Color.fromARGB(80, 0, 0, 0),
          width: .9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(digits.length, (index) {
          return Container(
            width: 2.75.w,
            height: 2.1.h,
            margin: EdgeInsets.symmetric(horizontal: .16.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [Color(0xFF3B3B3B), Color(0xFF090909)],
              ),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: const Color(0xFF141414),
                width: .5,
              ),
            ),
            child: Text(
              digits[index],
              style: AppStyles.boldTextStyle(context).copyWith(
                fontSize: 12.8.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gaugeBg = isDark ? theme.cardColor : AppColors.white;
    final secondaryText = isDark ? Colors.white70 : Colors.black54;
    final softIcon = isDark ? Colors.white70 : Colors.black54;
    final needleValue = _liveNeedleValue();
    final speedColor = _speedBandColor(_animatedSpeed);
    final displayOdometer = _resolveVehicleOdometer();
    final batteryPercent = _resolveBatteryPercent();
    final hasBatterySensor = _hasSensorType('battery');
    final hasBatteryData = batteryPercent != null;
    final batteryColor = !hasBatteryData
        ? (isDark ? Colors.white54 : Colors.grey)
        : (batteryPercent <= 20 ? Colors.red : AppColors.green);
    final batteryIcon =
        hasBatteryData ? _batteryIcon(batteryPercent) : Icons.battery_0_bar;
    final batteryText = hasBatteryData ? '${batteryPercent.round()}%' : '--';
    final gsmBars = _resolveGsmBars();
    final hasGsmSensor = _hasSensorType('gsm');
    final hasGsmData = gsmBars != null;
    final gsmColor = hasGsmData
        ? (isDark ? Colors.lightGreenAccent.shade100 : AppColors.green)
        : (isDark ? Colors.white54 : Colors.grey);
    final gpsSatellites = _resolveGpsSatellites();
    final hasGpsSensor = _hasSensorType('satellites');
    final hasGpsData = gpsSatellites != null;
    final gpsColor = hasGpsData
        ? (isDark ? Colors.lightBlueAccent.shade100 : AppColors.blueCyan)
        : (isDark ? Colors.white54 : Colors.grey);
    final ignitionOn = _resolveIgnitionOn();
    final hasIgnitionSensor = _sensorByTypes(const ['acc', 'ignition']) != null;
    final ignitionColor = ignitionOn == null
        ? (isDark ? Colors.white54 : Colors.grey)
        : (ignitionOn ? AppColors.green : Colors.red);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -10.2.h,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 49.w,
              height: 52.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, 0.7.h),
                    child: Container(
                      width: 37.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: gaugeBg,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 52.w,
                    height: 52.w,
                    child: _speedoMeter(
                      context,
                      needleValue,
                      speedColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 7.6.w,
                        height: 3.5.h,
                        child: _withMissingCross(
                          showCross: !hasBatterySensor,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.rotate(
                                angle: 1.5708,
                                child: Icon(
                                  batteryIcon,
                                  size: 3.5.h,
                                  color: batteryColor,
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(-2.2, 0.01.h),
                                child: Text(
                                  batteryText,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.semiboldTextStyle(context)
                                      .copyWith(
                                    fontSize: 10.4.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      horizontalSpace(width: 1.0.w),
                      _withMissingCross(
                        showCross: !hasGsmSensor,
                        child: _buildGsmBars(
                          bars: hasGsmData ? gsmBars : null,
                          color: gsmColor,
                          isDark: isDark,
                        ),
                      ),
                      horizontalSpace(width: 1.2.w),
                      _withMissingCross(
                        showCross: !hasGpsSensor,
                        child: Icon(
                          Icons.gps_fixed_rounded,
                          size: 1.85.h,
                          color: gpsColor,
                        ),
                      ),
                      horizontalSpace(width: .55.w),
                      Text(
                        hasGpsData ? '$gpsSatellites' : '--',
                        style: AppStyles.semiboldTextStyle(context).copyWith(
                          fontSize: 10.6.sp,
                          color: gpsColor,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      horizontalSpace(width: 1.2.w),
                      _withMissingCross(
                        showCross: !hasIgnitionSensor,
                        child: Icon(
                          Icons.power_settings_new_rounded,
                          size: 1.95.h,
                          color: ignitionColor,
                        ),
                      ),
                    ],
                  ),
                ),
                horizontalSpace(width: 1.2.w),
                _buildOdometerSlots(context, displayOdometer, isDark),
              ],
            ),
            verticalSpace(height: 0.32.h),
            Divider(
              height: 1,
              thickness: .6,
              color: secondaryText.withValues(alpha: .28),
            ),
            verticalSpace(height: .32.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 2.45.h, color: softIcon),
                horizontalSpace(width: 2.w),
                Expanded(
                  child: Text(
                    widget.deviceAddress,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.address(context).copyWith(
                      fontSize: 13.0.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      letterSpacing: 0.08,
                      color: secondaryText,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _speedoMeter(
    BuildContext context,
    double needleValue,
    Color speedColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SfRadialGauge(
      axes: [
        RadialAxis(
          minimum: 0,
          maximum: 180,
          startAngle: 180,
          endAngle: 0,
          centerY: 0.52,
          radiusFactor: 0.70,
          interval: 20,
          minorTicksPerInterval: 1,
          showFirstLabel: true,
          showLastLabel: true,
          labelOffset: 10,
          axisLabelStyle: GaugeTextStyle(
            fontSize: 10.0.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          majorTickStyle: MajorTickStyle(
            length: 0.09,
            lengthUnit: GaugeSizeUnit.factor,
            thickness: 2.0,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
          minorTickStyle: MinorTickStyle(
            length: 0.048,
            lengthUnit: GaugeSizeUnit.factor,
            thickness: 1.2,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          axisLineStyle: AxisLineStyle(
            color: isDark
                ? Colors.white.withValues(alpha: .12)
                : Colors.black.withValues(alpha: .08),
            thickness: 0.12,
            thicknessUnit: GaugeSizeUnit.factor,
            cornerStyle: CornerStyle.bothCurve,
          ),
          ranges: [
            GaugeRange(
              startValue: 0,
              endValue: 60,
              color: Colors.green.withValues(alpha: .92),
              startWidth: 0.12,
              endWidth: 0.12,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            GaugeRange(
              startValue: 60,
              endValue: 110,
              color: Colors.orange.withValues(alpha: .92),
              startWidth: 0.12,
              endWidth: 0.12,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            GaugeRange(
              startValue: 110,
              endValue: 180,
              color: Colors.red.withValues(alpha: .92),
              startWidth: 0.12,
              endWidth: 0.12,
              sizeUnit: GaugeSizeUnit.factor,
            ),
          ],
          pointers: [
            NeedlePointer(
              value: needleValue,
              needleLength: 0.53,
              needleStartWidth: 1.0,
              needleEndWidth: 3.2,
              needleColor: speedColor,
              knobStyle: KnobStyle(
                knobRadius: 0.07,
                color: isDark ? Colors.white : Colors.black87,
                borderColor: speedColor.withValues(alpha: .9),
                borderWidth: 0.025,
              ),
              tailStyle: TailStyle(
                width: 2.5,
                length: 0.16,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              enableAnimation: false,
            ),
          ],
          annotations: [
            GaugeAnnotation(
              positionFactor: 0.30,
              angle: 270,
              widget: Text(
                'km/h',
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 10.2.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black54,
                  letterSpacing: .2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BottomActions extends StatefulWidget {
  final String deviceId;
  const BottomActions({super.key, required this.deviceId});

  @override
  State<BottomActions> createState() => _BottomActionsState();
}

class _BottomActionsState extends State<BottomActions> {
  bool _isCallPressed = false;
  bool _isImmobilizerPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? theme.cardColor : AppColors.green;
    final textColor = AppColors.white;
    final canSendCommand =
        !MySharedPreferences.containKey(canSendCommandViewKey)
            ? true
            : MySharedPreferences.getBool(canSendCommandViewKey);

    return Row(
      children: [
        Expanded(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOutCubic,
            scale: _isCallPressed ? 0.97 : 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.px),
              onHighlightChanged: (isPressed) {
                if (_isCallPressed == isPressed) return;
                setState(() => _isCallPressed = isPressed);
              },
              onTap: () {
                showDriverDetailPopup(context, deviceId: widget.deviceId);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                curve: Curves.easeOutCubic,
                height: 4.35.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12.px),
                  border: Border.all(
                    color: isDark
                        ? Colors.white24
                        : AppColors.grey.withValues(alpha: .55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? .18 : .08),
                      blurRadius: _isCallPressed ? 5 : 10,
                      offset: Offset(0, _isCallPressed ? 1 : 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.call_rounded, color: textColor, size: 1.85.h),
                    SizedBox(width: .8.w),
                    Text(context.l10n.callToDriver,
                        style: AppStyles.regularTextStyle(context).copyWith(
                          color: textColor,
                          fontSize: 12.6.sp,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
        horizontalSpace(width: 3.w),
        Expanded(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOutCubic,
            scale: _isImmobilizerPressed ? 0.97 : 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onHighlightChanged: canSendCommand
                  ? (isPressed) {
                      if (_isImmobilizerPressed == isPressed) return;
                      setState(() => _isImmobilizerPressed = isPressed);
                    }
                  : null,
              onTap: () {
                if (!canSendCommand) {
                  AppSnackBar.error(
                    message: "You Dont Have Permission to use this Feature",
                  );
                  return;
                }
                showDeviceCommandsPopup(context, widget.deviceId);
              },
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 90),
                    curve: Curves.easeOutCubic,
                    height: 4.35.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: canSendCommand
                            ? [
                                ConstantColor.primaryColor,
                                ConstantColor.primaryColor.withValues(alpha: .86),
                              ]
                            : [
                                Colors.grey.shade500,
                                Colors.grey.shade600,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (canSendCommand
                                  ? ConstantColor.primaryColor
                                  : Colors.black54)
                              .withValues(alpha: .25),
                          blurRadius: _isImmobilizerPressed ? 6 : 12,
                          offset: Offset(0, _isImmobilizerPressed ? 1 : 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.electric_bolt,
                            color: AppColors.white, size: 1.9.h),
                        horizontalSpace(width: .8.w),
                        Text(context.l10n.immobilizer,
                            style:
                                AppStyles.regularTextStyle(context).copyWith(
                              color: AppColors.white,
                              fontSize: 12.6.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .2,
                            )),
                      ],
                    ),
                  ),
                  if (!canSendCommand)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 8.6.w,
                            height: 8.6.w,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: .16),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.red.withValues(alpha: .58),
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              Icons.cancel_outlined,
                              size: 1.7.h,
                              color: Colors.red.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
