import 'package:flutter/material.dart';

class AlertSettingsProvider extends ChangeNotifier {

  // toggles
  bool excessParking = false;
  bool offlineDuration = false;
  bool ignitionOn = false;
  bool ignitionOff = false;
  bool fenceExit = false;
  bool overspeed = false;
  bool stopDuration = false;
  bool powerDisconnected = false;
  bool idleDuration = false;

  double overspeedLimit = 0;

  void toggle(String key) {
    switch (key) {
      case "excessParking": excessParking = !excessParking; break;
      case "offlineDuration": offlineDuration = !offlineDuration; break;
      case "ignitionOn": ignitionOn = !ignitionOn; break;
      case "ignitionOff": ignitionOff = !ignitionOff; break;
      case "fenceExit": fenceExit = !fenceExit; break;
      case "overspeed": overspeed = !overspeed; break;
      case "stopDuration": stopDuration = !stopDuration; break;
      case "powerDisconnected": powerDisconnected = !powerDisconnected; break;
      case "idleDuration": idleDuration = !idleDuration; break;
    }
    notifyListeners();
  }

  void updateOverspeed(double v) {
    overspeedLimit = v;
    notifyListeners();
  }
}
