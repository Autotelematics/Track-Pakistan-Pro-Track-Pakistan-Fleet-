import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/vehicle_list_provider.dart';

class SearchFiled extends StatefulWidget {
   Color primary;
   Color onSurface;
   Color outline;

   SearchFiled({
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
    return TextField(
      cursorColor: widget.primary,
      style: AppStyles.regularTextStyle(context),
      onChanged: (value) =>
          Provider.of<VehicleListProvider>(context, listen: false)
              .updateSearchQuery(value),
      decoration: InputDecoration(
        hintText: "Search",
        hintStyle: TextStyle(color: widget.onSurface.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: widget.outline, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.primary, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Icon(Icons.search_outlined, size: 20.sp, color: widget.onSurface),
        ),
        prefixIconConstraints: BoxConstraints(maxHeight: 3.h),
      ),
    );
  }
}