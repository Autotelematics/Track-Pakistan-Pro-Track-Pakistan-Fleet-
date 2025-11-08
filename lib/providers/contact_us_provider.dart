import 'package:flutter/material.dart';


class ContactProvider extends ChangeNotifier {
  int selectedIndex = -1;

  void selectIndex(int i) {
    selectedIndex = i;
    notifyListeners();
  }

  void clearSelection() {
    selectedIndex = -1;
    notifyListeners();
  }
}

