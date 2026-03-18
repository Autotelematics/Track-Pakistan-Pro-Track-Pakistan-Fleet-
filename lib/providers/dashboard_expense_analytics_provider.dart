import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/data/models/get_device_status_model.dart'
    as status_model;
import 'package:trackerapp/data/repositories/device_expense_repository.dart';
import 'package:trackerapp/data/repositories/get_device_status_repository.dart';

enum ExpenseRangePreset { today, sevenDays, thirtyDays, thisMonth, custom }

class ExpenseTrendPoint {
  final DateTime date;
  final double amount;
  ExpenseTrendPoint({required this.date, required this.amount});
}

class ExpenseTypeTotal {
  final String type;
  final double amount;
  ExpenseTypeTotal({required this.type, required this.amount});
}

class ExpenseVehicleTotal {
  final int deviceId;
  final String vehicleName;
  final double amount;
  ExpenseVehicleTotal({
    required this.deviceId,
    required this.vehicleName,
    required this.amount,
  });
}

class ExpenseActivityItem {
  final int expenseId;
  final String vehicleName;
  final String type;
  final String name;
  final DateTime? date;
  final double amount;
  final String supplier;

  ExpenseActivityItem({
    required this.expenseId,
    required this.vehicleName,
    required this.type,
    required this.name,
    required this.date,
    required this.amount,
    required this.supplier,
  });
}

class DashboardExpenseAnalyticsProvider extends ChangeNotifier {
  final DeviceExpenseRepository _expenseRepo = DeviceExpenseRepository();
  final GetDeviceStatusRepository _statusRepo = GetDeviceStatusRepository();

  bool _isLoading = false;
  String? _error;

  ExpenseRangePreset _preset = ExpenseRangePreset.thisMonth;
  DateTime _from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _to = DateTime.now();

  List<status_model.Item> _devices = <status_model.Item>[];
  Map<int, String> _typeNameById = <int, String>{};

  double _selectedTotal = 0;
  double _thisMonthTotal = 0;
  double _lastMonthTotal = 0;
  int _transactionCount = 0;
  double _avgPerTransaction = 0;
  double _avgDailySpend = 0;
  List<ExpenseTrendPoint> _trend = <ExpenseTrendPoint>[];
  List<ExpenseTypeTotal> _topTypes = <ExpenseTypeTotal>[];
  List<ExpenseVehicleTotal> _topVehicles = <ExpenseVehicleTotal>[];
  List<ExpenseActivityItem> _recent = <ExpenseActivityItem>[];
  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ExpenseRangePreset get preset => _preset;
  DateTime get from => _from;
  DateTime get to => _to;
  double get selectedTotal => _selectedTotal;
  double get thisMonthTotal => _thisMonthTotal;
  double get lastMonthTotal => _lastMonthTotal;
  int get transactionCount => _transactionCount;
  double get avgPerTransaction => _avgPerTransaction;
  double get avgDailySpend => _avgDailySpend;
  List<ExpenseTrendPoint> get trend => _trend;
  List<ExpenseTypeTotal> get topTypes => _topTypes;
  List<ExpenseVehicleTotal> get topVehicles => _topVehicles;
  List<ExpenseActivityItem> get recent => _recent;

  double get monthChangePercent {
    if (_lastMonthTotal == 0) {
      if (_thisMonthTotal == 0) return 0;
      return 100;
    }
    return ((_thisMonthTotal - _lastMonthTotal) / _lastMonthTotal) * 100;
  }

  void _notifySafely() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> initialize() async {
    if (_disposed) return;
    await _ensureDevices();
    await refresh();
  }

  Future<void> setPreset(ExpenseRangePreset preset) async {
    if (_disposed) return;
    _preset = preset;
    final now = DateTime.now();
    switch (preset) {
      case ExpenseRangePreset.today:
        _from = DateTime(now.year, now.month, now.day);
        _to = DateTime(now.year, now.month, now.day);
        break;
      case ExpenseRangePreset.sevenDays:
        _from = DateTime(now.year, now.month, now.day - 6);
        _to = DateTime(now.year, now.month, now.day);
        break;
      case ExpenseRangePreset.thirtyDays:
        _from = DateTime(now.year, now.month, now.day - 29);
        _to = DateTime(now.year, now.month, now.day);
        break;
      case ExpenseRangePreset.thisMonth:
        _from = DateTime(now.year, now.month, 1);
        _to = DateTime(now.year, now.month, now.day);
        break;
      case ExpenseRangePreset.custom:
        break;
    }
    _notifySafely();
    if (preset != ExpenseRangePreset.custom) {
      await refresh();
    }
  }

  Future<void> setCustomRange({
    required DateTime from,
    required DateTime to,
  }) async {
    if (_disposed) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedFrom = DateTime(from.year, from.month, from.day);
    final normalizedTo = DateTime(to.year, to.month, to.day);

    // Ignore invalid custom ranges.
    if (normalizedFrom.isAfter(today) ||
        normalizedTo.isAfter(today) ||
        normalizedFrom.isAfter(normalizedTo)) {
      return;
    }

    _preset = ExpenseRangePreset.custom;
    _from = normalizedFrom;
    _to = normalizedTo;
    _notifySafely();
    await refresh();
  }

  Future<void> refresh() async {
    if (_disposed) return;
    _isLoading = true;
    _error = null;
    _notifySafely();
    try {
      await _ensureDevices();
      await _ensureExpenseTypes();
      await Future.wait([
        _loadRangeAnalytics(),
        _loadMonthComparison(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _notifySafely();
      }
    }
  }

  Future<void> exportSummary() async {
    final buffer = StringBuffer();
    final fmt = DateFormat('dd MMM yyyy');
    buffer.writeln("Expense Analytics Report");
    buffer.writeln("Period: ${fmt.format(_from)} - ${fmt.format(_to)}");
    buffer.writeln("Total Expense: Rs ${_selectedTotal.toStringAsFixed(2)}");
    buffer.writeln("Transactions: $_transactionCount");
    buffer.writeln(
        "Average per Transaction: Rs ${_avgPerTransaction.toStringAsFixed(2)}");
    buffer.writeln(
        "Average Daily Spend: Rs ${_avgDailySpend.toStringAsFixed(2)}");
    buffer.writeln(
        "This Month: Rs ${_thisMonthTotal.toStringAsFixed(2)} | Last Month: Rs ${_lastMonthTotal.toStringAsFixed(2)} | Change: ${monthChangePercent.toStringAsFixed(1)}%");
    buffer.writeln("");
    buffer.writeln("Top Expense Types:");
    for (final item in _topTypes.take(5)) {
      buffer.writeln("- ${item.type}: Rs ${item.amount.toStringAsFixed(2)}");
    }
    buffer.writeln("");
    buffer.writeln("Top Vehicles:");
    for (final item in _topVehicles.take(5)) {
      buffer.writeln(
          "- ${item.vehicleName}: Rs ${item.amount.toStringAsFixed(2)}");
    }
    buffer.writeln("");
    buffer.writeln("Recent Expenses:");
    for (final item in _recent.take(5)) {
      final dateText = item.date == null ? "-" : fmt.format(item.date!);
      buffer.writeln(
          "- $dateText | ${item.vehicleName} | ${item.type} | ${item.name.isEmpty ? "-" : item.name} | Rs ${item.amount.toStringAsFixed(2)}");
    }
    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  Future<void> _ensureDevices() async {
    if (_devices.isNotEmpty) return;
    final status = await _statusRepo.getDeviceStatusApi();
    _devices = status?.items ?? <status_model.Item>[];
  }

  Future<void> _ensureExpenseTypes() async {
    if (_typeNameById.isNotEmpty) return;
    final types = await _expenseRepo.getExpenseTypes();
    _typeNameById = {
      for (final type in types)
        if (type.id > 0 && type.name.trim().isNotEmpty)
          type.id: type.name.trim(),
    };
  }

  Future<void> _loadRangeAnalytics() async {
    if (_devices.isEmpty) {
      _selectedTotal = 0;
      _transactionCount = 0;
      _avgPerTransaction = 0;
      _avgDailySpend = 0;
      _trend = <ExpenseTrendPoint>[];
      _topTypes = <ExpenseTypeTotal>[];
      _topVehicles = <ExpenseVehicleTotal>[];
      _recent = <ExpenseActivityItem>[];
      return;
    }

    final responses = await Future.wait(
      _devices.map((device) async {
        final response = await _expenseRepo.listExpenses(
          deviceId: device.id,
          from: _from,
          to: _to,
          perPage: 100,
        );
        return (device, response);
      }),
    );

    final trendMap = <DateTime, double>{};
    final typeMap = <String, double>{};
    final vehicleTotals = <ExpenseVehicleTotal>[];
    final activities = <ExpenseActivityItem>[];

    double overall = 0;
    int transactions = 0;
    for (final entry in responses) {
      final device = entry.$1;
      final response = entry.$2;
      overall += response.total;
      vehicleTotals.add(
        ExpenseVehicleTotal(
          deviceId: device.id,
          vehicleName:
              device.name.isEmpty ? "Vehicle ${device.id}" : device.name,
          amount: response.total,
        ),
      );
      for (final expense in response.data) {
        transactions++;
        final keyDate = expense.date == null
            ? _from
            : DateTime(
                expense.date!.year, expense.date!.month, expense.date!.day);
        trendMap[keyDate] = (trendMap[keyDate] ?? 0) + expense.totalCost;
        final type = expense.typeName.isNotEmpty
            ? expense.typeName
            : (expense.typeId != null
                ? (_typeNameById[expense.typeId!] ?? "Unknown")
                : "Unknown");
        typeMap[type] = (typeMap[type] ?? 0) + expense.totalCost;
        activities.add(
          ExpenseActivityItem(
            expenseId: expense.id,
            vehicleName:
                device.name.isEmpty ? "Vehicle ${device.id}" : device.name,
            type: type,
            name: expense.name,
            date: expense.date,
            amount: expense.totalCost,
            supplier: expense.supplier,
          ),
        );
      }
    }

    final daysCount = _to.difference(_from).inDays + 1;
    _selectedTotal = overall;
    _transactionCount = transactions;
    _avgPerTransaction = transactions == 0 ? 0 : (overall / transactions);
    _avgDailySpend = daysCount <= 0 ? 0 : (overall / daysCount);

    final trendList = trendMap.entries
        .map((e) => ExpenseTrendPoint(date: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    _trend = trendList;

    final types = typeMap.entries
        .map((e) => ExpenseTypeTotal(type: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    _topTypes = types;

    vehicleTotals.sort((a, b) => b.amount.compareTo(a.amount));
    _topVehicles = vehicleTotals.where((v) => v.amount > 0).toList();

    activities.sort((a, b) {
      final ad = a.date;
      final bd = b.date;
      if (ad == null && bd == null) return b.expenseId.compareTo(a.expenseId);
      if (ad == null) return 1;
      if (bd == null) return -1;
      final dateCompare = bd.compareTo(ad);
      if (dateCompare != 0) return dateCompare;
      return b.expenseId.compareTo(a.expenseId);
    });
    _recent = activities.take(5).toList();
  }

  Future<void> _loadMonthComparison() async {
    final now = DateTime.now();
    final currentStart = DateTime(now.year, now.month, 1);
    final currentEnd = DateTime(now.year, now.month + 1, 0);
    final lastStart = DateTime(now.year, now.month - 1, 1);
    final lastEnd = DateTime(now.year, now.month, 0);

    _thisMonthTotal = await _sumForRange(currentStart, currentEnd);
    _lastMonthTotal = await _sumForRange(lastStart, lastEnd);
  }

  Future<double> _sumForRange(DateTime from, DateTime to) async {
    if (_devices.isEmpty) return 0;
    final responses = await Future.wait(
      _devices.map((device) {
        return _expenseRepo.listExpenses(
          deviceId: device.id,
          from: from,
          to: to,
          perPage: 1,
        );
      }),
    );
    return responses.fold<double>(0, (sum, item) => sum + item.total);
  }
}
