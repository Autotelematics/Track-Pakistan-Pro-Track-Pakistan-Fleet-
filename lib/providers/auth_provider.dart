import 'package:flutter/material.dart';
import 'package:trackerapp/data/repositories/auth_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/error_message.dart';
import 'package:trackerapp/utils/motion_bottom_navigation_bar.dart';
import 'package:trackerapp/utils/session_guard.dart';

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
      if (!context.mounted) return;
      if (success) {
        AppSnackBar.success(message: "Login Successfully");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    MotionBottomNavigationBar()));
      }
    } catch (e) {
      final message = AppErrorMessage.normalize(e);
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
    required String confirmPassword,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repo.changePasswordApi(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      await SessionGuard.forceLogout(
        message: 'Session expired. Please login again.',
      );
    } catch (e) {
      AppSnackBar.error(message: AppErrorMessage.normalize(e));
    }
    isLoading = false;
    notifyListeners();
  }
}
