import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/device_expense_model.dart';
import 'package:trackerapp/data/repositories/device_expense_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';

class DeviceExpenseProvider extends ChangeNotifier {
  final DeviceExpenseRepository _repository = DeviceExpenseRepository();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  double _total = 0;
  List<DeviceExpense> _expenses = <DeviceExpense>[];
  List<DeviceExpenseType> _types = <DeviceExpenseType>[];
  DateTime? _fromDate;
  DateTime? _toDate;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  double get total => _total;
  List<DeviceExpense> get expenses => _expenses;
  List<DeviceExpenseType> get types => _types;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  Future<void> initialize({required int deviceId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _types = await _repository.getExpenseTypes();
      final list = await _repository.listExpenses(
        deviceId: deviceId,
        from: _fromDate,
        to: _toDate,
      );
      _expenses = list.data;
      _total = list.total;
    } catch (e) {
      _errorMessage = e.toString();
      AppSnackBar.error(message: _errorMessage ?? "Failed to load expenses");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({required int deviceId}) async {
    try {
      final list = await _repository.listExpenses(
        deviceId: deviceId,
        from: _fromDate,
        to: _toDate,
      );
      _expenses = list.data;
      _total = list.total;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      AppSnackBar.error(message: _errorMessage ?? "Failed to load expenses");
    } finally {
      notifyListeners();
    }
  }

  Future<void> setDateRange({
    required int deviceId,
    DateTime? from,
    DateTime? to,
  }) async {
    DateTime? normalize(DateTime? value) =>
        value == null ? null : DateTime(value.year, value.month, value.day);

    final normalizedFrom = normalize(from);
    final normalizedTo = normalize(to);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if ((normalizedFrom != null && normalizedFrom.isAfter(today)) ||
        (normalizedTo != null && normalizedTo.isAfter(today))) {
      AppSnackBar.error(message: "Future dates are not allowed");
      return;
    }
    if (normalizedFrom != null &&
        normalizedTo != null &&
        normalizedFrom.isAfter(normalizedTo)) {
      AppSnackBar.error(message: "From date cannot be later than To date");
      return;
    }

    _fromDate = normalizedFrom;
    _toDate = normalizedTo;
    await refresh(deviceId: deviceId);
  }

  Future<void> addExpense({
    required int deviceId,
    required int typeId,
    required DateTime date,
    required double quantity,
    required double unitCost,
    String? name,
    String? supplier,
    String? comment,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.createExpense(
        deviceId: deviceId,
        typeId: typeId,
        date: date,
        quantity: quantity,
        unitCost: unitCost,
        name: name,
        supplier: supplier,
        comment: comment,
      );
      AppSnackBar.success(message: "Expense added");
      await refresh(deviceId: deviceId);
    } catch (e) {
      AppSnackBar.error(message: e.toString());
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> editExpense({
    required int deviceId,
    required int expenseId,
    int? typeId,
    DateTime? date,
    double? quantity,
    double? unitCost,
    String? name,
    String? supplier,
    String? comment,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.updateExpense(
        expenseId: expenseId,
        typeId: typeId,
        date: date,
        quantity: quantity,
        unitCost: unitCost,
        name: name,
        supplier: supplier,
        comment: comment,
      );
      AppSnackBar.success(message: "Expense updated");
      await refresh(deviceId: deviceId);
    } catch (e) {
      AppSnackBar.error(message: e.toString());
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense({
    required int deviceId,
    required int expenseId,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.deleteExpense(expenseId: expenseId);
      AppSnackBar.success(message: "Expense deleted");
      await refresh(deviceId: deviceId);
    } catch (e) {
      AppSnackBar.error(message: e.toString());
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String typeName(int? id) {
    if (id == null) return "Unknown";
    final match = _types.where((type) => type.id == id);
    if (match.isEmpty) return "Type #$id";
    final resolved = match.first.name.toString().trim();
    if (resolved.isEmpty) return "Type #$id";
    return resolved;
  }
}
