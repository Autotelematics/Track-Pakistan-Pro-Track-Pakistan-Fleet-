class VehiclePerformanceKpi {
  final int deviceId;
  final String deviceName;
  final int idleAlertCount;
  final int idleDurationSeconds;
  final int overSpeedAlertCount;
  final int overSpeedDurationSeconds;
  final double score;

  const VehiclePerformanceKpi({
    required this.deviceId,
    required this.deviceName,
    required this.idleAlertCount,
    required this.idleDurationSeconds,
    required this.overSpeedAlertCount,
    required this.overSpeedDurationSeconds,
    required this.score,
  });
}

class DriverPerformanceKpi {
  final int driverId;
  final String driverName;
  final String? deviceId;
  final String? vehicleName;
  final int idleAlertCount;
  final int idleDurationSeconds;
  final int overSpeedAlertCount;
  final int overSpeedDurationSeconds;
  final double score;

  const DriverPerformanceKpi({
    required this.driverId,
    required this.driverName,
    required this.deviceId,
    required this.vehicleName,
    required this.idleAlertCount,
    required this.idleDurationSeconds,
    required this.overSpeedAlertCount,
    required this.overSpeedDurationSeconds,
    required this.score,
  });
}
