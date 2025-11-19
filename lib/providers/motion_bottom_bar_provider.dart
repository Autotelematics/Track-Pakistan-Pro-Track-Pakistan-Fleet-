import 'package:flutter/cupertino.dart';

class MotionBottomBarProvider extends ChangeNotifier {
  int _currentIndex = 2;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}