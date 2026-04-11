import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/update_device_data_model.dart';
import 'package:trackerapp/data/repositories/update_device_data_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/error_message.dart';

class UpdateDeviceDataProvider extends ChangeNotifier {
  final UpdateDeviceDataRepository _repository = UpdateDeviceDataRepository();

  bool _isLoading = false;
  String? _errorMessage;
  UpdateDeviceDataModel? _updatedData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UpdateDeviceDataModel? get updatedData => _updatedData;

  Future<UpdateDeviceDataModel?> fetchCurrentDeviceData({
    required String deviceId,
    bool showErrorSnackBar = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await _repository.fetchCurrentDeviceData(deviceId: deviceId);
      _updatedData = response;
      return response;
    } catch (e) {
      _errorMessage = AppErrorMessage.normalize(e);
      if (showErrorSnackBar) {
        AppSnackBar.error(message: _errorMessage ?? "Something went wrong");
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UpdateDeviceDataModel?> updateDeviceData({
    required String deviceId,
    required String fuelQuantity,
    required String vehicleType,
    required String engineType,
    bool showSuccessSnackBar = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.updateDeviceData(
        deviceId: deviceId,
        fuelQuantity: fuelQuantity,
        vehicleType: vehicleType,
        engineType: engineType,
      );
      _updatedData = response;

      if (showSuccessSnackBar && response.message.isNotEmpty) {
        AppSnackBar.success(message: response.message);
      }

      return response;
    } catch (e) {
      _errorMessage = AppErrorMessage.normalize(e);
      AppSnackBar.error(message: _errorMessage ?? "Something went wrong");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResult() {
    _updatedData = null;
    _errorMessage = null;
    notifyListeners();
  }
}
