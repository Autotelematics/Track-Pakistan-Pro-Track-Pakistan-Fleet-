class ViewReportInitialData {
  final String fromDate;
  final String toDate;
  final int deviceId;
  final String reportFormat;
  final int reportType;
  final int speedLimit;
  final List<int> geofences;
  final int ignitionOff;
  final String reportName;
  final String fromTime;
  final String toTime;

  ViewReportInitialData({
    required this.fromDate,
    required this.toDate,
    required this.deviceId,
    required this.reportFormat,
    required this.reportType,
    this.speedLimit = 0,
    this.geofences = const [],
    this.ignitionOff = 0,
    this.reportName = "",
    this.fromTime = "",
    this.toTime = "",
  });
}