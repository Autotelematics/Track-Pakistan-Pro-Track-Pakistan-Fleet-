import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/task_model.dart';
import 'package:trackerapp/data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSubmitting = false;
  bool _permissionDenied = false;
  String? _errorMessage;
  List<TaskItem> _tasks = <TaskItem>[];
  int _totalTasks = 0;
  int _perPage = 20;
  int _currentPage = 1;
  int _lastPage = 1;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSubmitting => _isSubmitting;
  bool get permissionDenied => _permissionDenied;
  String? get errorMessage => _errorMessage;
  List<TaskItem> get tasks => _tasks;
  int get totalTasks => _totalTasks;
  int get perPage => _perPage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMoreTasks => _currentPage < _lastPage;

  List<TaskItem> get latestFiveTasks {
    final sorted = List<TaskItem>.from(_tasks)
      ..sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate == null && bDate == null) return b.id.compareTo(a.id);
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    return sorted.take(5).toList(growable: false);
  }

  Future<void> fetchTasks({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _tasks.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    _permissionDenied = false;
    notifyListeners();

    try {
      final fetched = await _repository.getTasksList(page: 1, perPage: _perPage);
      _tasks = fetched.items;
      _totalTasks = fetched.total;
      _perPage = fetched.perPage > 0 ? fetched.perPage : _perPage;
      _currentPage = fetched.currentPage;
      _lastPage = fetched.lastPage;
      _errorMessage = null;
      _permissionDenied = false;
    } catch (e) {
      final normalized = _normalizeErrorMessage(e);
      _errorMessage = normalized;
      _permissionDenied = _isPermissionError(normalized);
      _currentPage = 1;
      _lastPage = 1;
      _totalTasks = _tasks.length;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreTasks() async {
    if (_isLoading || _isLoadingMore || !hasMoreTasks) return;

    _isLoadingMore = true;
    notifyListeners();
    try {
      final nextPage = _currentPage + 1;
      final fetched =
          await _repository.getTasksList(page: nextPage, perPage: _perPage);
      _tasks = <TaskItem>[..._tasks, ...fetched.items];
      _totalTasks = fetched.total;
      _perPage = fetched.perPage > 0 ? fetched.perPage : _perPage;
      _currentPage = fetched.currentPage;
      _lastPage = fetched.lastPage;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _normalizeErrorMessage(e);
      _permissionDenied = _isPermissionError(_errorMessage!);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<TaskActionResult> createTask({
    required TaskUpsertPayload payload,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      late final TaskActionResult result;
      try {
        result = await _repository.createTask(payload: payload);
      } catch (e) {
        result = TaskActionResult(
          success: false,
          message: _normalizeErrorMessage(e),
        );
      }
      if (result.success) {
        await fetchTasks(force: true);
      }
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<TaskActionResult> updateTask({
    required int id,
    required TaskUpsertPayload payload,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      late final TaskActionResult result;
      try {
        result = await _repository.updateTask(id: id, payload: payload);
      } catch (e) {
        result = TaskActionResult(
          success: false,
          message: _normalizeErrorMessage(e),
        );
      }
      if (result.success) {
        await fetchTasks(force: true);
      }
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<TaskActionResult> deleteTask({required int id}) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      late final TaskActionResult result;
      try {
        result = await _repository.deleteTask(id: id);
      } catch (e) {
        result = TaskActionResult(
          success: false,
          message: _normalizeErrorMessage(e),
        );
      }
      if (result.success) {
        await fetchTasks(force: true);
      }
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<TaskActionResult> assignTask({
    required int taskId,
    required int deviceId,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      late final TaskActionResult result;
      try {
        result = await _repository.assignTasks(
          taskIds: <int>[taskId],
          deviceIds: <int>[deviceId],
        );
      } catch (e) {
        result = TaskActionResult(
          success: false,
          message: _normalizeErrorMessage(e),
        );
      }
      if (result.success) {
        await fetchTasks(force: true);
      }
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String _normalizeErrorMessage(Object error) {
    final raw = error.toString().trim();
    if (raw.startsWith('Exception:')) {
      return raw.replaceFirst('Exception:', '').trim();
    }
    return raw.isEmpty ? 'Request failed' : raw;
  }

  bool _isPermissionError(String message) {
    final lower = message.toLowerCase();
    return lower.contains("don't have permission") ||
        lower.contains('do not have permission') ||
        lower.contains('permission');
  }
}
