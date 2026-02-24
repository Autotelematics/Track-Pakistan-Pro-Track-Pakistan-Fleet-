import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/get_device_reports_model.dart';
import 'package:trackerapp/data/models/get_reports_model.dart';
import 'package:trackerapp/data/models/initial_reports.dart';
import 'package:trackerapp/data/repositories/get_vehicle_reports_repository.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class ReportTypeProvider extends ChangeNotifier {
  final ReportTypeRepository _repository = ReportTypeRepository();

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
    63, 57, 54, 55, 46, 32, 44, 28, 19, 62
  ];

  Future<void> fetchReportsType() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final String apiHash = MySharedPreferences.getString(authTokenKey);

      if (apiHash.isEmpty) {
        errorMessage = "User API key is missing";
        isLoading = false;
        notifyListeners();
        return;
      }

      reportTypeModel =
      await _repository.fetchReportTypes(userApiHashKey: apiHash);

      final List<ReportTypeItem> allItems =
          reportTypeModel?.items ?? [];

      itemsMain = allItems
          .where((item) =>
          prioritizedReportTypes.contains(item.type))
          .toList()
        ..sort(
              (a, b) => prioritizedReportTypes
              .indexOf(a.type!)
              .compareTo(
            prioritizedReportTypes.indexOf(b.type!),
          ),
        );

      itemsOther = allItems
          .where((item) =>
      !prioritizedReportTypes.contains(item.type) &&
          !excludedReportTypes.contains(item.type))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = "Failed to load report types: $e";
      isLoading = false;
      notifyListeners();
    }
  }

  Future<GetReportModel?> generateReport(
      ViewReportInitialData data) async {
    isGeneratingReport = true;
    generateReportError = null;
    generatedReport = null;
    notifyListeners();

    try {
      final String apiHash =
      MySharedPreferences.getString(authTokenKey);

      if (apiHash.isEmpty) {
        generateReportError = "User API key is missing";
        isGeneratingReport = false;
        notifyListeners();
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
      );

      isGeneratingReport = false;
      notifyListeners();
      return generatedReport;
    } catch (e) {
      generateReportError = "Failed to generate report: $e";
      isGeneratingReport = false;
      notifyListeners();
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
    notifyListeners();
  }

  /// Clear only report generation data
  void clearGeneratedReport() {
    generatedReport = null;
    generateReportError = null;
    isGeneratingReport = false;
    notifyListeners();
  }
}
