import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:trackerapp/data/models/get_device_reports_model.dart';
import 'package:trackerapp/data/models/get_reports_model.dart';
import 'package:trackerapp/data/models/initial_reports.dart';
import 'package:trackerapp/data/repositories/get_vehicle_reports_repository.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class ReportTypeProvider extends ChangeNotifier {
  final ReportTypeRepository _repository = ReportTypeRepository();
  bool _isDisposed = false;

  String _cleanErrorText(Object e) {
    final text = e.toString().trim();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length).trim();
    }
    return text;
  }

  /// Report types state
  bool isLoading = false;
  String? errorMessage;
  ReportTypeModel? reportTypeModel;

  List<ReportTypeItem> itemsMain = [];
  List<ReportTypeItem> itemsOther = [];

  bool isGeneratingReport = false;
  String? generateReportError;
  GetReportModel? generatedReport;

  final List<int> prioritizedReportTypes = [
    1,
    3,
    34,
    7,
    25,
    43,
    48,
    8,
  ];
  final List<int> excludedReportTypes = [
    63,
    57,
    54,
    55,
    46,
    32,
    44,
    28,
    19,
    62
  ];

  Future<void> fetchReportsType() async {
    isLoading = true;
    errorMessage = null;
    _notifySafely();

    try {
      final String apiHash = MySharedPreferences.getString(authTokenKey);

      if (apiHash.isEmpty) {
        errorMessage = "User API key is missing";
        isLoading = false;
        _notifySafely();
        return;
      }

      reportTypeModel =
          await _repository.fetchReportTypes(userApiHashKey: apiHash);

      final List<ReportTypeItem> allItems = reportTypeModel?.items ?? [];

      itemsMain = allItems
          .where((item) => prioritizedReportTypes.contains(item.type))
          .toList()
        ..sort(
          (a, b) => prioritizedReportTypes.indexOf(a.type!).compareTo(
                prioritizedReportTypes.indexOf(b.type!),
              ),
        );

      itemsOther = allItems
          .where((item) =>
              !prioritizedReportTypes.contains(item.type) &&
              !excludedReportTypes.contains(item.type))
          .toList();

      isLoading = false;
      _notifySafely();
    } catch (e) {
      errorMessage = "Failed to load report types: ${_cleanErrorText(e)}";
      isLoading = false;
      _notifySafely();
    }
  }

  Future<GetReportModel?> generateReport(ViewReportInitialData data) async {
    isGeneratingReport = true;
    generateReportError = null;
    generatedReport = null;
    _notifySafely();

    try {
      final String apiHash = MySharedPreferences.getString(authTokenKey);

      if (apiHash.isEmpty) {
        generateReportError = "User API key is missing";
        isGeneratingReport = false;
        _notifySafely();
        return null;
      }

      generatedReport = await _repository.generateReport(
        userApiHashKey: apiHash,
        dateFrom: data.fromDate,
        dateTo: data.toDate,
        deviceId: data.deviceId,
        format: data.reportFormat,
        reportType: data.reportType,
        fromTime: data.fromTime,
        toTime: data.toTime,
        speedLimit: data.speedLimit,
        geofenceIds: data.geofences,
        minutes: data.ignitionOff,
        stops: data.stops,
        showAddresses: data.showAddresses,
        zonesInstead: data.zonesInstead,
      );

      if (generatedReport == null || !generatedReport!.isSuccess) {
        generateReportError = generatedReport?.bestErrorMessage ??
            "Failed to generate report";
        isGeneratingReport = false;
        _notifySafely();
        return null;
      }

      isGeneratingReport = false;
      _notifySafely();
      return generatedReport;
    } catch (e) {
      generateReportError = _cleanErrorText(e);
      isGeneratingReport = false;
      _notifySafely();
      return null;
    }
  }

  void retry() => fetchReportsType();

  /// Clear all data
  void clear() {
    reportTypeModel = null;
    itemsMain.clear();
    itemsOther.clear();
    errorMessage = null;
    generatedReport = null;
    generateReportError = null;
    _notifySafely();
  }

  /// Clear only report generation data
  void clearGeneratedReport() {
    generatedReport = null;
    generateReportError = null;
    isGeneratingReport = false;
    _notifySafely();
  }

  void _notifySafely() {
    if (_isDisposed) return;
    final binding = WidgetsBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) {
        if (_isDisposed) return;
        notifyListeners();
      });
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
