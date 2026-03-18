import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/repositories/task_geocoding_repository.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';

class TaskMapPickResult {
  final String address;
  final double lat;
  final double lng;

  const TaskMapPickResult({
    required this.address,
    required this.lat,
    required this.lng,
  });
}

class TaskMapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialAddress;

  const TaskMapPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialAddress,
  });

  @override
  State<TaskMapPickerScreen> createState() => _TaskMapPickerScreenState();
}

class _TaskMapPickerScreenState extends State<TaskMapPickerScreen> {
  final TaskGeocodingRepository _geocodingRepository = TaskGeocodingRepository();
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  Timer? _searchDebounce;
  bool _isSearching = false;
  bool _isReverseLoading = false;
  List<TaskGeoSuggestion> _suggestions = <TaskGeoSuggestion>[];

  late LatLng _selected;
  late double _zoom;
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    final initialLat = widget.initialLat ?? 31.5204;
    final initialLng = widget.initialLng ?? 74.3587;
    _selected = LatLng(initialLat, initialLng);
    _zoom = widget.initialLat != null && widget.initialLng != null ? 16.0 : 12.0;
    _selectedAddress = widget.initialAddress?.trim() ?? '';
    _searchController.addListener(_onSearchChanged);

    if (_selectedAddress.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reverseLookup());
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    final text = _searchController.text.trim();
    if (text.length < 2) {
      setState(() {
        _suggestions = <TaskGeoSuggestion>[];
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _isSearching = true);
      try {
        final result = await _geocodingRepository.autocomplete(text);
        if (!mounted) return;
        setState(() {
          _suggestions = result;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _suggestions = <TaskGeoSuggestion>[];
        });
      } finally {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  Future<void> _reverseLookup() async {
    setState(() => _isReverseLoading = true);
    try {
      final address = await _geocodingRepository.reverseGeocode(
        lat: _selected.latitude,
        lon: _selected.longitude,
      );
      if (!mounted) return;
      setState(() {
        if (address.trim().isNotEmpty) {
          _selectedAddress = address.trim();
        }
      });
    } catch (_) {
      // Keep previous address if reverse lookup fails.
    } finally {
      if (mounted) {
        setState(() => _isReverseLoading = false);
      }
    }
  }

  Future<String> _ensureAddressForSelection() async {
    if (_selectedAddress.trim().isNotEmpty) {
      return _selectedAddress.trim();
    }
    try {
      final address = await _geocodingRepository.reverseGeocode(
        lat: _selected.latitude,
        lon: _selected.longitude,
      );
      if (address.trim().isNotEmpty) {
        if (mounted) {
          setState(() {
            _selectedAddress = address.trim();
          });
        }
        return address.trim();
      }
    } catch (_) {}
    return _selectedAddress.trim();
  }

  void _applySuggestion(TaskGeoSuggestion suggestion) {
    setState(() {
      _selected = LatLng(suggestion.lat, suggestion.lng);
      _selectedAddress = suggestion.address;
      _searchController.text = suggestion.address;
      _suggestions = <TaskGeoSuggestion>[];
      _zoom = 16.0;
    });
    _mapController.move(_selected, _zoom);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, .8.h),
            child: Column(
              children: [
                CustomTextField(
                  controller: _searchController,
                  labelText: 'Search address',
                  prefixIcon: Icons.search_rounded,
                  suffixIcon: _isSearching ? Icons.hourglass_top : null,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white,
                  textColor: theme.colorScheme.onSurface,
                  labelColor: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                  borderColor: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.6),
                  focusedBorderColor: theme.colorScheme.primary,
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: .6.h),
                    constraints: BoxConstraints(maxHeight: 24.h),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(alpha: .12),
                      ),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: theme.colorScheme.onSurface.withValues(alpha: .12),
                      ),
                      itemBuilder: (_, index) {
                        final item = _suggestions[index];
                        return ListTile(
                          dense: true,
                          onTap: () => _applySuggestion(item),
                          title: Text(
                            item.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.regularTextStyle(context)
                                .copyWith(fontSize: 12.5.sp),
                          ),
                          subtitle: (item.city.isNotEmpty || item.country.isNotEmpty)
                              ? Text(
                                  [item.city, item.country]
                                      .where((e) => e.trim().isNotEmpty)
                                      .join(', '),
                                  style: AppStyles.regularTextStyle(context)
                                      .copyWith(fontSize: 11.3.sp),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selected,
                    initialZoom: _zoom,
                    onTap: (_, point) {
                      setState(() {
                        _selected = point;
                      });
                      _reverseLookup();
                    },
                    onPositionChanged: (position, _) {
                      if (position.zoom != null) {
                        _zoom = position.zoom!;
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.trackerapp.mobile',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selected,
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.location_pin,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 3.w,
                  top: 1.2.h,
                  child: Column(
                    children: [
                      _mapControlButton(
                        icon: Icons.add_rounded,
                        onTap: () {
                          _zoom = (_zoom + 1).clamp(3.0, 19.0).toDouble();
                          _mapController.move(_selected, _zoom);
                        },
                      ),
                      SizedBox(height: .8.h),
                      _mapControlButton(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          _zoom = (_zoom - 1).clamp(3.0, 19.0).toDouble();
                          _mapController.move(_selected, _zoom);
                        },
                      ),
                      SizedBox(height: .8.h),
                      _mapControlButton(
                        icon: Icons.refresh_rounded,
                        onTap: _reverseLookup,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(4.w, 1.1.h, 4.w, 1.4.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: .12),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Selected',
                      style: AppStyles.semiboldTextStyle(context)
                          .copyWith(fontSize: 13.sp),
                    ),
                    const Spacer(),
                    if (_isReverseLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: .5.h),
                Text(
                  _selectedAddress.trim().isEmpty
                      ? 'Tap on map to fetch address'
                      : _selectedAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.regularTextStyle(context)
                      .copyWith(fontSize: 12.3.sp),
                ),
                SizedBox(height: .3.h),
                Text(
                  '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}',
                  style: AppStyles.regularTextStyle(context)
                      .copyWith(fontSize: 11.6.sp),
                ),
                SizedBox(height: 1.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final address = await _ensureAddressForSelection();
                      if (!mounted) return;
                      navigator.pop(
                        TaskMapPickResult(
                          address: address,
                          lat: _selected.latitude,
                          lng: _selected.longitude,
                        ),
                      );
                    },
                    child: const Text('Use This Location'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 11.w,
          height: 5.2.h,
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}
