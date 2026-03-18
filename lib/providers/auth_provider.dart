import 'package:flutter/material.dart';
import 'package:trackerapp/data/repositories/auth_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/motion_bottom_navigation_bar.dart';

class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();

  bool isObSecure = true;
  bool isLoading = false;

  void toggleObSecure() {
    isObSecure = !isObSecure;
    notifyListeners();
  }

  Future<void> loginProvider({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      bool success = await _repo.loginApi(email: email, password: password);
      if (success) {
        AppSnackBar.success(message: "Login Successfully");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    MotionBottomNavigationBar()));
      }
    } catch (e) {
      final message = e.toString().replaceFirst("Exception: ", "").trim();
      final isMobileAccessDenied =
          message == AuthRepository.mobileAccessDeniedMessage;
      AppSnackBar.error(
        message: message,
        duration: isMobileAccessDenied
            ? const Duration(seconds: 7)
            : const Duration(seconds: 2),
      );
    }
    isLoading = false;
    notifyListeners();
  }

  //  change password
  Future<void> changePasswordProvider({
    required BuildContext context,
    required String oldPassword,
    required String newPassword,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      String message = await _repo.changePasswordApi(
          oldPassword: oldPassword, newPassword: newPassword);
      AppSnackBar.success(message: message);
    } catch (e) {
      AppSnackBar.error(message: e.toString());
    }
    isLoading = false;
    notifyListeners();
  }
}
