import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/get_device_list_model.dart' as device_model;
import 'package:trackerapp/data/models/get_driver_performance_model.dart';
import 'package:trackerapp/data/models/get_vehicle_performance_model.dart';
import 'package:trackerapp/data/models/performance_kpi_model.dart';
import 'package:trackerapp/data/repositories/performance_repository.dart';
import 'package:trackerapp/data/repositories/vehicle_repository.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class PerformanceProvider with ChangeNotifier {
  final PerformanceRepository _performanceRepository = PerformanceRepository();
  final VehicleRepository _vehicleRepository = VehicleRepository();
  final Map<String, _PerformanceSnapshot> _cache = {};

  bool _isLoading = false;
  String? _error;
  DateTime? _fromDate;
  DateTime? _toDate;
  List<VehiclePerformanceKpi> _vehicleKpis = const [];
  List<DriverPerformanceKpi> _driverKpis = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  List<VehiclePerformanceKpi> get vehicleKpis => _vehicleKpis;
  List<DriverPerformanceKpi> get driverKpis => _driverKpis;

  List<VehiclePerformanceKpi> get topVehiclePerformance {
    final list = [..._vehicleKpis];
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  List<VehiclePerformanceKpi> get bottomVehiclePerformance {
    final list = [..._vehicleKpis];
    list.sort((a, b) => a.score.compareTo(b.score));
    return list;
  }

  List<DriverPerformanceKpi> get topDriverPerformance {
    final list = [..._driverKpis];
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  List<DriverPerformanceKpi> get bottomDriverPerformance {
    final list = [..._driverKpis];
    list.sort((a, b) => a.score.compareTo(b.score));
    return list;
  }

  Future<void> loadPerformance({
    DateTime? from,
    DateTime? to,
    bool forceRefresh = false,
  }) async {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final selectedFrom = from ?? normalizedToday;
    final selectedTo = to ?? normalizedToday;
    final cacheKey = _cacheKey(selectedFrom, selectedTo);

    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      _error = null;
      _fromDate = selectedFrom;
      _toDate = selectedTo;
      _vehicleKpis = cached.vehicleKpis;
      _driverKpis = cached.driverKpis;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _fromDate = selectedFrom;
    _toDate = selectedTo;
    notifyListeners();

    try {
      final token = MySharedPreferences.getString(authTokenKey).trim();
      if (token.isEmpty) {
        throw Exception("Authentication token not available");
      }

      final vehicleModel = await _performanceRepository.getVehiclePerformance(
          userApiHashKey: token,
          from: _fmtDate(selectedFrom),
          to: _fmtDate(selectedTo),
      );
      if (vehicleModel == null || vehicleModel.status != 1) {
        throw Exception("Unable to load vehicle performance");
      }

      final driverModel = await _performanceRepository.getDriverPerformance(
        userApiHashKey: token,
        from: _fmtDate(selectedFrom),
        to: _fmtDate(selectedTo),
      );

      final vehicles = _mapVehiclePerformance(vehicleModel.vehiclePerformance);
      final vehicleNameMap = await _fetchVehicleNameMap();
      final drivers = _mapDriverPerformance(
        driverModel?.driverPerformance ?? const <DriverPerformanceItem>[],
        vehicleNameMap: vehicleNameMap,
      );

      _vehicleKpis = vehicles;
      _driverKpis = drivers;
      _cache[cacheKey] = _PerformanceSnapshot(
        vehicleKpis: vehicles,
        driverKpis: drivers,
      );
      if (_cache.length > 8) {
        _cache.remove(_cache.keys.first);
      }
    } catch (e) {
      _error = e.toString();
      _vehicleKpis = const [];
      _driverKpis = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<VehiclePerformanceKpi> _mapVehiclePerformance(
    List<VehiclePerformanceItem> list,
  ) {
    return list
        .map(
          (e) => VehiclePerformanceKpi(
            deviceId: e.vehicleId,
            deviceName: e.vehicleName.trim().isEmpty
                ? 'Vehicle ${e.vehicleId}'
                : e.vehicleName,
            idleAlertCount: e.idleCount,
            idleDurationSeconds: e.idleDurationSec,
            overSpeedAlertCount: e.overspeedCount,
            overSpeedDurationSeconds: e.overspeedDurationSec,
            score: e.score.clamp(0, 100).toDouble(),
          ),
        )
        .toList();
  }

  List<DriverPerformanceKpi> _mapDriverPerformance(
    List<DriverPerformanceItem> list,
    {required Map<int, String> vehicleNameMap}
  ) {
    return list
        .map(
          (e) => DriverPerformanceKpi(
            driverId: e.driverId,
            driverName: e.driverName.trim().isEmpty
                ? 'Driver ${e.driverId}'
                : e.driverName,
            deviceId: null,
            vehicleName: _formatDriverVehicles(
              vehicleIds: e.vehicleIds,
              vehicleNameMap: vehicleNameMap,
              vehiclesCount: e.vehiclesCount,
            ),
            idleAlertCount: e.idleCount,
            idleDurationSeconds: e.idleDurationSec,
            overSpeedAlertCount: e.overspeedCount,
            overSpeedDurationSeconds: e.overspeedDurationSec,
            score: e.score.clamp(0, 100).toDouble(),
          ),
        )
        .toList();
  }

  Future<Map<int, String>> _fetchVehicleNameMap() async {
    try {
      final model = await _vehicleRepository.fetchVehicleData();
      final items = model?.items ?? const <device_model.Item>[];
      final map = <int, String>{};
      for (final item in items) {
        final id = item.id;
        if (id == null) continue;
        final name = (item.name ?? '').trim();
        if (name.isNotEmpty) {
          map[id] = name;
        }
      }
      return map;
    } catch (_) {
      return const {};
    }
  }

  String _formatDriverVehicles({
    required List<int> vehicleIds,
    required Map<int, String> vehicleNameMap,
    required int vehiclesCount,
  }) {
    if (vehicleIds.isEmpty) {
      return vehiclesCount > 0 ? '$vehiclesCount vehicle(s)' : 'No vehicle';
    }

    final names = vehicleIds
        .map((id) => vehicleNameMap[id] ?? 'Vehicle $id')
        .where((name) => name.trim().isNotEmpty)
        .toList();

    if (names.isEmpty) {
      return vehiclesCount > 0 ? '$vehiclesCount vehicle(s)' : 'No vehicle';
    }
    if (names.length <= 2) return names.join(', ');
    return '${names.take(2).join(', ')} +${names.length - 2}';
  }

  String _cacheKey(DateTime from, DateTime to) {
    return '${_fmtDate(from)}|${_fmtDate(to)}';
  }

  String _fmtDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}

class _PerformanceSnapshot {
  final List<VehiclePerformanceKpi> vehicleKpis;
  final List<DriverPerformanceKpi> driverKpis;

  const _PerformanceSnapshot({
    required this.vehicleKpis,
    required this.driverKpis,
  });
}
