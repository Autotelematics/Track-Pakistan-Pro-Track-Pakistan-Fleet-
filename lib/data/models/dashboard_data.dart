import 'package:flutter/material.dart';

class DashboardData {
  final List<ChartData> chartData;
  final List<AlertData> alerts;
  final List<double> barValues;
  final List<String> barDays;
  final List<DummyAlertData> dummyAlertData;
  final List<ExpenseData> expenseList;
  final String maintenanceDue;
  final String maintenanceOverdue;
  final String totalDistance;
  final String averageDistance;
  final String totalVehicles;

  DashboardData({
    required this.chartData,
    required this.alerts,
    required this.barValues,
    required this.barDays,
    required this.dummyAlertData,
    required this.expenseList,
    required this.maintenanceDue,
    required this.maintenanceOverdue,
    required this.totalDistance,
    required this.averageDistance,
    required this.totalVehicles,
  });
}

class ChartData {
  final Color color;
  final double value;
  final String label;
  final String percent;

  ChartData({
    required this.color,
    required this.value,
    required this.label,
    required this.percent,
  });
}

class AlertData {
  final String svgPath;
  final String name;
  final String unit;
  final String value;
  final Color bgColor;

  AlertData({
    required this.svgPath,
    required this.name,
    required this.unit,
    required this.value,
    required this.bgColor,
  });
}

class ExpenseData {
  final String label;
  final double amount;

  ExpenseData({required this.label, required this.amount});
}

class DummyAlertData {
  final String label;
  final int value;
  final int total;

  DummyAlertData({required this.label, required this.value, this.total = 100});
}