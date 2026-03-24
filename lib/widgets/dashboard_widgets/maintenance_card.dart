import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/dashboard_widgets/dashboard_scale.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class MaintenanceCard extends StatelessWidget {
  final GetDashboardModel data;

  const MaintenanceCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    final valid = data.maintenance;

    // All Maintenance Count
    final allCount = valid.length.toString();
    final due = valid
        .where((m) =>
            m.status.toLowerCase() == "due" ||
            (m.percent >= 95 && m.percent < 100))
        .toList();
    final dueCount = due.length.toString();
    final overdue = valid
        .where((m) =>
            m.status.toLowerCase() == "expired" ||
            m.percent >= 100 ||
            m.left <= 0)
        .toList();
    final overdueCount = overdue.length.toString();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.5.w),
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: isDark ? 14 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.maintenanceReminder,
            style:
                AppStyles.semiboldTextStyle(context).copyWith(fontSize: 15.sp),
          ),
          verticalSpace(height: 1.3.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 1.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: onSurface.withValues(alpha: 0.08)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.02),
                        Colors.white.withValues(alpha: 0.01),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.grey.shade50,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _maintenanceRow(
                  context,
                  title: context.l10n.vehicleStatusAll,
                  iconColor: const Color(0xFF2563EB),
                  count: allCount,
                  onTap: () => _showMaintenanceSheet(
                    context,
                    title: context.l10n.allMaintenance,
                    items: valid,
                  ),
                ),
                Divider(height: 1.7.h, color: onSurface.withValues(alpha: 0.12)),
                _maintenanceRow(
                  context,
                  title: context.l10n.dueSoon,
                  iconColor: const Color(0xFFF59E0B),
                  count: dueCount,
                  onTap: () => _showMaintenanceSheet(
                    context,
                    title: context.l10n.dueMaintenance,
                    items: due,
                  ),
                ),
                Divider(height: 1.7.h, color: onSurface.withValues(alpha: 0.12)),
                _maintenanceRow(
                  context,
                  title: context.l10n.overdue,
                  iconColor: const Color(0xFFDC2626),
                  count: overdueCount,
                  isCritical: true,
                  onTap: () => _showMaintenanceSheet(
                    context,
                    title: context.l10n.overdueMaintenance,
                    items: overdue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _maintenanceRow(
    BuildContext context, {
    required String title,
    required Color iconColor,
    required String count,
    required VoidCallback onTap,
    bool isCritical = false,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final iconScale = dashboardIconScale(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: .15.h),
        child: Row(
          children: [
            Container(
              height: 3.3.h,
              width: 3.3.h,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                title == context.l10n.vehicleStatusAll
                    ? Icons.build_circle
                    : Icons.calendar_month,
                color: iconColor,
                size: (17 * iconScale).sp,
              ),
            ),
            horizontalSpace(width: 2.2.w),
            Expanded(
              child: Text(
                title,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 14.sp,
                  fontWeight: isCritical ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 0.45.h),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isCritical ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: iconColor.withValues(alpha: 0.28)),
              ),
              child: Text(
                context.l10n.itemsCount(count),
                style: AppStyles.regularTextStyle(context)
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 11.5.sp),
              ),
            ),
            horizontalSpace(width: .7.h),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: (15 * iconScale).sp,
              color: isCritical
                  ? iconColor.withValues(alpha: 0.85)
                  : onSurface.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }

  void _showMaintenanceSheet(
    BuildContext context, {
    required String title,
    required List<MaintenanceItem> items,
  }) {
    final theme = Theme.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 70.h, maxHeight: 70.h),
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
                Text(
                  "$title (${items.length})",
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 15.sp,
                  ),
                ),
                verticalSpace(height: 1.h),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            "No maintenance items",
                            style: AppStyles.regularTextStyle(context)
                                .copyWith(fontSize: 13.sp),
                          ),
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1.6.h,
                            color: onSurface.withValues(alpha: 0.12),
                          ),
                          itemBuilder: (_, i) {
                            final item = items[i];
                            final status = item.status.toLowerCase();
                            final isOverdue = status == 'expired' ||
                                item.percent >= 100 ||
                                item.left <= 0;
                            final isDue = !isOverdue &&
                                (status == 'due' ||
                                    (item.percent >= 95 && item.percent < 100));
                            final statusColor = isOverdue
                                ? const Color(0xFFDC2626)
                                : (isDue
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF16A34A));

                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.4.w,
                                vertical: .9.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: statusColor.withValues(alpha: .10),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: .30),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Maintenance #${i + 1}",
                                    style: AppStyles.semiboldTextStyle(context)
                                        .copyWith(
                                      fontSize: 12.6.sp,
                                      color: statusColor,
                                    ),
                                  ),
                                  verticalSpace(height: .6.h),
                                  _detailRow(
                                    context,
                                    leftTitle: "Vehicle",
                                    leftValue: item.device.isEmpty
                                        ? 'Unknown'
                                        : item.device,
                                    rightTitle: "Name",
                                    rightValue: item.name.isEmpty
                                        ? 'No title'
                                        : item.name,
                                  ),
                                  verticalSpace(height: .5.h),
                                  _detailRow(
                                    context,
                                    leftTitle: "Type",
                                    leftValue: item.typeLabel.isEmpty
                                        ? (item.expirationBy.isEmpty
                                            ? '-'
                                            : item.expirationBy)
                                        : item.typeLabel,
                                    rightTitle: "Unit",
                                    rightValue:
                                        item.unit.isEmpty ? '-' : item.unit,
                                  ),
                                  verticalSpace(height: .5.h),
                                  _detailRow(
                                    context,
                                    leftTitle: "Interval",
                                    leftValue: item.interval.toStringAsFixed(0),
                                    rightTitle: "Last Service",
                                    rightValue: item.lastService.isEmpty
                                        ? '-'
                                        : item.lastService,
                                  ),
                                  verticalSpace(height: .5.h),
                                  _detailRow(
                                    context,
                                    leftTitle: "Current",
                                    leftValue: item.current.toStringAsFixed(0),
                                    rightTitle: "Percent",
                                    rightValue:
                                        "${item.percent.toStringAsFixed(0)}%",
                                  ),
                                  verticalSpace(height: .5.h),
                                  _detailRow(
                                    context,
                                    leftTitle: "Left",
                                    leftValue: item.left.toStringAsFixed(0),
                                    rightTitle: "Status",
                                    rightValue: item.status.isEmpty
                                        ? 'unknown'
                                        : item.status,
                                  ),
                                  verticalSpace(height: .45.h),
                                  _detailRow(
                                    context,
                                    leftTitle: "Expires Date",
                                    leftValue: item.expiresDate.isEmpty
                                        ? '-'
                                        : item.expiresDate,
                                    rightTitle: "Remind Date",
                                    rightValue: item.remindDate.isEmpty
                                        ? '-'
                                        : item.remindDate,
                                  ),
                                  if (item.daysTotal != null ||
                                      item.daysElapsed != null ||
                                      item.daysLeft != null) ...[
                                    verticalSpace(height: .45.h),
                                    _detailRow(
                                      context,
                                      leftTitle: "Days (Total/Elapsed)",
                                      leftValue:
                                          "${item.daysTotal ?? '-'} / ${item.daysElapsed ?? '-'}",
                                      rightTitle: "Days Left",
                                      rightValue:
                                          item.daysLeft?.toString() ?? '-',
                                    ),
                                  ],
                                  verticalSpace(height: .45.h),
                                  _detailSingle(
                                    context,
                                    title: "Description",
                                    value: item.description.isEmpty
                                        ? '-'
                                        : item.description,
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

  Widget _detailRow(
    BuildContext context, {
    required String leftTitle,
    required String leftValue,
    required String rightTitle,
    required String rightValue,
  }) {
    return Row(
      children: [
        Expanded(
          child: _detailSingle(
            context,
            title: leftTitle,
            value: leftValue,
          ),
        ),
        horizontalSpace(width: 2.w),
        Expanded(
          child: _detailSingle(
            context,
            title: rightTitle,
            value: rightValue,
          ),
        ),
      ],
    );
  }

  Widget _detailSingle(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return RichText(
      text: TextSpan(
        text: "$title: ",
        style: AppStyles.regularTextStyle(context).copyWith(
          fontSize: 11.2.sp,
          fontWeight: FontWeight.w700,
          color: onSurface.withValues(alpha: .74),
        ),
        children: [
          TextSpan(
            text: value,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 11.6.sp,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
