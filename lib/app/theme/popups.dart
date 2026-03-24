import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_device_commands_model.dart';
import 'package:trackerapp/data/models/get_driver_model.dart';
import 'package:trackerapp/data/models/local_reminder_model.dart';
import 'package:trackerapp/providers/alert_settings_provider.dart';
import 'package:trackerapp/providers/device_command_provider.dart';
import 'package:trackerapp/providers/driver_provider.dart';
import 'package:trackerapp/providers/get_geofence_provider.dart';
import 'package:trackerapp/providers/reminder_provider.dart';
import 'package:trackerapp/utils/app_loading.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/app_validation_dialog.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/maintenance_widgets/maintenance_field.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_colors.dart';

/// Action on Driver
Future<void> showDriverActionPopup(BuildContext context) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

  const transitionDuration = Duration(milliseconds: 400);
  const reverseDuration = Duration(milliseconds: 400);

  await Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      barrierLabel: '',
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseDuration,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor:
                  isDark ? theme.scaffoldBackgroundColor : Colors.white,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 4.8.w, vertical: 2.2.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 4.8.h,
                      child: Stack(
                        children: [
                          Positioned(
                            top: -.6.h,
                            right: -1.w,
                            child: Icon(
                              Icons.manage_accounts_rounded,
                              color: AppColors.blueCyan
                                  .withValues(alpha: isDark ? 0.22 : 0.16),
                              size: 6.2.h,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Driver Options",
                              style: AppStyles.boldTextStyle(context).copyWith(
                                fontSize: 16.2.sp,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpace(height: .45.h),
                    Text(
                      "Add, update, or remove drivers",
                      style: AppStyles.regularTextStyle(context).copyWith(
                        color: onSurface.withValues(alpha: .64),
                        fontSize: 13.8.sp,
                      ),
                    ),
                    verticalSpace(height: 1.6.h),
                    _DriverActionTile(
                      context: context,
                      icon: Icons.person_add_alt_1,
                      title: "Add New Driver",
                      subtitle: "Create a new driver",
                      color: AppColors.green,
                      onTap: () {
                        Navigator.pop(context);
                        showAddDriverPopup(context);
                      },
                    ),
                    verticalSpace(height: 1.h),
                    _DriverActionTile(
                      context: context,
                      icon: Icons.edit,
                      title: "Edit Driver",
                      subtitle: "Update driver info",
                      color: AppColors.blueCyan,
                      onTap: () {
                        Navigator.pop(context);
                        showEditDriverPopup(context);
                      },
                    ),
                    verticalSpace(height: 1.h),
                    _DriverActionTile(
                      context: context,
                      icon: Icons.delete_forever,
                      title: "Delete driver",
                      subtitle: "Permanent delete driver",
                      color: AppColors.red,
                      onTap: () {
                        Navigator.pop(context);
                        showDeleteDriverPopup(context);
                      },
                    ),
                    verticalSpace(height: 1.6.h),
                    CustomButton(
                      text: "Cancel",
                      height: 4.4.h,
                      backgroundColor: Colors.transparent,
                      textColor: onSurface.withValues(alpha: .82),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final t = animation.value;
            if (animation.status == AnimationStatus.reverse) {
              final p = 1.0 - t;
              final offset =
                  Offset.lerp(Offset.zero, const Offset(1.0, 0.0), p)!;
              return Transform.translate(
                offset:
                    Offset(offset.dx * MediaQuery.of(context).size.width, 0),
                child: child,
              );
            } else {
              final offset =
                  Offset.lerp(const Offset(-1.0, 0.0), Offset.zero, t)!;
              return Transform.translate(
                offset:
                    Offset(offset.dx * MediaQuery.of(context).size.width, 0),
                child: child,
              );
            }
          },
        );
      },
    ),
  );
}

class _DriverActionTile extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DriverActionTile({
    required this.context,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.3.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: color.withValues(alpha: 0.16),
              child: Icon(icon, color: color),
            ),
            horizontalSpace(width: 3.2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 14.7.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  verticalSpace(height: 0.25.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

/// Add Driver Popup
Future<void> showAddDriverPopup(BuildContext context) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final compactFieldHeight = 5.5.h;
  final compactTitleSize = 14.sp;
  final compactInputSize = 14.sp;
  final nameCtrl = TextEditingController();
  final rfIdCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.2.w, vertical: 1.8.h),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 11.w,
                        height: 11.w,
                        decoration: BoxDecoration(
                          color: AppColors.green
                              .withValues(alpha: isDark ? .22 : .14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          color: AppColors.green,
                          size: 17.sp,
                        ),
                      ),
                    ),
                    verticalSpace(height: .4.h),
                    Center(
                      child: Text(
                        "Add Driver",
                        style: AppStyles.boldTextStyle(context).copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ),
                    verticalSpace(height: 1.1.h),

                    // Driver Name field
                    MaintenanceField(
                      title: "Driver Name",
                      hint: "Enter driver name",
                      controller: nameCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .7.h,
                      inputVerticalPadding: 1.35.h,
                    ),
                    verticalSpace(height: .9.h),
                    MaintenanceField(
                      title: "RFID",
                      hint: "Enter driver RfId",
                      controller: rfIdCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .7.h,
                      inputVerticalPadding: 1.35.h,
                    ),
                    verticalSpace(height: .9.h),

                    // Phone field
                    MaintenanceField(
                      title: "Phone",
                      hint: "03xxxxxxxxx",
                      controller: phoneCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .7.h,
                      inputVerticalPadding: 1.35.h,
                    ),
                    verticalSpace(height: .9.h),

                    // Email field
                    MaintenanceField(
                      title: "Email",
                      hint: "driver@email.com",
                      controller: emailCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .7.h,
                      inputVerticalPadding: 1.35.h,
                    ),
                    verticalSpace(height: 1.2.h),

                    // Cancel and Save buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            backgroundColor: Colors.transparent,
                            textColor: onSurface.withValues(alpha: .82),
                            height: 4.4.h,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Consumer<DriverProvider>(
                          builder: (context, driverProvider, child) {
                            return driverProvider.isLoading
                                ? AppLoadings.buttonLoading() // loading widget
                                : Expanded(
                                    child: CustomButton(
                                      text: "Save",
                                      height: 4.4.h,
                                      onPressed: () async {
                                        final emailValid = RegExp(
                                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$")
                                            .hasMatch(emailCtrl.text.trim());

                                        if (nameCtrl.text.isEmpty) {
                                          showValidationErrorDialog(
                                            context,
                                            message: "Driver name is required",
                                          );
                                        } else if (emailCtrl.text.isEmpty) {
                                          showValidationErrorDialog(
                                            context,
                                            message: "Please enter your email",
                                          );
                                        } else if (!emailValid) {
                                          showValidationErrorDialog(
                                            context,
                                            message:
                                                "Please enter your valid email",
                                          );
                                        } else {
                                          await driverProvider.addDriver(
                                            name: nameCtrl.text,
                                            rfId: rfIdCtrl.text,
                                            phone: phoneCtrl.text,
                                            email: emailCtrl.text,
                                            deviceId: "",
                                          );
                                          if (!context.mounted) return;
                                          Navigator.pop(context);
                                          // Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  );
                          },
                        )
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

/// Edit Driver
Future<void> showEditDriverPopup(BuildContext context) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final compactFieldHeight = 5.5.h;
  final compactTitleSize = 14.sp;
  final compactInputSize = 14.sp;

  final driverProvider = Provider.of<DriverProvider>(context, listen: false);
  driverProvider.getDriverUser(deviceId: "");

  // Controllers
  final nameCtrl = TextEditingController();
  final rfIdCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      int? selectedIndex;

      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.2.w, vertical: 1.8.h),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Consumer<DriverProvider>(
                builder: (context, driverProvider, child) {
                  if (driverProvider.isLoading) {
                    return SizedBox(
                      height: 20.h,
                      child: Center(child: AppLoadings.circleLoading()),
                    );
                  }
                  final drivers =
                      driverProvider.getDriverModel?.items.drivers.data ?? [];

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 11.w,
                            height: 11.w,
                            decoration: BoxDecoration(
                              color: AppColors.blueCyan
                                  .withValues(alpha: isDark ? .22 : .14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: AppColors.blueCyan,
                              size: 16.5.sp,
                            ),
                          ),
                        ),
                        verticalSpace(height: .6.h),

                        /// Title
                        Center(
                          child: Text(
                            "Edit Driver",
                            style: AppStyles.boldTextStyle(context).copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                        ),

                        verticalSpace(height: 1.1.h),

                        /// Dropdown Label
                        Text(
                          "Select Driver",
                          style: TextStyle(
                            fontSize: 13.2.sp,
                            fontWeight: FontWeight.w500,
                            color: onSurface,
                          ),
                        ),
                        verticalSpace(height: .6.h),

                        /// Driver Search (inline, no separate search box)
                        Autocomplete<int>(
                          optionsBuilder: (textEditingValue) {
                            final query =
                                textEditingValue.text.trim().toLowerCase();
                            final entries = drivers.asMap().entries;
                            if (query.isEmpty) {
                              return entries.map((e) => e.key);
                            }
                            return entries
                                .where((e) =>
                                    e.value.name.toLowerCase().contains(query))
                                .map((e) => e.key);
                          },
                          displayStringForOption: (index) =>
                              drivers[index].name,
                          fieldViewBuilder: (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            if (selectedIndex != null &&
                                textEditingController.text.isEmpty) {
                              textEditingController.text =
                                  drivers[selectedIndex!].name;
                            }
                            return Focus(
                              onFocusChange: (hasFocus) {
                                if (!hasFocus &&
                                    selectedIndex != null &&
                                    textEditingController.text.trim().isEmpty) {
                                  textEditingController.text =
                                      drivers[selectedIndex!].name;
                                }
                              },
                              child: TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                onTap: () {
                                  if (selectedIndex != null &&
                                      textEditingController.text ==
                                          drivers[selectedIndex!].name) {
                                    // Clear to reopen full list for quick scroll/select.
                                    textEditingController.clear();
                                  }
                                },
                                onTapOutside: (_) {
                                  FocusScope.of(context).unfocus();
                                },
                                style: TextStyle(
                                  fontSize: 13.6.sp,
                                  fontWeight: FontWeight.w500,
                                  color: onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Driver",
                                  labelStyle: TextStyle(
                                    fontSize: 13.8.sp,
                                    color: onSurface.withValues(alpha: .72),
                                  ),
                                  hintText: "Search and select driver",
                                  suffixIcon: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: onSurface.withValues(alpha: .7),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            final optionList = options.toList();
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  constraints: BoxConstraints(maxHeight: 28.h),
                                  width: 78.w,
                                  padding: EdgeInsets.symmetric(vertical: .4.h),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: optionList.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: onSurface.withValues(alpha: .08),
                                    ),
                                    itemBuilder: (context, i) {
                                      final optionIndex = optionList[i];
                                      return InkWell(
                                        onTap: () => onSelected(optionIndex),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 3.w,
                                            vertical: 1.1.h,
                                          ),
                                          child: Text(
                                            drivers[optionIndex].name,
                                            style: TextStyle(
                                              fontSize: 13.6.sp,
                                              fontWeight: FontWeight.w500,
                                              color: onSurface,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          onSelected: (index) {
                            setState(() {
                              selectedIndex = index;
                              final driver = drivers[index];

                              /// 🔥 AUTO FILL
                              nameCtrl.text = driver.name;
                              rfIdCtrl.text = driver.rfid;
                              phoneCtrl.text = driver.phone;
                              emailCtrl.text = driver.email;
                            });
                          },
                        ),

                        verticalSpace(height: .6.h),

                        /// Editable Fields
                        MaintenanceField(
                          title: "Driver Name",
                          hint: "Enter driver name",
                          controller: nameCtrl,
                          height: compactFieldHeight,
                          titleFontSize: compactTitleSize,
                          fieldFontSize: compactInputSize,
                          hintFontSize: compactInputSize,
                          titleBottomSpacing: .7.h,
                          inputVerticalPadding: 1.35.h,
                        ),
                        verticalSpace(height: .9.h),

                        MaintenanceField(
                          title: "RFID",
                          hint: "Enter RFID",
                          controller: rfIdCtrl,
                          height: compactFieldHeight,
                          titleFontSize: compactTitleSize,
                          fieldFontSize: compactInputSize,
                          hintFontSize: compactInputSize,
                          titleBottomSpacing: .7.h,
                          inputVerticalPadding: 1.35.h,
                        ),
                        verticalSpace(height: .9.h),

                        MaintenanceField(
                          title: "Phone",
                          hint: "03xxxxxxxxx",
                          controller: phoneCtrl,
                          height: compactFieldHeight,
                          titleFontSize: compactTitleSize,
                          fieldFontSize: compactInputSize,
                          hintFontSize: compactInputSize,
                          titleBottomSpacing: .7.h,
                          inputVerticalPadding: 1.35.h,
                        ),
                        verticalSpace(height: .9.h),

                        MaintenanceField(
                          title: "Email",
                          hint: "driver@email.com",
                          controller: emailCtrl,
                          height: compactFieldHeight,
                          titleFontSize: compactTitleSize,
                          fieldFontSize: compactInputSize,
                          hintFontSize: compactInputSize,
                          titleBottomSpacing: .7.h,
                          inputVerticalPadding: 1.35.h,
                        ),

                        verticalSpace(height: 1.2.h),

                        /// Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: "Cancel",
                                backgroundColor: Colors.transparent,
                                textColor: onSurface.withValues(alpha: .82),
                                height: 4.4.h,
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ),
                            horizontalSpace(width: 3.w),
                            Consumer<DriverProvider>(
                              builder: (context, driverProvider, child) =>
                                  driverProvider.isLoading
                                      ? AppLoadings.buttonLoading()
                                      : Expanded(
                                          child: CustomButton(
                                            text: "Update",
                                            height: 3.9.h,
                                            onPressed: () async {
                                              if (selectedIndex == null) {
                                                showValidationErrorDialog(
                                                  context,
                                                  message:
                                                      "Please select a driver",
                                                );
                                                return;
                                              }

                                              final driver =
                                                  drivers[selectedIndex!];

                                              await driverProvider.editDriver(
                                                driverId: driver.id.toString(),
                                                name: nameCtrl.text.trim(),
                                                rfid: rfIdCtrl.text.trim(),
                                                phone: phoneCtrl.text.trim(),
                                                email: emailCtrl.text.trim(),
                                                description: '',
                                              );
                                              if (!ctx.mounted) return;
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                        ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    },
  );
}

/// Delete Driver
Future<void> showDeleteDriverPopup(BuildContext context) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final driverProvider = Provider.of<DriverProvider>(context, listen: false);
  driverProvider.getDriverUser(deviceId: "");
  final ScrollController scrollController = ScrollController();
  bool canScrollUp = false;
  bool canScrollDown = false;
  bool scrollListenerAttached = false;
  bool isClosingDialog = false;
  String searchQuery = "";

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final Set<int> selectedDriverIds = {};

      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: StatefulBuilder(
            builder: (context, setState) {
              if (!scrollListenerAttached) {
                scrollListenerAttached = true;
                scrollController.addListener(() {
                  if (isClosingDialog) return;
                  if (!scrollController.hasClients) return;
                  final position = scrollController.position;
                  final nextCanScrollUp = position.pixels > 0.5;
                  final nextCanScrollDown =
                      position.pixels < (position.maxScrollExtent - 0.5);
                  if (nextCanScrollUp != canScrollUp ||
                      nextCanScrollDown != canScrollDown) {
                    setState(() {
                      canScrollUp = nextCanScrollUp;
                      canScrollDown = nextCanScrollDown;
                    });
                  }
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!scrollController.hasClients) return;
                  final position = scrollController.position;
                  setState(() {
                    canScrollUp = position.pixels > 0.5;
                    canScrollDown =
                        position.pixels < (position.maxScrollExtent - 0.5);
                  });
                });
              }

              return Consumer<DriverProvider>(
                builder: (context, driverProvider, child) {
                  if (driverProvider.isLoading) {
                    return SizedBox(
                      height: 20.h,
                      child: Center(child: AppLoadings.circleLoading()),
                    );
                  }

                  final drivers =
                      driverProvider.getDriverModel?.items.drivers.data ?? [];
                  final filteredDrivers = drivers.where((driver) {
                    if (searchQuery.trim().isEmpty) return true;
                    return driver.name
                        .toLowerCase()
                        .contains(searchQuery.trim().toLowerCase());
                  }).toList();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: BoxDecoration(
                            color: AppColors.red
                                .withValues(alpha: isDark ? .24 : .14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.delete_forever_rounded,
                            color: AppColors.red,
                            size: 17.sp,
                          ),
                        ),
                      ),
                      verticalSpace(height: .6.h),
                      Center(
                        child: Text(
                          "Delete Driver",
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      verticalSpace(height: 2.h),

                      Text(
                        "Select Drivers",
                        style: AppStyles.semiboldTextStyle(context).copyWith(
                          fontSize: 15.sp,
                        ),
                      ),

                      verticalSpace(height: .2.h),
                      Text(
                        "Use the checkbox to select multiple drivers",
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      verticalSpace(height: .8.h),
                      TextField(
                        onChanged: (value) {
                          if (isClosingDialog) return;
                          setState(() {
                            searchQuery = value;
                          });
                          if (scrollController.hasClients) {
                            scrollController.jumpTo(0);
                          }
                        },
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        style: TextStyle(
                          fontSize: 13.4.sp,
                          color: AppColors.textBlack,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search driver name",
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.grey.shade600,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.15.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      verticalSpace(height: 1.h),

                      /// 🔥 Driver List
                      SizedBox(
                        height: 31.h,
                        child: Stack(
                          children: [
                            if (filteredDrivers.isEmpty)
                              Center(
                                child: Text(
                                  "No drivers found",
                                  style: AppStyles.regularTextStyle(context)
                                      .copyWith(
                                    fontSize: 13.2.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                controller: scrollController,
                                itemCount: filteredDrivers.length,
                                itemBuilder: (context, index) {
                                  final driver = filteredDrivers[index];
                                  final isSelected =
                                      selectedDriverIds.contains(driver.id);

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 0.45.h),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 0.45.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.red
                                            : Colors.grey.shade200,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                driver.name,
                                                style:
                                                    AppStyles.semiboldTextStyle(
                                                            context)
                                                        .copyWith(
                                                  fontSize: 14.sp,
                                                  color: AppColors.textBlack,
                                                ),
                                              ),
                                              if (driver.phone.isNotEmpty)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: .3.h),
                                                  child: Text(
                                                    driver.phone,
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Checkbox(
                                          value: isSelected,
                                          activeColor: AppColors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedDriverIds
                                                    .add(driver.id);
                                              } else {
                                                selectedDriverIds
                                                    .remove(driver.id);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            if (canScrollUp)
                              Positioned(
                                top: .2.h,
                                left: 0,
                                right: 0,
                                child: IgnorePointer(
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3.w, vertical: .35.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: .92),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_up_rounded,
                                        color: Colors.grey.shade700,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (canScrollDown)
                              Positioned(
                                bottom: .2.h,
                                left: 0,
                                right: 0,
                                child: IgnorePointer(
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3.w, vertical: .35.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: .92),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.grey.shade700,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      /// Selected Count
                      if (selectedDriverIds.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 1.h),
                          child: Text(
                            "${selectedDriverIds.length} driver(s) selected",
                            style: TextStyle(
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      verticalSpace(height: 1.2.h),

                      /// Buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Cancel",
                              backgroundColor: Colors.transparent,
                              textColor: AppColors.textBlack,
                              height: 4.4.h,
                              onPressed: () {
                                isClosingDialog = true;
                                FocusManager.instance.primaryFocus?.unfocus();
                                Navigator.pop(ctx);
                              },
                            ),
                          ),
                          horizontalSpace(width: 3.w),
                          Expanded(
                            child: CustomButton(
                              backgroundColor: AppColors.red,
                              text: "Delete",
                              height: 4.5.h,
                              onPressed: () {
                                if (selectedDriverIds.isEmpty) {
                                  showValidationErrorDialog(
                                    context,
                                    message:
                                        "Please select at least one driver",
                                  );
                                  return;
                                }

                                isClosingDialog = true;
                                Navigator.pop(ctx);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );
    },
  );

  scrollController.dispose();
}

///IMMOBILIZER
Future<void> showDeviceCommandsPopup(
  BuildContext context,
  String deviceId,
) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

  final commandsProvider =
      Provider.of<GetDeviceCommandsProvider>(context, listen: false);

  unawaited(commandsProvider.getDeviceCommandMethod(deviceId: deviceId));

  GetDeviceCommandsModel? selectedCommand;
  final TextEditingController messageController = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        insetPadding: EdgeInsets.fromLTRB(7.w, 2.h, 7.w, 2.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Consumer<GetDeviceCommandsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return SizedBox(
                    height: 14.h,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppLoadings.circleLoading(),
                          verticalSpace(height: 1.0.h),
                          Text(
                            "Loading commands...",
                            style: AppStyles.regularTextStyle(context).copyWith(
                              fontSize: 13.5.sp,
                              color: onSurface.withValues(alpha: .68),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final commands =
                    (provider.getDeviceCommands ?? []).where((cmd) {
                  final title = cmd.title.toLowerCase();
                  return title != 'engine stop' && title != 'engine resume';
                }).toList();

                if (commands.isEmpty) {
                  return SizedBox(
                    height: 22.h,
                    child: Center(
                      child: Text(
                        "No commands available",
                        style: AppStyles.regularTextStyle(context),
                      ),
                    ),
                  );
                }

                final selectedTitle =
                    selectedCommand?.title.toLowerCase() ?? '';
                final isCustomSelected = selectedTitle.contains('custom') ||
                    selectedTitle == 'custom';

                final canSend = selectedCommand != null &&
                    (!isCustomSelected ||
                        messageController.text.trim().isNotEmpty);

                final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

                return Padding(
                  padding: EdgeInsets.only(bottom: keyboardInset),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(4.5.w, 2.0.h, 4.5.w, 1.7.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 4.6.h,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: -.6.h,
                                  right: -1.w,
                                  child: Icon(
                                    Icons.electric_bolt_rounded,
                                    color: ConstantColor.primaryColor
                                        .withValues(alpha: isDark ? 0.22 : 0.16),
                                    size: 6.2.h,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Immobilizer",
                                    style: AppStyles.boldTextStyle(context)
                                        .copyWith(
                                      fontSize: 16.2.sp,
                                      fontWeight: FontWeight.w700,
                                      color: onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          verticalSpace(height: .45.h),
                          Text(
                            "Select and send command",
                            style: AppStyles.regularTextStyle(context).copyWith(
                              color: onSurface.withValues(alpha: .62),
                              fontSize: 12.8.sp,
                            ),
                          ),
                          verticalSpace(height: 1.4.h),
                          Text(
                            "Select Command",
                            style:
                                AppStyles.semiboldTextStyle(context).copyWith(
                              fontSize: 14.4.sp,
                              color: onSurface.withValues(alpha: .88),
                            ),
                          ),
                          verticalSpace(height: .8.h),
                          ...commands.map((command) {
                            final isSelected =
                                selectedCommand?.type == command.type &&
                                    selectedCommand?.title == command.title;
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  selectedCommand = command;
                                  final t = command.title.toLowerCase();
                                  if (!(t.contains('custom') ||
                                      t == 'custom')) {
                                    messageController.clear();
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                margin: EdgeInsets.only(bottom: .75.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.8.w, vertical: 1.1.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? ConstantColor.primaryColor
                                          .withValues(alpha: .12)
                                      : (isDark
                                          ? Colors.white.withValues(alpha: .04)
                                          : Colors.black.withValues(alpha: .02)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? ConstantColor.primaryColor
                                            .withValues(alpha: .7)
                                        : (isDark
                                            ? Colors.white10
                                            : Colors.black12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      size: 17.sp,
                                      color: isSelected
                                          ? ConstantColor.primaryColor
                                          : onSurface.withValues(alpha: .44),
                                    ),
                                    horizontalSpace(width: 2.1.w),
                                    Expanded(
                                      child: Text(
                                        command.title,
                                        style:
                                            AppStyles.regularTextStyle(context)
                                                .copyWith(
                                          fontSize: 13.8.sp,
                                          color: onSurface.withValues(alpha: .88),
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          if (isCustomSelected) ...[
                            verticalSpace(height: .8.h),
                            Text(
                              "Message",
                              style:
                                  AppStyles.semiboldTextStyle(context).copyWith(
                                fontSize: 14.2.sp,
                              ),
                            ),
                            verticalSpace(height: .55.h),
                            TextField(
                              controller: messageController,
                              maxLines: 1,
                              minLines: 1,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: "Enter custom command message",
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withValues(alpha: .05)
                                    : Colors.black.withValues(alpha: .02),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: onSurface.withValues(alpha: .15)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: onSurface.withValues(alpha: .15)),
                                ),
                              ),
                            ),
                          ],
                          verticalSpace(height: 1.9.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: "Cancel",
                                  backgroundColor: Colors.transparent,
                                  textColor: onSurface.withValues(alpha: .82),
                                  height: 4.4.h,
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                              ),
                              horizontalSpace(width: 3.w),
                              Expanded(
                                child: CustomButton(
                                  text: "Send",
                                  backgroundColor: ConstantColor.primaryColor,
                                  height: 4.4.h,
                                  onPressed: !canSend
                                      ? null
                                      : () {
                                          provider.sendDeviceCommandMethod(
                                            deviceId: deviceId,
                                            commandType:
                                                selectedCommand?.type ?? "",
                                          );
                                          Navigator.pop(ctx);
                                        },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );
}

/// Add Expense Popup
Future<void> showAddExpensePopup(BuildContext context) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final compactFieldHeight = 4.4.h;
  final compactTitleSize = 13.6.sp;
  final compactInputSize = 13.2.sp;

  // Controllers
  final amountCtrl = TextEditingController();
  final supplierCtrl = TextEditingController();
  final buyerCtrl = TextEditingController();
  final otherCategoryCtrl = TextEditingController();
  final otherDeviceCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  String? selectedCategory;
  String? selectedDeviceType;
  DateTime? expenseDate;
  TimeOfDay? expenseTime;

  // Lists
  final expenseCategories = [
    "Fuel",
    "Maintenance",
    "Insurance",
    "Registration",
    "Parking",
    "Toll",
    "Fine",
    "Other",
  ];

  final deviceTypes = [
    "GPS Tracker",
    "OBD Device",
    "Fuel Sensor",
    "Temperature Sensor",
    "Dash Camera",
    "Other",
  ];

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.2.w, vertical: 1.6.h),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 4.8.h,
                      child: Stack(
                        children: [
                          Positioned(
                            top: -.6.h,
                            right: -1.w,
                            child: Icon(
                              Icons.attach_money_rounded,
                              color: AppColors.green
                                  .withValues(alpha: isDark ? 0.22 : 0.16),
                              size: 6.2.h,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Add Expense",
                              style: AppStyles.boldTextStyle(context).copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpace(height: .4.h),

                    Text(
                      "Category",
                      style: TextStyle(
                          fontSize: compactTitleSize,
                          fontWeight: FontWeight.w500,
                          color: onSurface),
                    ),
                    verticalSpace(height: .65.h),
                    SizedBox(
                      height: compactFieldHeight,
                      child: DropdownButtonFormField<String>(
                        isDense: true,
                        initialValue: selectedCategory,
                        style: TextStyle(
                          fontSize: compactInputSize,
                          color: onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        hint: Text(
                          "Select category",
                          style: TextStyle(
                            fontSize: compactInputSize,
                            color: onSurface.withValues(alpha: .58),
                          ),
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: .7.h),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: expenseCategories
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => selectedCategory = v);
                          if (v != "Other") otherCategoryCtrl.clear();
                        },
                      ),
                    ),
                    verticalSpace(height: 1.0.h),
                    if (selectedCategory == "Other") ...[
                      MaintenanceField(
                        title: "Specify Category",
                        hint: "Enter other category",
                        controller: otherCategoryCtrl,
                        height: compactFieldHeight,
                        titleFontSize: compactTitleSize,
                        fieldFontSize: compactInputSize,
                        hintFontSize: compactInputSize,
                        titleBottomSpacing: .65.h,
                        inputVerticalPadding: 1.0.h,
                      ),
                      verticalSpace(height: 1.0.h),
                    ],

                    // Amount
                    MaintenanceField(
                      title: "Amount (Rs)",
                      hint: "0",
                      controller: amountCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                    ),
                    verticalSpace(height: 1.0.h),

                    // Date & Time in one responsive row
                    Row(
                      children: [
                        Expanded(
                          child: MaintenanceField(
                            title: "Expense Date",
                            hint: expenseDate == null
                                ? "Pick date"
                                : "${expenseDate!.day}/${expenseDate!.month}/${expenseDate!.year}",
                            height: compactFieldHeight,
                            titleFontSize: compactTitleSize,
                            fieldFontSize: compactInputSize,
                            hintFontSize: compactInputSize,
                            titleBottomSpacing: .65.h,
                            inputVerticalPadding: 1.0.h,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                                initialDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => expenseDate = date);
                              }
                            },
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: MaintenanceField(
                            title: "Expense Time",
                            hint: expenseTime == null
                                ? "Pick time"
                                : expenseTime!.format(context),
                            height: compactFieldHeight,
                            titleFontSize: compactTitleSize,
                            fieldFontSize: compactInputSize,
                            hintFontSize: compactInputSize,
                            titleBottomSpacing: .65.h,
                            inputVerticalPadding: 1.0.h,
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() => expenseTime = time);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.0.h),

                    // Supplier & Buyer in one responsive row
                    Row(
                      children: [
                        Expanded(
                          child: MaintenanceField(
                            title: "Supplier",
                            hint: "Shell, PSO, etc.",
                            controller: supplierCtrl,
                            height: compactFieldHeight,
                            titleFontSize: compactTitleSize,
                            fieldFontSize: compactInputSize,
                            hintFontSize: compactInputSize,
                            titleBottomSpacing: .65.h,
                            inputVerticalPadding: 1.0.h,
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: MaintenanceField(
                            title: "Buyer",
                            hint: "Enter buyer name",
                            controller: buyerCtrl,
                            height: compactFieldHeight,
                            titleFontSize: compactTitleSize,
                            fieldFontSize: compactInputSize,
                            hintFontSize: compactInputSize,
                            titleBottomSpacing: .65.h,
                            inputVerticalPadding: 1.0.h,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.0.h),

                    // Device Type Dropdown (full width)
                    Text(
                      "Device Type",
                      style: TextStyle(
                          fontSize: compactTitleSize,
                          fontWeight: FontWeight.w500,
                          color: onSurface),
                    ),
                    verticalSpace(height: .65.h),
                    SizedBox(
                      height: compactFieldHeight,
                      child: DropdownButtonFormField<String>(
                        isDense: true,
                        initialValue: selectedDeviceType,
                        style: TextStyle(
                          fontSize: compactInputSize,
                          color: onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        hint: Text(
                          "Select device type",
                          style: TextStyle(
                            fontSize: compactInputSize,
                            color: onSurface.withValues(alpha: .58),
                          ),
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: .7.h),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: deviceTypes
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => selectedDeviceType = v);
                          if (v != "Other") otherDeviceCtrl.clear();
                        },
                      ),
                    ),
                    verticalSpace(height: 1.0.h),

                    if (selectedDeviceType == "Other") ...[
                      MaintenanceField(
                        title: "Specify Device Type",
                        hint: "Enter other device type",
                        controller: otherDeviceCtrl,
                        height: compactFieldHeight,
                        titleFontSize: compactTitleSize,
                        fieldFontSize: compactInputSize,
                        hintFontSize: compactInputSize,
                        titleBottomSpacing: .65.h,
                        inputVerticalPadding: 1.0.h,
                      ),
                      verticalSpace(height: 1.0.h),
                    ],

                    // Description
                    MaintenanceField(
                      title: "Description",
                      hint: "Optional notes",
                      controller: notesCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                    ),
                    verticalSpace(height: 1.0.h),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            backgroundColor: Colors.transparent,
                            textColor: onSurface.withValues(alpha: .82),
                            height: 4.4.h,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: CustomButton(
                            text: "Save",
                            height: 4.4.h,
                            onPressed: () {
                              // Final category handling
                              String finalCategory = selectedCategory == "Other"
                                  ? otherCategoryCtrl.text.trim().isEmpty
                                      ? "Other"
                                      : otherCategoryCtrl.text.trim()
                                  : selectedCategory ?? "Not selected";

                              // Final device type handling
                              String finalDeviceType =
                                  selectedDeviceType == "Other"
                                      ? otherDeviceCtrl.text.trim().isEmpty
                                          ? "Other"
                                          : otherDeviceCtrl.text.trim()
                                      : selectedDeviceType ?? "Not selected";

                              debugPrint(
                                  "Add Expense - Category: $finalCategory");
                              debugPrint(
                                  "Add Expense - Amount: ${amountCtrl.text}");
                              debugPrint("Add Expense - Date: $expenseDate");
                              debugPrint("Add Expense - Time: $expenseTime");
                              debugPrint(
                                  "Add Expense - Supplier: ${supplierCtrl.text}");
                              debugPrint(
                                  "Add Expense - Buyer: ${buyerCtrl.text}");
                              debugPrint(
                                  "Add Expense - Device Type: $finalDeviceType");
                              debugPrint(
                                  "Add Expense - Notes: ${notesCtrl.text}");
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

/// Add Maintenance Popup
Future<void> showAddMaintenancePopup(BuildContext context) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final compactFieldHeight = 4.4.h;
  final compactTitleSize = 13.6.sp;
  final compactInputSize = 13.2.sp;

  // Input controllers
  final nameCtrl = TextEditingController();
  final intervalCtrl = TextEditingController();
  final lastServiceCtrl = TextEditingController();
  final triggerLeftCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final String currentOdometer = "-";
  final String currentEngineHours = "808.32";

  String? expirationBy = "Odometer";
  bool renewAfterExpiration = false;

  final expirationOptions = ["Odometer", "Engine Hours", "Date"];

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.2.w, vertical: 1.6.h),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 4.8.h,
                      child: Stack(
                        children: [
                          Positioned(
                            top: -.6.h,
                            right: -1.w,
                            child: Icon(
                              Icons.build_circle_outlined,
                              color: AppColors.yellow
                                  .withValues(alpha: isDark ? 0.22 : 0.16),
                              size: 6.2.h,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Add Service",
                              style: AppStyles.boldTextStyle(context).copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpace(height: .4.h),

                    MaintenanceField(
                      title: "Name",
                      hint: "Enter service name",
                      controller: nameCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                    ),
                    verticalSpace(height: 1.0.h),

                    Text(
                      "Expiration by",
                      style: TextStyle(
                          fontSize: compactTitleSize,
                          fontWeight: FontWeight.w500,
                          color: onSurface),
                    ),
                    verticalSpace(height: 0.65.h),
                    SizedBox(
                      height: compactFieldHeight,
                      child: DropdownButtonFormField<String>(
                        isDense: true,
                        initialValue: expirationBy,
                        style: TextStyle(
                          fontSize: compactInputSize,
                          color: onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        hint: Text(
                          "Select expiration type",
                          style: TextStyle(
                            fontSize: compactInputSize,
                            color: onSurface.withValues(alpha: .58),
                          ),
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: .7.h),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: expirationOptions
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      fontSize: compactInputSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => expirationBy = v),
                      ),
                    ),
                    verticalSpace(height: 1.0.h),
                    Row(
                      children: [
                        Expanded(
                          child: MaintenanceField(
                            title: "Interval",
                            hint: "Enter interval",
                            controller: intervalCtrl,
                            height: compactFieldHeight,
                            titleFontSize: compactTitleSize,
                            fieldFontSize: compactInputSize,
                            hintFontSize: compactInputSize,
                            titleBottomSpacing: .65.h,
                            inputVerticalPadding: 1.0.h,
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: MaintenanceField(
                            title: "Last service",
                            hint: "Enter last value/date",
                            controller: lastServiceCtrl,
                            height: compactFieldHeight,
                            titleFontSize: compactTitleSize,
                            fieldFontSize: compactInputSize,
                            hintFontSize: compactInputSize,
                            titleBottomSpacing: .65.h,
                            inputVerticalPadding: 1.0.h,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.0.h),

                    MaintenanceField(
                      title: "Trigger event when left",
                      hint: "e.g. 1000 km",
                      controller: triggerLeftCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                    ),
                    verticalSpace(height: 1.0.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Renew after expiration",
                          style: TextStyle(
                              fontSize: 13.6.sp,
                              fontWeight: FontWeight.w500,
                              color: onSurface),
                        ),
                        SizedBox(
                          height: 4.4.h,
                          width: 10.w,
                          child: Checkbox(
                            value: renewAfterExpiration,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) => setState(
                              () => renewAfterExpiration = val ?? false,
                            ),
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: .95.h),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Odometer",
                                style: TextStyle(
                                    fontSize: compactTitleSize,
                                    fontWeight: FontWeight.w500,
                                    color: onSurface),
                              ),
                              verticalSpace(height: 0.65.h),
                              Container(
                                height: compactFieldHeight,
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                decoration: BoxDecoration(
                                  color: theme.cardColor.withValues(alpha: .6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: theme.dividerColor
                                          .withValues(alpha: .4)),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  currentOdometer,
                                  style: TextStyle(
                                      fontSize: compactInputSize,
                                      color: onSurface.withValues(alpha: .8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Engine hours",
                                style: TextStyle(
                                    fontSize: compactTitleSize,
                                    fontWeight: FontWeight.w500,
                                    color: onSurface),
                              ),
                              verticalSpace(height: 0.65.h),
                              Container(
                                height: compactFieldHeight,
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                decoration: BoxDecoration(
                                  color: theme.cardColor.withValues(alpha: .6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: theme.dividerColor
                                          .withValues(alpha: .4)),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  currentEngineHours,
                                  style: TextStyle(
                                      fontSize: compactInputSize,
                                      color: onSurface.withValues(alpha: .8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.0.h),

                    MaintenanceField(
                      title: "Description",
                      hint: "Optional notes",
                      controller: descriptionCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                    ),
                    verticalSpace(height: 1.0.h),

                    MaintenanceField(
                      title: "Email",
                      hint: "notification@email.com",
                      controller: emailCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                    ),
                    verticalSpace(height: 1.1.h),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            backgroundColor: Colors.transparent,
                            textColor: onSurface.withValues(alpha: .82),
                            height: 4.4.h,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: CustomButton(
                            text: "Save",
                            height: 4.4.h,
                            onPressed: () {
                              debugPrint(
                                  "Add Service - Name: ${nameCtrl.text}");
                              debugPrint(
                                  "Add Service - Expiration by: $expirationBy");
                              debugPrint(
                                  "Add Service - Interval: ${intervalCtrl.text}");
                              debugPrint(
                                  "Add Service - Last service: ${lastServiceCtrl.text}");
                              debugPrint(
                                  "Add Service - Trigger when left: ${triggerLeftCtrl.text}");
                              debugPrint(
                                  "Add Service - Renew after expiration: $renewAfterExpiration");
                              debugPrint(
                                  "Add Service - Current odometer: $currentOdometer");
                              debugPrint(
                                  "Add Service - Current engine hours: $currentEngineHours");
                              debugPrint(
                                  "Add Service - Description: ${descriptionCtrl.text}");
                              debugPrint(
                                  "Add Service - Email: ${emailCtrl.text}");
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

/// Assign Driver Popup
Future<void> showAssignDriverPopup(
    BuildContext context, String deviceId) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final compactFieldHeight = 4.4.h;
  TextEditingController? driverSearchController;
  const int noDriverOptionIndex = -1;
  const String noDriverLabel = "No Driver";

  final driverProvider = Provider.of<DriverProvider>(context, listen: false);
  driverProvider.getDriverUser(deviceId: "");

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      int? selectedIndex;
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.2.w, vertical: 1.8.h),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Consumer<DriverProvider>(
                builder: (context, driverProvider, child) {
                  if (driverProvider.isLoading) {
                    return SizedBox(
                      height: 20.h,
                      child: Center(child: AppLoadings.circleLoading()),
                    );
                  }
                  final drivers =
                      driverProvider.getDriverModel?.items.drivers.data ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 4.6.h,
                        child: Stack(
                          children: [
                            Positioned(
                              top: -.6.h,
                              right: -1.w,
                              child: Icon(
                                Icons.person_add_alt_1_rounded,
                                color: AppColors.blueCyan
                                    .withValues(alpha: isDark ? 0.22 : 0.16),
                                size: 6.2.h,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Assign Driver",
                                style:
                                    AppStyles.boldTextStyle(context).copyWith(
                                  fontSize: 16.2.sp,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      verticalSpace(height: .45.h),
                      Text(
                        "Select Driver",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: onSurface,
                        ),
                      ),
                      verticalSpace(height: .65.h),
                      Autocomplete<int>(
                        optionsBuilder: (textEditingValue) {
                          final query =
                              textEditingValue.text.trim().toLowerCase();
                          final entries = drivers.asMap().entries;
                          if (query.isEmpty) {
                            return [
                              noDriverOptionIndex,
                              ...entries.map((e) => e.key),
                            ];
                          }
                          final options = <int>[];
                          if (noDriverLabel.toLowerCase().contains(query)) {
                            options.add(noDriverOptionIndex);
                          }
                          options.addAll(entries
                              .where((e) =>
                                  e.value.name.toLowerCase().contains(query))
                              .map((e) => e.key));
                          return options;
                        },
                        displayStringForOption: (index) {
                          if (index == noDriverOptionIndex) {
                            return noDriverLabel;
                          }
                          return drivers[index].name;
                        },
                        fieldViewBuilder: (
                          context,
                          textEditingController,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          driverSearchController = textEditingController;
                          if (selectedIndex != null &&
                              textEditingController.text.isEmpty) {
                            textEditingController.text =
                                selectedIndex == noDriverOptionIndex
                                    ? noDriverLabel
                                    : drivers[selectedIndex!].name;
                          }
                          return SizedBox(
                            height: compactFieldHeight,
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                if (!hasFocus &&
                                    selectedIndex != null &&
                                    textEditingController.text.trim().isEmpty) {
                                  textEditingController.text =
                                      drivers[selectedIndex!].name;
                                }
                              },
                              child: TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                onTap: () {
                                  if (selectedIndex != null &&
                                      textEditingController.text ==
                                          (selectedIndex == noDriverOptionIndex
                                              ? noDriverLabel
                                              : drivers[selectedIndex!].name)) {
                                    textEditingController.clear();
                                  }
                                },
                                onTapOutside: (_) {
                                  FocusScope.of(context).unfocus();
                                },
                                style: TextStyle(
                                  fontSize: 14.2.sp,
                                  fontWeight: FontWeight.w500,
                                  color: onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Driver",
                                  labelStyle: TextStyle(
                                    fontSize: 12.8.sp,
                                    color: onSurface.withValues(alpha: .72),
                                  ),
                                  hintText: "Search and select driver",
                                  hintStyle: TextStyle(
                                    fontSize: 12.6.sp,
                                    color: onSurface.withValues(alpha: .58),
                                  ),
                                  suffixIcon: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: onSurface.withValues(alpha: .7),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: .7.h),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          final optionList = options.toList();
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                constraints: BoxConstraints(maxHeight: 28.h),
                                width: 79.w,
                                padding: EdgeInsets.symmetric(vertical: .4.h),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: optionList.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    color: onSurface.withValues(alpha: .08),
                                  ),
                                  itemBuilder: (context, i) {
                                    final optionIndex = optionList[i];
                                    return InkWell(
                                      onTap: () => onSelected(optionIndex),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 3.w,
                                          vertical: 1.1.h,
                                        ),
                                        child: Text(
                                          optionIndex == noDriverOptionIndex
                                              ? noDriverLabel
                                              : drivers[optionIndex].name,
                                          style: TextStyle(
                                            fontSize: 14.2.sp,
                                            fontWeight: FontWeight.w500,
                                            color: onSurface,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        onSelected: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      ),
                      verticalSpace(height: 1.3.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Cancel",
                              backgroundColor: Colors.transparent,
                              textColor: onSurface.withValues(alpha: .82),
                              height: 4.4.h,
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ),
                          horizontalSpace(width: 3.w),
                          Consumer<DriverProvider>(
                            builder: (context, driverProvider, chile) =>
                                driverProvider.isLoading
                                    ? AppLoadings.buttonLoading()
                                    : Expanded(
                                        child: CustomButton(
                                          text: "Save",
                                          textColor: Colors.white,
                                          height: 4.4.h,
                                          onPressed: () async {
                                            Datum? selectedDriver;
                                            bool unassignSelected = false;

                                            if (selectedIndex ==
                                                noDriverOptionIndex) {
                                              unassignSelected = true;
                                            } else if (selectedIndex != null &&
                                                selectedIndex! >= 0 &&
                                                selectedIndex! <
                                                    drivers.length) {
                                              selectedDriver =
                                                  drivers[selectedIndex!];
                                            }

                                            final typedName =
                                                driverSearchController?.text
                                                        .trim()
                                                        .toLowerCase() ??
                                                    '';
                                            if (!unassignSelected &&
                                                typedName ==
                                                    noDriverLabel
                                                        .toLowerCase()) {
                                              unassignSelected = true;
                                            }

                                            if (!unassignSelected &&
                                                selectedDriver == null &&
                                                typedName.isNotEmpty) {
                                              final exactMatches = drivers
                                                  .where((d) =>
                                                      d.name
                                                          .trim()
                                                          .toLowerCase() ==
                                                      typedName)
                                                  .toList();
                                              if (exactMatches.isNotEmpty) {
                                                selectedDriver =
                                                    exactMatches.first;
                                              } else {
                                                final partialMatches = drivers
                                                    .where((d) => d.name
                                                        .toLowerCase()
                                                        .contains(typedName))
                                                    .toList();
                                                if (partialMatches.length ==
                                                    1) {
                                                  selectedDriver =
                                                      partialMatches.first;
                                                }
                                              }
                                            }

                                            if (selectedDriver != null ||
                                                unassignSelected) {
                                              final driverIdToSend =
                                                  unassignSelected
                                                      ? null
                                                      : selectedDriver!.id
                                                          .toString();
                                              debugPrint(
                                                  "✅ Assign Driver action for device: $deviceId, driverId: ${driverIdToSend ?? "none"}");
                                              await driverProvider.assignDriver(
                                                driverId: driverIdToSend,
                                                deviceId: deviceId,
                                              );
                                              await driverProvider
                                                  .getDriverUser(
                                                      deviceId: deviceId);
                                              if (!ctx.mounted) return;
                                              Navigator.pop(
                                                  ctx, selectedDriver);
                                            } else {
                                              showValidationErrorDialog(
                                                context,
                                                message:
                                                    "Please select a driver",
                                              );
                                            }
                                          },
                                        ),
                                      ),
                          )
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );
    },
  );
}

/// Add Reminder Popup
Future<void> showAddReminderPopup(
  BuildContext context, {
  required int deviceId,
  required String vehicleName,
  LocalReminder? existingReminder,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final compactFieldHeight = 4.4.h;
  final compactTitleSize = 13.6.sp;
  final compactInputSize = 13.2.sp;
  final titleCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  String? selectedReminderType = 'Custom';
  DateTime? reminderDueDate;
  TimeOfDay? reminderDueTime;
  bool isRecurring = false;
  String recurringMode = "daily";
  final reminderTypes = [
    'Custom',
    'Oil Change',
    'Tire Rotation',
    'Brake Inspection',
    'Air Filter Replacement',
    'Spark Plugs Replacement',
    'Battery Check',
    'Insurance Renewal',
    'Registration Renewal',
    'Emission Test',
    'General Service',
    'Coolant Flush',
  ];

  Future<DateTime?> pickReminderDate(DateTime? initial) async {
    DateTime tempDate = initial ?? DateTime.now();

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final pickerIsDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: pickerIsDark ? const Color(0xFF1A2433) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 1.h, bottom: .6.h),
                width: 10.w,
                height: .45.h,
                decoration: BoxDecoration(
                  color: pickerIsDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    const Spacer(),
                    Text(
                      "Select Date",
                      style: AppStyles.semiboldTextStyle(ctx)
                          .copyWith(fontSize: 14.sp),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, tempDate),
                      child: Text(
                        "Done",
                        style: TextStyle(color: ConstantColor.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate,
                  minimumDate: DateTime(2020),
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (value) => tempDate = value,
                ),
              ),
            ],
          ),
        );
      },
    );

    return result;
  }

  Future<TimeOfDay?> pickReminderTime(TimeOfDay? initial) async {
    final now = DateTime.now();
    DateTime tempTime = DateTime(
      now.year,
      now.month,
      now.day,
      initial?.hour ?? now.hour,
      initial?.minute ?? now.minute,
    );

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final pickerIsDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: 34.h,
          decoration: BoxDecoration(
            color: pickerIsDark ? const Color(0xFF1A2433) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 1.h, bottom: .6.h),
                width: 10.w,
                height: .45.h,
                decoration: BoxDecoration(
                  color: pickerIsDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    const Spacer(),
                    Text(
                      "Select Time",
                      style: AppStyles.semiboldTextStyle(ctx)
                          .copyWith(fontSize: 14.sp),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, tempTime),
                      child: Text(
                        "Done",
                        style: TextStyle(color: ConstantColor.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: tempTime,
                  use24hFormat: true,
                  onDateTimeChanged: (value) => tempTime = value,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return null;
    return TimeOfDay(hour: result.hour, minute: result.minute);
  }

  if (existingReminder != null) {
    titleCtrl.text = existingReminder.title;
    notesCtrl.text = existingReminder.description;
    selectedReminderType = existingReminder.type;
    reminderDueDate = existingReminder.dueAt;
    reminderDueTime = TimeOfDay.fromDateTime(existingReminder.dueAt);
    isRecurring = existingReminder.isRecurring;
    recurringMode = existingReminder.repeatType == "none"
        ? "daily"
        : existingReminder.repeatType;
    if (!reminderTypes.contains(selectedReminderType)) {
      selectedReminderType = 'Custom';
    }
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.2.w, vertical: 1.8.h),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 4.8.h,
                      child: Stack(
                        children: [
                          Positioned(
                            top: -.6.h,
                            right: -1.w,
                            child: Icon(
                              Icons.notifications_active_outlined,
                              color: AppColors.blueCyan
                                  .withValues(alpha: isDark ? 0.22 : 0.16),
                              size: 6.2.h,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              existingReminder == null
                                  ? "Add Reminder"
                                  : "Edit Reminder",
                              style: AppStyles.boldTextStyle(context).copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpace(height: .4.h),

                    // Type label and dropdown
                    Text(
                      "Type",
                      style: TextStyle(
                          fontSize: compactTitleSize,
                          fontWeight: FontWeight.w500,
                          color: onSurface),
                    ),
                    verticalSpace(height: 0.65.h),
                    SizedBox(
                      height: compactFieldHeight,
                      child: DropdownButtonFormField<String>(
                        isDense: true,
                        initialValue: selectedReminderType,
                        style: TextStyle(
                          fontSize: compactInputSize,
                          color: onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        hint: Text(
                          "Select type",
                          style: TextStyle(
                            fontSize: compactInputSize,
                            color: onSurface.withValues(alpha: .58),
                          ),
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: .7.h),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: reminderTypes
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: TextStyle(
                                      fontSize: compactInputSize,
                                      fontWeight: FontWeight.w500,
                                    ))))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedReminderType = v;
                            if (v != null && v != 'Custom') {
                              titleCtrl.text = v;
                            }
                          });
                        },
                      ),
                    ),
                    verticalSpace(height: 1.0.h),

                    // Title field
                    MaintenanceField(
                      title: "Title",
                      hint: "Reminder title",
                      controller: titleCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                    ),
                    verticalSpace(height: 1.0.h),

                    if (!(isRecurring && recurringMode == "daily"))
                      MaintenanceField(
                        title: "Due Date",
                        hint: reminderDueDate == null
                            ? "dd/mm/yyyy"
                            : "${reminderDueDate!.day.toString().padLeft(2, '0')}/${reminderDueDate!.month.toString().padLeft(2, '0')}/${reminderDueDate!.year}",
                        height: compactFieldHeight,
                        titleFontSize: compactTitleSize,
                        fieldFontSize: compactInputSize,
                        hintFontSize: compactInputSize,
                        titleBottomSpacing: .65.h,
                        inputVerticalPadding: 1.0.h,
                        onTap: () async {
                          final date = await pickReminderDate(reminderDueDate);
                          if (date != null) {
                            setState(() => reminderDueDate = date);
                          }
                        },
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Date is ignored for daily repeat",
                          style: AppStyles.regularTextStyle(context).copyWith(
                            fontSize: 11.4.sp,
                            color: onSurface.withValues(alpha: .65),
                          ),
                        ),
                      ),
                    verticalSpace(height: 1.0.h),

                    MaintenanceField(
                      title: "Due Time",
                      hint: reminderDueTime == null
                          ? "Select time"
                          : reminderDueTime!.format(context),
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                      onTap: () async {
                        final time = await pickReminderTime(reminderDueTime);
                        if (time != null) {
                          setState(() => reminderDueTime = time);
                        }
                      },
                    ),
                    verticalSpace(height: 1.0.h),

                    // Recurring switch
                    Row(
                      children: [
                        Icon(Icons.loop, color: onSurface),
                        horizontalSpace(width: 2.w),
                        Text(
                          "Recurring",
                          style: TextStyle(
                              fontSize: compactTitleSize,
                              fontWeight: FontWeight.w500,
                              color: onSurface),
                        ),
                        const Spacer(),
                        Switch(
                          value: isRecurring,
                          onChanged: (val) => setState(() => isRecurring = val),
                        ),
                      ],
                    ),
                    if (isRecurring) ...[
                      verticalSpace(height: .3.h),
                      Row(
                        children: [
                          _RecurringCheck(
                            label: "Daily",
                            selected: recurringMode == "daily",
                            onTap: () =>
                                setState(() => recurringMode = "daily"),
                          ),
                          _RecurringCheck(
                            label: "Weekly",
                            selected: recurringMode == "weekly",
                            onTap: () =>
                                setState(() => recurringMode = "weekly"),
                          ),
                        ],
                      ),
                      verticalSpace(height: .45.h),
                      Row(
                        children: [
                          _RecurringCheck(
                            label: "Monthly",
                            selected: recurringMode == "monthly",
                            onTap: () =>
                                setState(() => recurringMode = "monthly"),
                          ),
                          _RecurringCheck(
                            label: "Yearly",
                            selected: recurringMode == "yearly",
                            onTap: () =>
                                setState(() => recurringMode = "yearly"),
                          ),
                        ],
                      ),
                      verticalSpace(height: .55.h),
                    ],
                    verticalSpace(height: 1.0.h),

                    // Optional description
                    MaintenanceField(
                      title: "Description",
                      hint: "Optional notes",
                      controller: notesCtrl,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                    ),
                    verticalSpace(height: 1.0.h),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            backgroundColor: Colors.transparent,
                            textColor: onSurface.withValues(alpha: .82),
                            height: 4.4.h,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: CustomButton(
                            text: existingReminder == null
                                ? "Add Reminder"
                                : "Save Changes",
                            height: 4.4.h,
                            onPressed: () async {
                              if (titleCtrl.text.trim().isEmpty) {
                                showValidationErrorDialog(
                                  context,
                                  message: "Reminder title is required",
                                );
                                return;
                              }
                              if (reminderDueDate == null) {
                                if (!isRecurring || recurringMode != "daily") {
                                  showValidationErrorDialog(
                                    context,
                                    message: "Please select due date",
                                  );
                                  return;
                                }
                              }
                              if (reminderDueTime == null) {
                                showValidationErrorDialog(
                                  context,
                                  message: "Please select due time",
                                );
                                return;
                              }

                              final dateBase =
                                  reminderDueDate ?? DateTime.now();
                              final dueDateTime = DateTime(
                                dateBase.year,
                                dateBase.month,
                                dateBase.day,
                                reminderDueTime!.hour,
                                reminderDueTime!.minute,
                              );

                              if (existingReminder == null) {
                                await context
                                    .read<ReminderProvider>()
                                    .addReminder(
                                      deviceId: deviceId,
                                      vehicleName: vehicleName,
                                      title: titleCtrl.text,
                                      type: selectedReminderType ?? "Custom",
                                      description: notesCtrl.text,
                                      dueAt: dueDateTime,
                                      repeatType:
                                          isRecurring ? recurringMode : "none",
                                    );
                              } else {
                                await context
                                    .read<ReminderProvider>()
                                    .updateReminder(
                                      reminderId: existingReminder.id,
                                      deviceId: deviceId,
                                      vehicleName: vehicleName,
                                      title: titleCtrl.text,
                                      type: selectedReminderType ?? "Custom",
                                      description: notesCtrl.text,
                                      dueAt: dueDateTime,
                                      repeatType:
                                          isRecurring ? recurringMode : "none",
                                    );
                              }

                              if (!context.mounted) return;
                              Navigator.pop(ctx);
                              AppSnackBar.success(
                                message: existingReminder == null
                                    ? "Reminder saved successfully"
                                    : "Reminder updated successfully",
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

class _RecurringCheck extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RecurringCheck({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: selected,
                onChanged: (_) => onTap(),
                visualDensity: VisualDensity.compact,
              ),
            ),
            horizontalSpace(width: 1.2.w),
            Text(
              label,
              style: AppStyles.regularTextStyle(context).copyWith(
                fontSize: 12.1.sp,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Driver Detail Popup
Future<void> showDriverDetailPopup(
  BuildContext context, {
  required String deviceId,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

  final driverProvider = Provider.of<DriverProvider>(context, listen: false);
  unawaited(driverProvider.getVehicleDriver(deviceId: deviceId));

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Consumer<DriverProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 7.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              backgroundColor:
                  isDark ? theme.scaffoldBackgroundColor : Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.5.w, 2.0.h, 4.5.w, 2.0.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Call to Driver",
                        style: AppStyles.boldTextStyle(context).copyWith(
                          fontSize: 17.2.sp,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ),
                    verticalSpace(height: 1.2.h),
                    AppLoadings.circleLoading(),
                    verticalSpace(height: 1.1.h),
                    Text(
                      "Loading driver details...",
                      style: AppStyles.regularTextStyle(context).copyWith(
                        fontSize: 12.8.sp,
                        color: onSurface.withValues(alpha: .68),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final matchedDriver = provider.currentVehicleDriver;
          final rawPhone = matchedDriver?.phone ?? "";
          final sanitizedPhone = _sanitizePhoneNumber(rawPhone);

          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 7.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            backgroundColor:
                isDark ? theme.scaffoldBackgroundColor : Colors.white,
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.5.w, 2.0.h, 4.5.w, 1.8.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 6.6.h,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -.6.h,
                          right: -1.w,
                          child: Icon(
                            Icons.contact_phone_rounded,
                            color: AppColors.blueCyan
                                .withValues(alpha: isDark ? 0.22 : 0.16),
                            size: 6.2.h,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Call to Driver",
                            style: AppStyles.boldTextStyle(context).copyWith(
                              fontSize: 17.2.sp,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(height: .3.h),
                  Text(
                    "Driver contact and profile details",
                    style: AppStyles.regularTextStyle(context).copyWith(
                      color: onSurface.withValues(alpha: .62),
                      fontSize: 12.8.sp,
                    ),
                  ),
                  verticalSpace(height: 1.4.h),

                  ///  No driver assigned
                  if (matchedDriver == null) ...[
                    Center(
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: .06)
                              : Colors.black.withValues(alpha: .03),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.person_off_rounded,
                          size: 19.sp,
                          color: onSurface.withValues(alpha: .48),
                        ),
                      ),
                    ),
                    verticalSpace(height: 1.1.h),
                    Center(
                      child: Text(
                        "No driver assigned",
                        style: AppStyles.semiboldTextStyle(context).copyWith(
                          fontSize: 14.2.sp,
                          color: onSurface.withValues(alpha: .86),
                        ),
                      ),
                    ),
                    verticalSpace(height: .4.h),
                    Center(
                      child: Text(
                        "Assign a driver to this vehicle to\nview contact actions",
                        textAlign: TextAlign.center,
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: 12.6.sp,
                          color: onSurface.withValues(alpha: .62),
                        ),
                      ),
                    ),
                    verticalSpace(height: 2.h),
                  ]

                  /// ✅ Driver found
                  else ...[
                    _driverDetailRow(
                      context: context,
                      icon: Icons.person_rounded,
                      value: matchedDriver.name,
                      color: AppColors.blueCyan,
                    ),
                    verticalSpace(height: .75.h),
                    _driverDetailRow(
                      context: context,
                      icon: Icons.phone_rounded,
                      value: matchedDriver.phone.isEmpty
                          ? "No phone number"
                          : matchedDriver.phone,
                      color: AppColors.green,
                    ),
                    verticalSpace(height: .75.h),
                    _driverDetailRow(
                      context: context,
                      icon: Icons.alternate_email_rounded,
                      value: matchedDriver.email.isEmpty
                          ? "No email"
                          : matchedDriver.email,
                      color: Colors.orange,
                    ),
                    verticalSpace(height: .9.h),
                    Text(
                      "Description",
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: 13.6.sp,
                        color: onSurface.withValues(alpha: .86),
                      ),
                    ),
                    verticalSpace(height: .5.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.15.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: .04)
                            : Colors.black.withValues(alpha: .02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Text(
                        matchedDriver.description ?? "No description available",
                        style: AppStyles.regularTextStyle(context).copyWith(
                          fontSize: 12.9.sp,
                          color: onSurface.withValues(alpha: .78),
                        ),
                      ),
                    ),
                    verticalSpace(height: 1.2.h),
                    Row(
                      children: [
                        Expanded(
                          child: _driverActionChip(
                            context: context,
                            icon: Icons.call_rounded,
                            label: "Call",
                            color: AppColors.green,
                            onTap: sanitizedPhone.isEmpty
                                ? null
                                : () => _launchDriverCall(sanitizedPhone),
                          ),
                        ),
                        horizontalSpace(width: 1.7.w),
                        Expanded(
                          child: _driverActionChip(
                            context: context,
                            icon: FontAwesomeIcons.whatsapp,
                            label: "WhatsApp",
                            color: AppColors.green,
                            onTap: sanitizedPhone.isEmpty
                                ? null
                                : () => _launchDriverWhatsApp(sanitizedPhone),
                          ),
                        ),
                        horizontalSpace(width: 1.7.w),
                        Expanded(
                          child: _driverActionChip(
                            context: context,
                            icon: Icons.chat_bubble_rounded,
                            label: "Message",
                            color: AppColors.blueCyan,
                            onTap: sanitizedPhone.isEmpty
                                ? null
                                : () => _launchDriverSms(sanitizedPhone),
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.8.h),
                  ],

                  /// Close button
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "Close",
                          backgroundColor: Colors.transparent,
                          textColor: onSurface.withValues(alpha: .82),
                          height: 4.4.h,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Helper widget for info rows in driver detail
Widget _driverDetailRow({
  required BuildContext context,
  required IconData icon,
  required String value,
  required Color color,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final onSurface = Theme.of(context).colorScheme.onSurface;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 1.0.h),
    decoration: BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: .04)
          : Colors.black.withValues(alpha: .02),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withValues(alpha: .36),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 7.5.w,
          height: 3.4.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        horizontalSpace(width: 2.6.w),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 13.7.sp,
              color: onSurface.withValues(alpha: .9),
            ),
          ),
        ),
      ],
    ),
  );
}

String _sanitizePhoneNumber(String phone) {
  final trimmed = phone.trim();
  if (trimmed.isEmpty) return "";
  // Keep leading + and digits only.
  final cleaned = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
  if (cleaned.isEmpty) return "";
  if (cleaned.startsWith('+')) {
    return '+${cleaned.substring(1).replaceAll('+', '')}';
  }
  return cleaned;
}

Future<void> _launchDriverCall(String phone) async {
  final uri = Uri.parse('tel:$phone');
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched) {
    AppSnackBar.error(message: "Unable to open dialer");
  }
}

Future<void> _launchDriverSms(String phone) async {
  final uri = Uri.parse('sms:$phone');
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched) {
    AppSnackBar.error(message: "Unable to open messages");
  }
}

Future<void> _launchDriverWhatsApp(String phone) async {
  final number = phone.startsWith('+') ? phone.substring(1) : phone;
  final uri = Uri.parse('https://wa.me/$number');
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched) {
    AppSnackBar.error(message: "Unable to open WhatsApp");
  }
}

Widget _driverActionChip({
  required BuildContext context,
  required IconData icon,
  required String label,
  required Color color,
  VoidCallback? onTap,
}) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  final disabled = onTap == null;
  final activeForeground = onSurface.withValues(alpha: .94);
  final disabledForeground = onSurface.withValues(alpha: .45);

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: .85.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: disabled ? .06 : .11),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: disabled ? .18 : .35),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14.2.sp,
              color: disabled ? disabledForeground : activeForeground,
            ),
            horizontalSpace(width: 1.2.w),
            Text(
              label,
              style: AppStyles.semiboldTextStyle(context).copyWith(
                fontSize: 12.4.sp,
                color: disabled ? disabledForeground : activeForeground,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Alert Settings Popup
Future<void> showAlertSettingsPopup(
  BuildContext context, {
  required int deviceId,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final provider = Provider.of<AlertSettingsProvider>(context, listen: false);
  await provider.fetchAlertSettings(deviceId: deviceId.toString());
  if (!context.mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.px)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              verticalSpace(height: 1.2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.2.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 4.8.h,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -.6.h,
                        right: -1.w,
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.red
                              .withValues(alpha: isDark ? 0.22 : 0.16),
                          size: 6.2.h,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Alert Settings",
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 16.2.sp,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpace(height: .3.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.2.w),
                constraints: BoxConstraints(maxHeight: 50.h),
                child: Consumer<AlertSettingsProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: CircularProgressIndicator(
                              color: ConstantColor.primaryColor),
                        ),
                      );
                    }
                    if (provider.errorMessage != null) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Center(
                          child: Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: AppStyles.regularTextStyle(context).copyWith(
                              color: onSurface.withValues(alpha: .78),
                              fontSize: 12.8.sp,
                            ),
                          ),
                        ),
                      );
                    }
                    if (provider.alertItems.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.alertItems.length,
                        itemBuilder: (context, index) {
                          final item = provider.alertItems[index];
                          return _tile(
                            context,
                            item.name,
                            item.assigned,
                            () => provider.toggleAlertItem(index),
                          );
                        },
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: [
                        _tile(context, "Excess Parking", provider.excessParking,
                            () => provider.toggle("excessParking")),
                        _tile(
                            context,
                            "Offline Duration",
                            provider.offlineDuration,
                            () => provider.toggle("offlineDuration")),
                        _tile(context, "Ignition ON", provider.ignitionOn,
                            () => provider.toggle("ignitionOn")),
                        _tile(context, "Ignition OFF", provider.ignitionOff,
                            () => provider.toggle("ignitionOff")),
                        _tile(context, "Fence Exit", provider.fenceExit,
                            () => provider.toggle("fenceExit")),
                        _tile(context, "Overspeed", provider.overspeed,
                            () => provider.toggle("overspeed")),
                        _tile(context, "Stop Duration", provider.stopDuration,
                            () => provider.toggle("stopDuration")),
                        _tile(
                            context,
                            "Power Disconnected",
                            provider.powerDisconnected,
                            () => provider.toggle("powerDisconnected")),
                        _tile(context, "Idle Duration", provider.idleDuration,
                            () => provider.toggle("idleDuration")),
                      ],
                    );
                  },
                ),
              ),
              verticalSpace(height: 1.0.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.2.w),
                child: Consumer<AlertSettingsProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            backgroundColor: Colors.transparent,
                            textColor: onSurface.withValues(alpha: .82),
                            height: 4.2.h,
                            onPressed: provider.isSyncing
                                ? null
                                : () => Navigator.pop(context),
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: provider.isSyncing
                              ? AppLoadings.buttonLoading()
                              : CustomButton(
                                  text: "Save",
                                  textColor: Colors.white,
                                  height: 4.2.h,
                                  onPressed: () async {
                                    final ok = await provider.syncAlertSettings(
                                      deviceId: deviceId.toString(),
                                    );
                                    if (!context.mounted) return;
                                    if (ok) Navigator.pop(context);
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              verticalSpace(height: 1.2.h),
            ],
          ),
        ),
      );
    },
  );
}

Widget _tile(
    BuildContext context, String title, bool value, VoidCallback onTap) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

  return AnimatedContainer(
    padding: EdgeInsets.only(left: 3.w),
    duration: const Duration(milliseconds: 300),
    margin: EdgeInsets.only(bottom: .8.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: isDark ? Colors.white.withValues(alpha: .05) : theme.cardColor,
      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      boxShadow: [
        if (!isDark)
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2)),
      ],
    ),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        title,
        style: AppStyles.regularTextStyle(context).copyWith(
          color: onSurface,
          fontSize: 14.0.sp,
        ),
      ),
      trailing: Checkbox(
        value: value,
        activeColor: ConstantColor.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (_) => onTap(),
      ),
    ),
  );
}

/// Geofence Settings Popup
Future<void> showGeofenceSettingsPopup(BuildContext context) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final provider = Provider.of<GeofenceProvider>(context, listen: false);
  if (provider.model == null) {
    provider.fetchGeofence(isRefresh: true, context: context);
  }
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.px)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              verticalSpace(height: 1.2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.2.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 4.8.h,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -.6.h,
                        right: -1.w,
                        child: Icon(
                          Icons.location_on_outlined,
                          color: AppColors.purple
                              .withValues(alpha: isDark ? 0.22 : 0.16),
                          size: 6.2.h,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Assign Geofence",
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 16.2.sp,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpace(height: .3.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.2.w),
                constraints: BoxConstraints(maxHeight: 50.h),
                child: Consumer<GeofenceProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.model == null) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          child: CircularProgressIndicator(
                              color: ConstantColor.primaryColor),
                        ),
                      );
                    }

                    if (provider.errorMessage != null &&
                        provider.model == null) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          child: Text(
                            provider.errorMessage!,
                            style: AppStyles.regularTextStyle(context)
                                .copyWith(color: onSurface),
                          ),
                        ),
                      );
                    }

                    final geofences = provider.model?.geofences ?? [];

                    if (geofences.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          child: Text(
                            "No geofences found",
                            style: AppStyles.regularTextStyle(context)
                                .copyWith(color: onSurface),
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: geofences.map((geofence) {
                          return _geofenceTile(
                            context,
                            geofence.name,
                            geofence.active,
                            () async {
                              final success = await provider
                                  .toggleGeofenceActive(geofence.id);
                              if (context.mounted && !success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Failed to update status")),
                                );
                              }
                            },
                            geofence.type,
                            geofence.polygonColor,
                            provider.isLoading,
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              verticalSpace(height: 1.0.h),
              CustomButton(
                text: "Close",
                backgroundColor: Colors.transparent,
                textColor: onSurface.withValues(alpha: .82),
                height: 4.2.h,
                width: 42.w,
                onPressed: () => Navigator.pop(context),
              ),
              verticalSpace(height: 1.2.h),
            ],
          ),
        ),
      );
    },
  );
}

Widget _geofenceTile(
  BuildContext context,
  String title,
  bool value,
  VoidCallback onTap,
  String type,
  String colorHex,
  bool isLoading,
) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));

  return AnimatedContainer(
    padding: EdgeInsets.only(left: 2.w),
    duration: const Duration(milliseconds: 300),
    margin: EdgeInsets.only(bottom: 1.5.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: theme.cardColor,
      boxShadow: [
        if (!isDark)
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2)),
      ],
    ),
    child: ListTile(
      contentPadding: EdgeInsets.only(right: 2.w),
      onTap: isLoading ? null : onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(
          type == 'circle' ? Icons.circle_outlined : Icons.pentagon_outlined,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppStyles.regularTextStyle(context)
            .copyWith(color: onSurface, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        type.capitalize(),
        style: AppStyles.lightTextStyle(context)
            .copyWith(color: onSurface.withValues(alpha: 0.7), fontSize: 12.sp),
      ),
      trailing: Checkbox(
        value: value,
        activeColor: ConstantColor.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: isLoading ? null : (_) => onTap(),
      ),
    ),
  );
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
