import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/providers/maintenance_provider.dart';
import 'package:trackerapp/utils/top_curve_bezier.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/maintenance_widgets/maintenance_field.dart';
import 'package:trackerapp/widgets/maintenance_widgets/vehicle_dropdown.dart';

class AddMaintenanceScreen extends StatelessWidget {
  const AddMaintenanceScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return ChangeNotifierProvider(
      create: (_) => MaintenanceProvider(),
      child: Consumer<MaintenanceProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                    colors: [theme.cardColor, theme.cardColor])
                    : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.purple,
                    AppColors.blueCyanWithOpacity
                  ],
                ),
              ),
              child: Column(
                children: [
                  verticalSpace(height: 7.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: isDark ? onSurface : AppColors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Flexible(child: Container()),
                        Text(
                          "Add Maintenance",
                          style: AppStyles.boldTextStyle(context).copyWith(
                              color: isDark ? onSurface : AppColors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600),
                        ),
                        horizontalSpace(width: 15.w),
                        Flexible(child: Container()),
                      ],
                    ),
                  ),
                  verticalSpace(height: 4.h),
                  Expanded(
                    child: ClipPath(
                      clipper: TopCurveClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? LinearGradient(
                            colors: [
                              theme.scaffoldBackgroundColor,
                              theme.scaffoldBackgroundColor
                            ],
                          )
                              : LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.grey.shade100,
                            ],
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 6.h),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Select Vehicle",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: onSurface,
                                      fontWeight: FontWeight.w500)),
                              verticalSpace(height: 1.h),
                              const VehicleDropdown(),
                              verticalSpace(height: 2.h),

                              MaintenanceField(
                                title: "Maintenance Date",
                                hint: provider.maintenanceDate == null
                                    ? "Pick Date"
                                    : "${provider.maintenanceDate!.day}/${provider.maintenanceDate!.month}/${provider.maintenanceDate!.year}",
                                onTap: () =>provider.pickDate(context),
                              ),
                              verticalSpace(height: 2.h),

                              MaintenanceField(
                                title: "Maintenance Time",
                                hint: provider.maintenanceTime == null
                                    ? "Pick Time"
                                    : provider.maintenanceTime!.format(context),
                                onTap: () => provider.pickTime(context),
                              ),
                              verticalSpace(height: 2.h),

                              MaintenanceField(
                                title: "Description",
                                hint: provider.description.isEmpty
                                    ? "Write here"
                                    : provider.description,
                                onTap: () async {
                                  final text = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) {
                                      final controller =
                                      TextEditingController(
                                          text: provider.description);
                                      return AlertDialog(
                                        title: const Text("Enter Description"),
                                        content: TextField(
                                          controller: controller,
                                          maxLines: 4,
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text("Cancel")),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      ctx, controller.text),
                                              child: const Text("Save")),
                                        ],
                                      );
                                    },
                                  );
                                  if (text != null) provider.setDescription(text);
                                },
                              ),
                              verticalSpace(height: 10.h),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Cancel",
                                          style: TextStyle(
                                              fontSize: 17.sp,
                                              color: onSurface)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: CustomButton(
                                      text: "Save",
                                      onPressed: () {
                                        debugPrint(
                                            "Vehicle: ${provider.selectedVehicle}, Date: ${provider.maintenanceDate}, Time: ${provider.maintenanceTime}, Desc: ${provider.description}");
                                      },
                                      height: 4.5.h,
                                    ),
                                  ),
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
            ),
          );
        },
      ),
    );
  }
}
