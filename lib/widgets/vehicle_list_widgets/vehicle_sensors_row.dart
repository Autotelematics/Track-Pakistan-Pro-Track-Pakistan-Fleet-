import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart';

class VehicleStatusRow extends StatelessWidget {
  final Item vehicle;
  final double horizontalPadding;
  static final Map<int, String> _lastValidSatByVehicleId = {};

  const VehicleStatusRow({
    super.key,
    required this.vehicle,
    this.horizontalPadding = 3.2,
  });

  Widget _sensorItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16.0.sp),
        SizedBox(width: 0.6.w),
        Text(
          "$label:",
          style: AppStyles.regularTextStyle(context).copyWith(
            fontSize: 12.5.sp,
            color: onSurface.withValues(alpha: .62),
          ),
        ),
        SizedBox(width: 0.4.w),
        Text(
          value,
          style: AppStyles.semiboldTextStyle(context).copyWith(
            fontSize: 12.5.sp,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final param = vehicle.param;
    bool parseFlag(String? value) {
      final v = value?.trim().toLowerCase();
      return v == 'true' || v == 'on' || v == '1' || v == 'yes';
    }

    final String blocked = param?.blocked?.trim() ?? '';
    final bool immobilizer =
        blocked.isNotEmpty ? parseFlag(blocked) : parseFlag(param?.out1);
    final bool ignOn = parseFlag(param?.ignition);
    final bool chgOn = parseFlag(param?.charge);

    final int? rssiRaw = int.tryParse(param?.rssi?.trim() ?? '');
    final String rssi =
        rssiRaw == null ? 'N/A' : '${(rssiRaw.clamp(1, 5) * 20).toInt()}%';

    final int? batteryRaw = int.tryParse(param?.batterylevel?.trim() ?? '');
    final String battery =
        batteryRaw == null ? 'N/A' : '${batteryRaw.clamp(0, 100).toInt()}%';

    final String ignition = ignOn ? 'On' : 'Off';
    final String charging = chgOn ? 'On' : 'Off';
    final String rawSat = param?.sat?.trim() ?? '';
    final int? satNumber = int.tryParse(rawSat);
    final int? vehicleId = vehicle.id;
    String sat = 'N/A';

    if (satNumber != null && satNumber > 0) {
      sat = satNumber.toString();
      if (vehicleId != null) {
        _lastValidSatByVehicleId[vehicleId] = sat;
      }
    } else if (satNumber == 0) {
      final String? previousSat =
          vehicleId != null ? _lastValidSatByVehicleId[vehicleId] : null;
      sat = previousSat ?? '0';
    } else if (rawSat.isNotEmpty) {
      sat = rawSat;
    }

    final sensorItems = <Widget>[
      _sensorItem(
        context: context,
        icon: Icons.lock_outline_rounded,
        color: immobilizer ? Colors.red : Colors.green,
        label: "Imm",
        value: immobilizer ? "On" : "Off",
      ),
      _sensorItem(
        context: context,
        icon: Icons.signal_cellular_alt_rounded,
        color: Colors.orange,
        label: "RSSI",
        value: rssi,
      ),
      _sensorItem(
        context: context,
        icon: Icons.satellite_alt_rounded,
        color: Colors.blueGrey,
        label: "Sat",
        value: sat,
      ),
      _sensorItem(
        context: context,
        icon: Icons.vpn_key_rounded,
        color: ignition == 'On' ? Colors.green : Colors.red,
        label: "Ign",
        value: ignition,
      ),
      _sensorItem(
        context: context,
        icon: Icons.battery_charging_full_rounded,
        color: charging == 'On' ? Colors.green : Colors.red,
        label: "Chg",
        value: charging,
      ),
      _sensorItem(
        context: context,
        icon: Icons.sensors_rounded,
        color: Colors.green,
        label: "Bat",
        value: battery,
      ),
    ];

    Widget buildSensorRow(List<Widget> items) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: 1.6.w),
            items[i],
          ],
        ],
      );
    }

    final firstRowItems = sensorItems.take(3).toList(growable: false);
    final secondRowItems = sensorItems.skip(3).toList(growable: false);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSensorRow(firstRowItems),
          if (secondRowItems.isNotEmpty) ...[
            SizedBox(height: .45.h),
            buildSensorRow(secondRowItems),
          ],
        ],
      ),
    );
  }
}
