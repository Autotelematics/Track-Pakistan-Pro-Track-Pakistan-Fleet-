import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/dashboard_provider.dart';
import 'package:trackerapp/widgets/dashboard_widgets/dashboard_scale.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class OfflineOver24hCard extends StatelessWidget {
  final List<OfflineVehicleInfo> vehicles;

  const OfflineOver24hCard({
    super.key,
    required this.vehicles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final total = vehicles.length;
    final shown = vehicles.take(5).toList();

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
          Row(
            children: [
              Expanded(
                child: Text(
                  "Offline Over 24 Hours",
                  style: AppStyles.semiboldTextStyle(context)
                      .copyWith(fontSize: 15.sp),
                ),
              ),
              IconButton(
                onPressed: () => _shareOfflineSummary(context),
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: "Export",
                iconSize: 19,
                padding: EdgeInsets.zero,
                visualDensity: const VisualDensity(
                  horizontal: -3,
                  vertical: -3,
                ),
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
            ],
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
            child: total == 0
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: .7.h),
                    child: Row(
                      children: [
                        Container(
                          height: 3.3.h,
                          width: 3.3.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.verified_rounded,
                            color: const Color(0xFF16A34A),
                            size: (17 * dashboardIconScale(context)).sp,
                          ),
                        ),
                        horizontalSpace(width: 2.2.w),
                        Expanded(
                          child: Text(
                            "No vehicles offline for more than 24 hours",
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      ...List.generate(shown.length, (index) {
                        final vehicle = shown[index];
                        return Column(
                          children: [
                            _vehicleRow(context, vehicle),
                            if (index != shown.length - 1)
                              Divider(
                                height: 1.7.h,
                                color: onSurface.withValues(alpha: 0.12),
                              ),
                          ],
                        );
                      }),
                      if (total > shown.length) ...[
                        Divider(
                          height: 1.7.h,
                          color: onSurface.withValues(alpha: 0.12),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => _showAllVehiclesSheet(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.2.w, vertical: .2.h),
                              child: Text(
                                "+${total - shown.length} more",
                                style:
                                    AppStyles.regularTextStyle(context).copyWith(
                                  fontSize: 11.8.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleRow(BuildContext context, OfflineVehicleInfo vehicle) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final iconScale = dashboardIconScale(context);
    final accent = const Color(0xFF0284C7);

    return Row(
      children: [
        Container(
          height: 3.3.h,
          width: 3.3.h,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.wifi_off_rounded,
            color: accent,
            size: (17 * iconScale).sp,
          ),
        ),
        horizontalSpace(width: 2.2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.vehicleName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 13.4.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              verticalSpace(height: .15.h),
              Text(
                "Offline since ${_formatDuration(vehicle.duration)}",
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 11.5.sp,
                  color: onSurface.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration diff) {
    if (diff.isNegative) return "0min";

    int totalDays = diff.inDays;
    final years = totalDays ~/ 365;
    totalDays %= 365;
    final months = totalDays ~/ 30;
    final days = totalDays % 30;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    final parts = <String>[];
    if (years > 0) parts.add("${years}y");
    if (months > 0) parts.add("${months}m");
    if (days > 0) parts.add("${days}d");
    if (hours > 0) parts.add("${hours}h");
    if (minutes > 0) parts.add("${minutes}min");

    if (parts.isEmpty) return "0min";
    return parts.join(" ");
  }

  Future<void> _shareOfflineSummary(BuildContext context) async {
    final buffer = StringBuffer();
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');
    buffer.writeln("Offline Over 24 Hours Report");
    buffer.writeln("Generated: ${fmt.format(DateTime.now())}");
    buffer.writeln("Total Vehicles: ${vehicles.length}");
    buffer.writeln("");

    if (vehicles.isEmpty) {
      buffer.writeln("No vehicles offline for more than 24 hours.");
    } else {
      for (final vehicle in vehicles) {
        buffer.writeln(
          "- ${vehicle.vehicleName} | Offline since ${fmt.format(vehicle.since)} | Duration: ${_formatDuration(vehicle.duration)}",
        );
      }
    }

    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  void _showAllVehiclesSheet(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.5.h),
            child: SizedBox(
              height: 65.h,
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
                    "Offline Over 24 Hours (${vehicles.length})",
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 15.sp,
                    ),
                  ),
                  verticalSpace(height: 1.0.h),
                  Expanded(
                    child: ListView.separated(
                      itemCount: vehicles.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1.5.h,
                        color: onSurface.withValues(alpha: 0.12),
                      ),
                      itemBuilder: (_, index) => _vehicleRow(
                        context,
                        vehicles[index],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
