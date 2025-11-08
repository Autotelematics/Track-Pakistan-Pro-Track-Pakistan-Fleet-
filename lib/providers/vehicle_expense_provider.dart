import 'package:flutter/material.dart';

class VehicleExpenseProvider extends ChangeNotifier {
  VehicleExpenseProvider() {
    selectedDate = DateTime.now();
    monthTotal = 6584;
    shoppingPercent = 45;
    foodPercent = 35;
    healthPercent = 20;
  }

  DateTime selectedDate = DateTime.now();
  double monthTotal = 0;

  // percents (integers for display)
  double shoppingPercent = 0;
  double foodPercent = 0;
  double healthPercent = 0;

  // Helpers
  double get shoppingFraction => shoppingPercent / 100;
  double get foodFraction => foodPercent / 100;
  double get healthFraction => healthPercent / 100;

  String get monthLabel {
    final m = selectedDate.month;
    final y = selectedDate.year;
    // simple month name map
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[m - 1]} $y';
  }

  // Date picker (UI only) - updates selectedDate
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(selectedDate.year - 5),
      lastDate: DateTime(selectedDate.year + 5),
    );
    if (picked != null) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  // Optional: change month (left / right)
  void changeMonth(int delta) {
    selectedDate = DateTime(selectedDate.year, selectedDate.month + delta, selectedDate.day);
    notifyListeners();
  }

  // If you later want to set values from API / DB
  void setPercents({double? shopping, double? food, double? health, double? total}) {
    if (shopping != null) shoppingPercent = shopping;
    if (food != null) foodPercent = food;
    if (health != null) healthPercent = health;
    if (total != null) monthTotal = total;
    notifyListeners();
  }
}
