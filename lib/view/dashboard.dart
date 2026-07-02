import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_history_model.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/providers/dashboard_layout_provider.dart';
import 'package:trackerapp/providers/dashboard_provider.dart';
import 'package:trackerapp/providers/task_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/dashboard_widgets/alert_grid.dart';
import 'package:trackerapp/widgets/dashboard_widgets/dashboard_scale.dart';
import 'package:trackerapp/widgets/dashboard_widgets/distance_travelled_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/expense_analytics_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/fleet_insight_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/fuel_price_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/header_widget.dart';
import 'package:trackerapp/widgets/dashboard_widgets/local_reminder_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/latest_tasks_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/maintenance_analytics_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/maintenance_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/offline_over_24h_card.dart';
import 'package:trackerapp/widgets/dashboard_widgets/performance_analytics_card.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/vehicle_list_widgets/top_speed_card.dart';

class NewDashboard extends StatefulWidget {
  const NewDashboard({super.key});
  @override
  State<NewDashboard> createState() => _NewDashboardState();
}

class _NewDashboardState extends State<NewDashboard>
    with WidgetsBindingObserver {
  late final DashboardProvider _provider;
  bool _providerReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<DashboardProvider>(context, listen: false);
      _providerReady = true;
      _provider.getDashboardProvider();
      _provider.getDashboardHistoryProvider();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (!mounted || !_providerReady) return;
        _provider.refreshOnResume();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = dashboardTextScale(context);
    final iconScale = dashboardIconScale(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: IconTheme(
          data: IconTheme.of(context).copyWith(size: 24 * iconScale),
          child: Consumer3<DashboardProvider, DashboardLayoutProvider,
              TaskProvider>(
            builder: (context, provider, layoutProvider, taskProvider, child) {
              if (provider.dashboardModel == null) {
                if (provider.error != null) {
                  return _DashboardErrorState(
                    error: provider.error!,
                    onRetry: () {
                      provider.getDashboardProvider();
                      provider.getDashboardHistoryProvider();
                    },
                  );
                }
                return const _DashboardShimmer();
              }

              // Success State
              final data1 = provider.dashboardModel!;
              final historyData = provider.dashboardHistoryModel;
              final cards = _buildCardWidgets(
                data1: data1,
                historyData: historyData,
                provider: provider,
                hideLatestTasks: taskProvider.permissionDenied,
              );
              final orderedVisibleIds = layoutProvider.orderedCardIds
                  .where((id) => layoutProvider.isCardVisible(id))
                  .where(cards.containsKey)
                  .toList();

              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderWidget(
                        currentTime: provider.getTimePeriod(),
                        data1: data1,
                      ),

                      /// Scrollable Part of Dashboard Screen
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 980),
                              child: Column(
                                children: [
                                  _DashboardCustomizeBar(
                                    onTap: () => _showCustomizeSheet(context),
                                  ),
                                  verticalSpace(height: 1.h),
                                  if (orderedVisibleIds.isEmpty)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.w, vertical: 2.h),
                                      child: Text(
                                        l10n.noDashboardCardsSelected,
                                        textAlign: TextAlign.center,
                                        style:
                                            AppStyles.regularTextStyle(context)
                                                .copyWith(fontSize: 13.2.sp),
                                      ),
                                    )
                                  else
                                    ...orderedVisibleIds.expand(
                                      (id) => [
                                        cards[id]!,
                                        verticalSpace(height: 1.h),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (provider.isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Map<String, Widget> _buildCardWidgets({
    required GetDashboardModel data1,
    required GetDashboardHistoryModel? historyData,
    required DashboardProvider provider,
    required bool hideLatestTasks,
  }) {
    final cards = <String, Widget>{
      'fleet_insight': FleetInsightCard(
        dashboard: data1,
        history: historyData,
        offlineOver24hCount: provider.offlineVehiclesOver24h.length,
      ),
      'alert_grid': AlertGrid(data: data1),
      'maintenance': MaintenanceCard(data: data1),
      'maintenance_analytics': MaintenanceAnalyticsCard(data: data1),
      'local_reminder': const LocalReminderCard(),
      'fuel_price': FuelPriceCard(data: data1),
      'history_pair': Column(
              children: [
                DistanceTravelledCard(historyData: historyData),
                verticalSpace(height: 1.h),
                TopSpeedCard(historyData: historyData),
              ],
            ),
      'offline_24h': OfflineOver24hCard(
        vehicles: provider.offlineVehiclesOver24h,
      ),
      'performance': const PerformanceAnalyticsCard(),
      'expense': const ExpenseAnalyticsCard(),
    };
    if (!hideLatestTasks) {
      cards['latest_tasks'] = const LatestTasksCard();
    }
    return cards;
  }

  void _showCustomizeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DashboardCustomizeSheet(),
    );
  }
}

class _DashboardCustomizeBar extends StatelessWidget {
  final VoidCallback onTap;

  const _DashboardCustomizeBar({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final softGreenBg =
        isDark ? const Color(0xFF1D3026) : const Color(0xFFEAF8EE);
    final softGreenBorder =
        isDark ? const Color(0xFF3E6F53) : const Color(0xFFAED9BE);
    final softGreenAccent =
        isDark ? const Color(0xFF8BD3A7) : const Color(0xFF3F8F63);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: .85.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: softGreenBorder,
        ),
        color: softGreenBg,
      ),
      child: Row(
        children: [
          Icon(
            Icons.dashboard_customize_rounded,
            size: 17.sp,
            color: softGreenAccent,
          ),
          horizontalSpace(width: 2.2.w),
          Expanded(
            child: Text(
              context.l10n.customizeDashboard,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: .2.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              context.l10n.edit,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 13.2.sp,
                fontWeight: FontWeight.w700,
                color: softGreenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCustomizeSheet extends StatelessWidget {
  const _DashboardCustomizeSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<DashboardLayoutProvider, TaskProvider>(
      builder: (context, layoutProvider, taskProvider, _) {
        final hideLatestTasks = taskProvider.permissionDenied;
        final allItems = layoutProvider.itemsForEditor;
        final items = hideLatestTasks
            ? allItems
                .where((item) => item.id != 'latest_tasks')
                .toList(growable: false)
            : allItems;
        final displayedIds =
            items.map((item) => item.id).toList(growable: false);
        final allIds = allItems.map((item) => item.id).toList(growable: false);
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 78.h, maxHeight: 78.h),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 11.w,
                    height: .5.h,
                    margin: EdgeInsets.only(bottom: 1.2.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.customizeDashboard,
                        style: AppStyles.semiboldTextStyle(context)
                            .copyWith(fontSize: 15.sp),
                      ),
                    ),
                    TextButton(
                      onPressed: layoutProvider.resetDefaults,
                      child: Text(context.l10n.reset),
                    ),
                  ],
                ),
                Text(
                  context.l10n.dashboardCustomizeHint,
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 11.5.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .7),
                  ),
                ),
                verticalSpace(height: 1.h),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: items.length,
                    onReorder: (oldIndex, newIndex) {
                      if (!hideLatestTasks) {
                        layoutProvider.reorderCards(oldIndex, newIndex);
                        return;
                      }
                      final visiblePositions = displayedIds
                          .map((id) => allIds.indexOf(id))
                          .where((index) => index >= 0)
                          .toList(growable: false);
                      if (oldIndex < 0 || oldIndex >= visiblePositions.length) {
                        return;
                      }
                      final oldFull = visiblePositions[oldIndex];
                      final newFull = newIndex >= visiblePositions.length
                          ? allIds.length
                          : visiblePositions[newIndex];
                      layoutProvider.reorderCards(oldFull, newFull);
                    },
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        color: Colors.transparent,
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        key: ValueKey(item.id),
                        margin: EdgeInsets.only(bottom: .7.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: .75.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: .1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.drag_indicator_rounded),
                            horizontalSpace(width: 2.w),
                            Expanded(
                              child: Text(
                                item.label,
                                style: AppStyles.regularTextStyle(context)
                                    .copyWith(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: item.isVisible,
                              onChanged: (value) =>
                                  layoutProvider.setCardVisibility(
                                item.id,
                                value,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _DashboardErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 40.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            verticalSpace(height: 2.h),
            Text(
              context.l10n.errorLabel(error),
              textAlign: TextAlign.center,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            verticalSpace(height: 2.h),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCardsLoadingPlaceholder extends StatelessWidget {
  const _HistoryCardsLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    return Column(
      children: [
        Container(
          height: 20.h,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        verticalSpace(height: 2.h),
        Container(
          height: 17.h,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ],
    );
  }
}

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerBase = isDark ? const Color(0xFF2A2D35) : Colors.grey[300]!;
    final shimmerHighlight =
        isDark ? const Color(0xFF3B3F48) : Colors.grey[100]!;
    final placeholderColor = isDark ? const Color(0xFF3A3D46) : Colors.white;

    return Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpace(height: 6.h),
          // Header Placeholder
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Avatar
                Container(
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    shape: BoxShape.circle,
                  ),
                  height: 5.h,
                  width: 5.h,
                ),
                // Settings + Notification
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        shape: BoxShape.circle,
                      ),
                      height: 2.6.h,
                      width: 2.6.h,
                    ),
                    horizontalSpace(width: 5.w),
                    Container(
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        shape: BoxShape.circle,
                      ),
                      height: 2.6.h,
                      width: 2.6.h,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ///Greeting
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: placeholderColor,
              borderRadius: BorderRadius.circular(12),
            ),
            height: 2.6.h,
            width: 25.w,
          ),
          Container(
            height: 20.h,
            margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: placeholderColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          /// Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [

                  // Alert Grid Placeholder
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.8,
                      children: List.generate(
                        6,
                        (index) => Container(
                          decoration: BoxDecoration(
                            color: placeholderColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  verticalSpace(height: 2.h),
                  /// Maintenance Card Placeholder
                  Container(
                    height: 15.h,
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  verticalSpace(height: 2.h),
                  ///Distance Travelled Card Placeholder
                  Container(
                    height: 20.h,
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  verticalSpace(height: 2.h),
                  /// Fuel Price Card Placeholder
                  Container(
                    height: 15.h,
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  verticalSpace(height: 5.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
