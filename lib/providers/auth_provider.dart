import 'package:flutter/cupertino.dart';

class AuthProvider extends ChangeNotifier{
  bool isObSecure=true;
  void toggleObSecure(){
    isObSecure=!isObSecure;
    notifyListeners();
  }
}