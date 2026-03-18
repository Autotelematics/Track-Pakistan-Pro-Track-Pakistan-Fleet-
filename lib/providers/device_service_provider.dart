import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/device_service_model.dart';
import 'package:trackerapp/data/repositories/device_service_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';

class DeviceServiceProvider extends ChangeNotifier {
  final DeviceServiceRepository _repository = DeviceServiceRepository();
  bool _isDisposed = false;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  int _total = 0;
  int _currentPage = 1;
  int _lastPage = 1;
  List<DeviceService> _services = <DeviceService>[];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int get total => _total;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  List<DeviceService> get services => _services;

  Future<void> initialize({required int deviceId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final list = await _repository.listServices(deviceId: deviceId);
      _services = list.data;
      _total = list.total;
      _currentPage = list.currentPage;
      _lastPage = list.lastPage;
    } catch (e) {
      _errorMessage = e.toString();
      AppSnackBar.error(message: _errorMessage ?? 'Failed to load services');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({required int deviceId}) async {
    try {
      final list = await _repository.listServices(deviceId: deviceId);
      _services = list.data;
      _total = list.total;
      _currentPage = list.currentPage;
      _lastPage = list.lastPage;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      AppSnackBar.error(message: _errorMessage ?? 'Failed to load services');
    } finally {
      notifyListeners();
    }
  }

  Future<void> addService({
    required int deviceId,
    required String name,
    required String expirationBy,
    required String interval,
    required String lastService,
    String? triggerEventLeft,
    required bool renewAfterExpiration,
    required bool expires,
    DateTime? expiresDate,
    required bool remind,
    DateTime? remindDate,
    String? email,
    String? mobilePhone,
    String? description,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.createService(
        deviceId: deviceId,
        name: name,
        expirationBy: expirationBy,
        interval: interval,
        lastService: lastService,
        triggerEventLeft: triggerEventLeft,
        renewAfterExpiration: renewAfterExpiration,
        expires: expires,
        expiresDate: expiresDate,
        remind: remind,
        remindDate: remindDate,
        email: email,
        mobilePhone: mobilePhone,
        description: description,
      );
      AppSnackBar.success(message: 'Service added');
      await refresh(deviceId: deviceId);
    } catch (e) {
      AppSnackBar.error(message: e.toString());
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> editService({
    required int deviceId,
    required int serviceId,
    String? name,
    String? expirationBy,
    String? interval,
    String? lastService,
    String? triggerEventLeft,
    bool? renewAfterExpiration,
    bool? expires,
    DateTime? expiresDate,
    bool? remind,
    DateTime? remindDate,
    String? email,
    String? mobilePhone,
    String? description,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.updateService(
        serviceId: serviceId,
        name: name,
        expirationBy: expirationBy,
        interval: interval,
        lastService: lastService,
        triggerEventLeft: triggerEventLeft,
        renewAfterExpiration: renewAfterExpiration,
        expires: expires,
        expiresDate: expiresDate,
        remind: remind,
        remindDate: remindDate,
        email: email,
        mobilePhone: mobilePhone,
        description: description,
      );
      AppSnackBar.success(message: 'Service updated');
      await refresh(deviceId: deviceId);
    } catch (e) {
      AppSnackBar.error(message: e.toString());
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteService({
    required int deviceId,
    required int serviceId,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.deleteService(
        serviceId: serviceId,
        deviceId: deviceId,
      );
      AppSnackBar.success(message: 'Service deleted');
      await refresh(deviceId: deviceId);
    } catch (e) {
      AppSnackBar.error(message: e.toString());
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
