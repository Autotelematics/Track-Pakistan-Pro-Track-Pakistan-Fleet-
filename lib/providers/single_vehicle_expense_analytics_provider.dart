import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/data/repositories/device_expense_repository.dart';

enum SingleExpenseRangePreset {
  today,
  sevenDays,
  thirtyDays,
  thisMonth,
  custom
}

class SingleExpenseTrendPoint {
  final DateTime date;
  final double amount;
  SingleExpenseTrendPoint({required this.date, required this.amount});
}

class SingleExpenseTypeTotal {
  final String type;
  final double amount;
  SingleExpenseTypeTotal({required this.type, required this.amount});
}

class SingleExpenseActivityItem {
  final int expenseId;
  final String type;
  final String name;
  final DateTime? date;
  final double amount;
  final String supplier;

  SingleExpenseActivityItem({
    required this.expenseId,
    required this.type,
    required this.name,
    required this.date,
    required this.amount,
    required this.supplier,
  });
}

class SingleVehicleExpenseAnalyticsProvider extends ChangeNotifier {
  final int deviceId;
  final DeviceExpenseRepository _expenseRepo = DeviceExpenseRepository();

  SingleVehicleExpenseAnalyticsProvider({required this.deviceId});

  bool _isLoading = false;
  String? _error;

  SingleExpenseRangePreset _preset = SingleExpenseRangePreset.thisMonth;
  DateTime _from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _to = DateTime.now();
  Map<int, String> _typeNameById = <int, String>{};

  double _selectedTotal = 0;
  double _thisMonthTotal = 0;
  double _lastMonthTotal = 0;
  int _transactionCount = 0;
  double _avgPerTransaction = 0;
  double _avgDailySpend = 0;
  List<SingleExpenseTrendPoint> _trend = <SingleExpenseTrendPoint>[];
  List<SingleExpenseTypeTotal> _topTypes = <SingleExpenseTypeTotal>[];
  List<SingleExpenseActivityItem> _recent = <SingleExpenseActivityItem>[];
  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  SingleExpenseRangePreset get preset => _preset;
  DateTime get from => _from;
  DateTime get to => _to;
  double get selectedTotal => _selectedTotal;
  double get thisMonthTotal => _thisMonthTotal;
  double get lastMonthTotal => _lastMonthTotal;
  int get transactionCount => _transactionCount;
  double get avgPerTransaction => _avgPerTransaction;
  double get avgDailySpend => _avgDailySpend;
  List<SingleExpenseTrendPoint> get trend => _trend;
  List<SingleExpenseTypeTotal> get topTypes => _topTypes;
  List<SingleExpenseActivityItem> get recent => _recent;

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
    await _ensureExpenseTypes();
    await refresh();
  }

  Future<void> setPreset(SingleExpenseRangePreset preset) async {
    if (_disposed) return;
    _preset = preset;
    final now = DateTime.now();
    switch (preset) {
      case SingleExpenseRangePreset.today:
        _from = DateTime(now.year, now.month, now.day);
        _to = DateTime(now.year, now.month, now.day);
        break;
      case SingleExpenseRangePreset.sevenDays:
        _from = DateTime(now.year, now.month, now.day - 6);
        _to = DateTime(now.year, now.month, now.day);
        break;
      case SingleExpenseRangePreset.thirtyDays:
        _from = DateTime(now.year, now.month, now.day - 29);
        _to = DateTime(now.year, now.month, now.day);
        break;
      case SingleExpenseRangePreset.thisMonth:
        _from = DateTime(now.year, now.month, 1);
        _to = DateTime(now.year, now.month, now.day);
        break;
      case SingleExpenseRangePreset.custom:
        break;
    }
    _notifySafely();
    if (preset != SingleExpenseRangePreset.custom) {
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

    if (normalizedFrom.isAfter(today) ||
        normalizedTo.isAfter(today) ||
        normalizedFrom.isAfter(normalizedTo)) {
      return;
    }

    _preset = SingleExpenseRangePreset.custom;
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
      await _loadRangeAnalytics();
      await _loadMonthComparison();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _notifySafely();
      }
    }
  }

  Future<void> exportSummary({required String vehicleName}) async {
    final buffer = StringBuffer();
    final fmt = DateFormat('dd MMM yyyy');
    buffer.writeln("Single Vehicle Expense Analytics");
    buffer.writeln("Vehicle: $vehicleName");
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
    buffer.writeln("Recent Expenses:");
    for (final item in _recent.take(5)) {
      final dateText = item.date == null ? "-" : fmt.format(item.date!);
      buffer.writeln(
          "- $dateText | ${item.type} | ${item.name.isEmpty ? "-" : item.name} | Rs ${item.amount.toStringAsFixed(2)}");
    }
    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
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
    final response = await _expenseRepo.listExpenses(
      deviceId: deviceId,
      from: _from,
      to: _to,
      perPage: 100,
    );

    final trendMap = <DateTime, double>{};
    final typeMap = <String, double>{};
    final activities = <SingleExpenseActivityItem>[];

    final overall = response.total;
    int transactions = 0;

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
        SingleExpenseActivityItem(
          expenseId: expense.id,
          type: type,
          name: expense.name,
          date: expense.date,
          amount: expense.totalCost,
          supplier: expense.supplier,
        ),
      );
    }

    final daysCount = _to.difference(_from).inDays + 1;
    _selectedTotal = overall;
    _transactionCount = transactions;
    _avgPerTransaction = transactions == 0 ? 0 : (overall / transactions);
    _avgDailySpend = daysCount <= 0 ? 0 : (overall / daysCount);

    _trend = trendMap.entries
        .map((e) => SingleExpenseTrendPoint(date: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    _topTypes = typeMap.entries
        .map((e) => SingleExpenseTypeTotal(type: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

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
    final response = await _expenseRepo.listExpenses(
      deviceId: deviceId,
      from: from,
      to: to,
      perPage: 1,
    );
    return response.total;
  }
}
