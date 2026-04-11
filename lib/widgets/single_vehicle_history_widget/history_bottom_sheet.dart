import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/providers/get_device_history_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';

import 'common_widgets.dart';
import 'history_alerts_tab.dart';
import 'history_parked_tab.dart';
import 'history_playback_tab.dart';
import 'history_trips_tab.dart';

class HistoryBottomSheet extends StatefulWidget {
  final DeviceHistoryProvider provider;
  final GoogleMapController? mapController;

  const HistoryBottomSheet({
    super.key,
    required this.provider,
    required this.mapController,
  });

  @override
  State<HistoryBottomSheet> createState() => _HistoryBottomSheetState();
}

class _HistoryBottomSheetState extends State<HistoryBottomSheet> {
  static const double _minSize = 0.13;
  static const double _midSize = 0.38;
  static const double _maxSize = 0.88;

  int _bottomTabIndex = 0;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool _isExpanded = false;

  Future<void> _toggleSheet() async {
    if (!_sheetController.isAttached) return;
    final target = _isExpanded ? _minSize : _maxSize;
    await _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final safeBottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final expandedNow = notification.extent > (_midSize + _minSize) / 2;
        if (expandedNow != _isExpanded) {
          setState(() => _isExpanded = expandedNow);
        }
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: _midSize,
        minChildSize: _minSize,
        maxChildSize: _maxSize,
        snap: true,
        snapSizes: const [_minSize, _midSize, _maxSize],
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: .08)
                    : Colors.black.withValues(alpha: .08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: safeBottomInset),
              child: Column(
                children: [
                  // Handle (tap to toggle full/collapsed)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleSheet,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.8.h),
                        child: Container(
                          width: 9.w,
                          height: 0.5.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: .24),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Tab row
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: .8.h),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SheetTab(
                            label: l10n.playbackLabel,
                            icon: Icons.play_circle_outline_rounded,
                            isSelected: _bottomTabIndex == 0,
                            onTap: () => setState(() => _bottomTabIndex = 0),
                          ),
                          horizontalSpace(width: .7.w),
                          SheetTab(
                            label: l10n.tripsCountLabel(
                              widget.provider.tripSegments.length,
                            ),
                            icon: Icons.route_outlined,
                            isSelected: _bottomTabIndex == 1,
                            onTap: () => setState(() => _bottomTabIndex = 1),
                          ),
                          horizontalSpace(width: .7.w),
                          SheetTab(
                            label: l10n.parkedCountLabel(
                              widget.provider.parkedSegments.length,
                            ),
                            icon: Icons.local_parking_rounded,
                            isSelected: _bottomTabIndex == 2,
                            onTap: () => setState(() => _bottomTabIndex = 2),
                          ),
                          horizontalSpace(width: .7.w),
                          SheetTab(
                            label: l10n.alertsCountLabel(
                              widget.provider.alertSegments.length,
                            ),
                            icon: Icons.notifications_active_rounded,
                            isSelected: _bottomTabIndex == 3,
                            onTap: () => setState(() => _bottomTabIndex = 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? Colors.white.withValues(alpha: .10)
                          : Colors.black.withValues(alpha: .08),
                    ),
                  ),
                  SizedBox(height: .8.h),
                  // Tab content
                  Expanded(
                    child: _bottomTabIndex == 0
                        ? HistoryPlaybackTab(
                            provider: widget.provider,
                            scrollController: scrollController,
                            mapController: widget.mapController,
                          )
                        : _bottomTabIndex == 1
                            ? HistoryTripsTab(
                                provider: widget.provider,
                                scrollController: scrollController,
                                mapController: widget.mapController,
                                onTripPlay: () =>
                                    setState(() => _bottomTabIndex = 0),
                              )
                            : _bottomTabIndex == 2
                                ? HistoryParkedTab(
                                    provider: widget.provider,
                                    scrollController: scrollController,
                                    mapController: widget.mapController,
                                  )
                                : HistoryAlertsTab(
                                    provider: widget.provider,
                                    scrollController: scrollController,
                                    mapController: widget.mapController,
                                  ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
