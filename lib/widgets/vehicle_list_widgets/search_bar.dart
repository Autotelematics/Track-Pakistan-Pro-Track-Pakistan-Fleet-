import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';
import 'package:trackerapp/utils/app_localizations_x.dart';

class SearchFiled extends StatefulWidget {
  final Color primary;
  final Color onSurface;
  final Color outline;

  const SearchFiled({
    super.key,
    required this.primary,
    required this.onSurface,
    required this.outline,
  });

  @override
  State<SearchFiled> createState() => _SearchFiledState();
}

class _SearchFiledState extends State<SearchFiled> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GetDevicesListProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          height: 5.h,
          child: TextField(
            cursorColor: widget.primary,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 14.8.sp,
            ),
            onChanged: provider.updateSearchQuery,
            decoration: InputDecoration(
              hintText: context.l10n.searchVehicle,
              hintStyle: TextStyle(
                color: widget.onSurface.withValues(alpha: 0.52),
                fontSize: 14.4.sp,
              ),
              filled: true,
              fillColor: widget.primary.withValues(alpha: 0.06),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.outline.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(14),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: widget.outline.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.primary, width: 1.1),
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 2.8.w),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18.5.sp,
                color: widget.onSurface.withValues(alpha: 0.72),
              ),
              prefixIconConstraints: BoxConstraints(
                minHeight: 5.h,
                minWidth: 10.w,
              ),
            ),
          ),
        );
      },
    );
  }
}
