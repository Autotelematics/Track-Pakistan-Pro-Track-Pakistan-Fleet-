import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_dashboard_model.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';
import 'package:trackerapp/widgets/dashboard_widgets/dashboard_scale.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class FuelPriceCard extends StatelessWidget {
  final GetDashboardModel data;

  const FuelPriceCard({super.key, required this.data});

  String _formatLastUpdated(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return "-";
    final parsed = DateTime.tryParse(text.replaceFirst(' ', 'T'));
    if (parsed == null) return text;
    return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

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
                  Icons.local_gas_station_rounded,
                  color: Colors.white,
                  size: _fSp(context, phone: 15.0),
                ),
              ),
              horizontalSpace(width: 2.w),
              Expanded(
                child: Text(
                  context.l10n.fuelPrices,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: _fSp(context, phone: 12.8),
                    fontWeight: FontWeight.w900,
                    color: onSurface.withValues(alpha: .92),
                  ),
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
            child: Column(
              children: [
                _fuelRow(
                  context,
                  label: context.l10n.petrol,
                  price: "${data.petrolPrice.toStringAsFixed(2)} PKR",
                  accent: const Color(0xFF16A34A),
                ),
                Divider(
                    height: 1.6.h, color: onSurface.withValues(alpha: 0.12)),
                _fuelRow(
                  context,
                  label: context.l10n.diesel,
                  price: "${data.dieselPrice.toStringAsFixed(2)} PKR",
                  accent: const Color(0xFFF59E0B),
                ),
                Divider(
                    height: 1.6.h, color: onSurface.withValues(alpha: 0.12)),
                Row(
                  children: [
                    // Container(
                    //   height: 3.h,
                    //   width: 3.h,
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFF2563EB).withValues(alpha: 0.14),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   // child: Icon(
                    //   //   Icons.update,
                    //   //   color: const Color(0xFF2563EB),
                    //   //   size: 15.sp,
                    //   // ),
                    // ),
                    horizontalSpace(width: 1.w),
                    Expanded(
                      child: Text(
                        context.l10n.lastUpdated,
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: _fSp(context, phone: 12.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.4.w, vertical: 0.45.h),
                      // decoration: BoxDecoration(
                      //   color: onSurface.withValues(alpha: 0.08),
                      //   // borderRadius: BorderRadius.circular(20),
                      // ),
                      child: Text(
                        _formatLastUpdated(data.fuelPriceLastUpdated),
                        style: AppStyles.regularTextStyle(context)
                            .copyWith(fontSize: _fSp(context, phone: 11.2)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fuelRow(
    BuildContext context, {
    required String label,
    required String price,
    required Color accent,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final iconScale = dashboardIconScale(context);
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
            Icons.local_gas_station,
            color: accent,
            size: (17 * iconScale).sp,
          ),
        ),
        horizontalSpace(width: 2.2.w),
        Expanded(
          child: Text(
            label,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: _fSp(context, phone: 14.0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.45.h),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.30)),
          ),
          child: Text(
            price,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: _fSp(context, phone: 11.8),
              color: onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

double _fSp(
  BuildContext context, {
  required double phone,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= 360) return (phone * 1.08).sp;
  if (width <= 393) return (phone * 1.10).sp;
  if (width <= 430) return (phone * 1.06).sp;
  return (phone * 1.03).sp;
}
