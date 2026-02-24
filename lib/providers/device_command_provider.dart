import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:trackerapp/data/models/get_device_commands_model.dart';
import 'package:trackerapp/data/repositories/get_device_commands_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';

class GetDeviceCommandsProvider with ChangeNotifier {
  final GetDeviceCommandsRepository deviceCommandsRepository =
      GetDeviceCommandsRepository();

  List<GetDeviceCommandsModel>? getDeviceCommands;
  bool isLoading = false;

  /// GET Device Commands
  Future<void> getDeviceCommandMethod({required String deviceId})
  async {
    isLoading = true;
    notifyListeners();
    try {
      final response =
          await deviceCommandsRepository.getDeviceCommands(deviceId: deviceId);
      if (response != null) {
        getDeviceCommands = response;
        if (kDebugMode) {
          print("Response is that :$getDeviceCommands");
        }
      } else {
        getDeviceCommands = null;
        AppSnackBar.error(message: "No Data");
      }
    } catch (e) {
      debugPrint("getDriverUser error: $e");
      AppSnackBar.error(message: "Something went wrong");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Send Device Command
  Future<void> sendDeviceCommandMethod({required String deviceId,commandType})
  async {
    isLoading = true;
    notifyListeners();
    try {
      await deviceCommandsRepository.sendDeviceCommands(deviceId: deviceId,commandType: commandType);
    } catch (e) {
      debugPrint("Send Command error: $e");
      AppSnackBar.error(message: "Something went wrong");
    }

    isLoading = false;
    notifyListeners();
  }
}
