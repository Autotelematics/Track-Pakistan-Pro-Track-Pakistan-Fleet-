import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/maintenance_provider.dart';

class VehicleDropdown extends StatelessWidget {
  const VehicleDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MaintenanceProvider>(context);
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.cardColor,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.selectedVehicle,
          style:  AppStyles.regularTextStyle(context),
          hint: Text(
            "Select Vehicle",
            style: AppStyles.regularTextStyle(context)
          ),
          icon: Icon(Icons.arrow_drop_down, color: onSurface),
          isExpanded: true,
          items: provider.vehicles
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (val) => provider.selectVehicle(val!),
        ),
      ),
    );
  }
}
