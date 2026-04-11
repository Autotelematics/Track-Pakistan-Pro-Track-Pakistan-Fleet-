import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/dashboard_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
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
              Container(
                width: 5.8.w,
                height: 5.8.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFF22D3EE),
                      Color(0xFF0284C7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.white,
                  size: _oSp(context, phone: 15.0),
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: Text(
                  context.l10n.offlineOver24Hours,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: _oSp(context, phone: 12.8),
                    fontWeight: FontWeight.w900,
                    color: onSurface.withValues(alpha: .92),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _shareOfflineSummary(context),
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: context.l10n.export,
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
                            color:
                                const Color(0xFF16A34A).withValues(alpha: 0.12),
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
                            context.l10n.noVehiclesOffline24h,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: _oSp(context, phone: 13.0),
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
                                style: AppStyles.regularTextStyle(context)
                                    .copyWith(
                                  fontSize: _oSp(context, phone: 11.8),
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
                  fontSize: _oSp(context, phone: 13.5),
                  fontWeight: FontWeight.w800,
                ),
              ),
              verticalSpace(height: .15.h),
              Text(
                "Offline since ${_formatDuration(vehicle.duration)}",
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: _oSp(context, phone: 11.7),
                  color: onSurface.withValues(alpha: 0.8),
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
    buffer.writeln(context.l10n.reportOffline24h);
    buffer.writeln(context.l10n.generatedAt(fmt.format(DateTime.now())));
    buffer.writeln(context.l10n.totalVehiclesReport(vehicles.length));
    buffer.writeln("");

    if (vehicles.isEmpty) {
      buffer.writeln(context.l10n.noVehiclesOffline24h);
    } else {
      for (final vehicle in vehicles) {
        buffer.writeln(
          "- ${context.l10n.offlineSinceDuration(vehicle.vehicleName, fmt.format(vehicle.since), _formatDuration(vehicle.duration))}",
        );
      }
    }

    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  void _showAllVehiclesSheet(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 74.h, maxHeight: 74.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? <Color>[
                      theme.cardColor.withValues(alpha: .98),
                      theme.cardColor.withValues(alpha: .93),
                    ]
                  : <Color>[
                      Colors.white,
                      const Color(0xFFF7FBFF),
                    ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color:
                  const Color(0xFF0EA5E9).withValues(alpha: isDark ? .24 : .14),
            ),
          ),
          child: SafeArea(
            top: false,
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
                        color: onSurface.withValues(alpha: .24),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.4.w, vertical: .8.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? <Color>[
                                Colors.white.withValues(alpha: .08),
                                Colors.white.withValues(alpha: .04),
                              ]
                            : <Color>[
                                const Color(0xFFF2F8FF),
                                Colors.white,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: onSurface.withValues(alpha: .10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6.2.w,
                          height: 6.2.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xFF22D3EE),
                                Color(0xFF0284C7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: 11.2.sp,
                            color: Colors.white,
                          ),
                        ),
                        horizontalSpace(width: 2.w),
                        Expanded(
                          child: Text(
                            context.l10n.offlineOver24Hours,
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.0.w,
                            vertical: .32.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF7DD3FC),
                            ),
                          ),
                          child: Text(
                            '${vehicles.length}',
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 11.2.sp,
                              color: const Color(0xFF075985),
                            ),
                          ),
                        ),
                        horizontalSpace(width: 1.2.w),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(1.4.w),
                            decoration: BoxDecoration(
                              color: onSurface.withValues(alpha: .08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 10.5.sp,
                              color: onSurface.withValues(alpha: .75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(height: 1.0.h),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 1.4.w, vertical: .25.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark
                            ? Colors.white.withValues(alpha: .03)
                            : Colors.white.withValues(alpha: .90),
                        border: Border.all(
                          color: onSurface.withValues(alpha: .10),
                        ),
                      ),
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

double _oSp(
  BuildContext context, {
  required double phone,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360) return (phone * 1.08).sp;
  if (width <= 393) return (phone * 1.10).sp;
  if (width <= 430) return (phone * 1.06).sp;
  return (phone * 1.03).sp;
}
