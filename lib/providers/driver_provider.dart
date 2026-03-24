import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:trackerapp/data/models/get_driver_model.dart';
import 'package:trackerapp/data/repositories/driver_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';

class DriverProvider with ChangeNotifier {
  final DriverRepository driverRepository = DriverRepository();

  GetDriverModel? getDriverModel;
  Datum? currentVehicleDriver;
  bool isLoading = false;

  /// ADD DRIVER
  Future<void> addDriver({
    required String name,
    required String rfId,
    required String phone,
    required String email,
    required String deviceId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await driverRepository.addDriverMethod(
          name: name,
          rfId: rfId,
          phone: phone,
          email: email,
          deviceId: deviceId);

      AppSnackBar.success(message: "Driver Added Successfully");
    } catch (e) {
      log("Error in Provider${e.toString()}");
      AppSnackBar.error(message: e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  /// Edit Driver
  Future<void> editDriver({
    required String driverId,
    required String name,
    required String rfid,
    required String phone,
    required String email,
    required String description,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await driverRepository.editDriverInfoMethod(
          driverId: driverId,
          name: name,
          rfid: rfid,
          phone: phone,
          email: email,
          description: description);
      AppSnackBar.success(message: "Driver Updated Successfully");
    } catch (e) {
      log("Error in Provider${e.toString()}");
      AppSnackBar.error(message: e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  /// GET DRIVERS
  Future<void> getDriverUser({required String deviceId}) async {
    isLoading = true;
    notifyListeners();

    try {
      final response =
          await driverRepository.getDriverMethod(deviceId: deviceId);
      if (response != null) {
        getDriverModel = response;
        debugPrint("Response is that :${getDriverModel?.items}");
      } else {
        getDriverModel = null;
        AppSnackBar.error(message: "No Data");
      }
    } catch (e) {
      debugPrint("getDriverUser error: $e");
      AppSnackBar.error(message: "Something went wrong");
    }

    isLoading = false;
    notifyListeners();
  }

  /// GET ASSIGNED DRIVER FOR A VEHICLE
  Future<void> getVehicleDriver({required String deviceId}) async {
    isLoading = true;
    currentVehicleDriver = null;
    notifyListeners();

    try {
      final response =
          await driverRepository.getVehicleDriverMethod(deviceId: deviceId);
      currentVehicleDriver = response;
    } catch (e) {
      debugPrint("getVehicleDriver error: $e");
      AppSnackBar.error(message: "Something went wrong");
      currentVehicleDriver = null;
    }

    isLoading = false;
    notifyListeners();
  }

  ///Assign Driver
  Future<void> assignDriver({
    required String deviceId,
    String? driverId,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await driverRepository.addDeviceToDriverMethod(
          deviceId: deviceId, driverId: driverId);
      AppSnackBar.success(
          message: (driverId == null || driverId.trim().isEmpty)
              ? "Driver unassigned successfully"
              : "Driver assigned successfully");
    } catch (e) {
      log("Error in Provider${e.toString()}");
      AppSnackBar.error(message: e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
