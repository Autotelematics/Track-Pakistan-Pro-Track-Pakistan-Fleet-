import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/get_device_commands_model.dart';
import 'package:trackerapp/data/models/get_driver_model.dart';
import 'package:trackerapp/providers/alert_settings_provider.dart';
import 'package:trackerapp/providers/device_command_provider.dart';
import 'package:trackerapp/providers/driver_provider.dart';
import 'package:trackerapp/providers/get_geofence_provider.dart';
import 'package:trackerapp/utils/app_loading.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/maintenance_widgets/maintenance_field.dart';
import 'app_colors.dart';

/// Action on Driver
Future<void> showDriverActionPopup(BuildContext context)
async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Driver Options",
                style: AppStyles.boldTextStyle(context).copyWith(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
              verticalSpace(height: 2.h),
              _DriverActionTile(
                context: context,
                icon: Icons.person_add_alt_1,
                title: "Add New Driver",
                subtitle: "Create a new driver",
                color: AppColors.green,
                onTap: () {
                  Navigator.pop(ctx);
                  showAddDriverPopup(context);
                },
              ),
              verticalSpace(height: 2.h),
              _DriverActionTile(
                context: context,
                icon: Icons.edit,
                title: "Edit Driver",
                subtitle: "Update driver info",
                color: AppColors.blueCyan,
                onTap: () {
                  showEditDriverPopup(context);
                },
              ),
              verticalSpace(height: 2.h),
              _DriverActionTile(
                context: context,
                icon: Icons.delete_forever,
                title: "Delete driver",
                subtitle: "Permanent delete driver",
                color: AppColors.red,
                onTap: () {
                  showDeleteDriverPopup(context);
                },
              ),
              verticalSpace(height: 3.h),
              CustomButton(
                text: "Cancel",
                height: 4.5.h,
                backgroundColor: Colors.transparent,
                textColor: AppColors.textBlack,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      );
    },
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
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            horizontalSpace(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.length > 14 ? "${title.substring(0, 14)}..." : title,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  verticalSpace(height: 0.5.h),
                  Text(
                    subtitle.length > 18
                        ? "${subtitle.substring(0, 18)}..."
                        : subtitle,
                    style: AppStyles.semiboldTextStyle(context).copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

/// Add Driver Popup
Future<void> showAddDriverPopup(BuildContext context)
async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final nameCtrl = TextEditingController();
  final rfIdCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        "Add Driver",
                        style: AppStyles.boldTextStyle(context).copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ),
                    verticalSpace(height: 2.h),

                    // Driver Name field
                    MaintenanceField(
                      title: "Driver Name",
                      hint: "Enter driver name",
                      controller: nameCtrl,
                    ),
                    verticalSpace(height: 2.h),
                    MaintenanceField(
                      title: "RFID",
                      hint: "Enter driver RfId",
                      controller: rfIdCtrl,
                    ),
                    verticalSpace(height: 2.h),

                    // Phone field
                    MaintenanceField(
                      title: "Phone",
                      hint: "03xxxxxxxxx",
                      controller: phoneCtrl,
                    ),
                    verticalSpace(height: 2.h),

                    // Email field
                    MaintenanceField(
                      title: "Email",
                      hint: "driver@email.com",
                      controller: emailCtrl,
                    ),
                    verticalSpace(height: 4.h),

                    // Cancel and Save buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            backgroundColor: Colors.transparent,
                            textColor: AppColors.textBlack,
                            height: 4.5.h,
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
                                      height: 4.5.h,
                                      onPressed: () {
                                        final emailValid = RegExp(
                                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$")
                                            .hasMatch(emailCtrl.text.trim());

                                        if (nameCtrl.text.isEmpty) {
                                          AppSnackBar.error(
                                              message:
                                                  "Driver name is required");
                                        } else if (emailCtrl.text.isEmpty) {
                                          AppSnackBar.error(
                                              message:
                                                  "Please enter your email");
                                        } else if (!emailValid) {
                                          AppSnackBar.error(
                                              message:
                                                  "Please enter your valid email");
                                        } else {
                                          driverProvider
                                              .addDriver(
                                                  name: nameCtrl.text,
                                                  rfId: rfIdCtrl.text,
                                                  phone: phoneCtrl.text,
                                                  email: emailCtrl.text,
                                                  deviceId: "")
                                              .then((_) {
                                            Navigator.pop(context);
                                          });
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
Future<void> showEditDriverPopup(BuildContext context)
async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
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
                        /// Title
                        Center(
                          child: Text(
                            "Edit Driver",
                            style: AppStyles.boldTextStyle(context).copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                          ),
                        ),

                        verticalSpace(height: 2.h),

                        /// Dropdown Label
                        Text(
                          "Select Driver",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: onSurface,
                          ),
                        ),
                        verticalSpace(height: 1.h),

                        /// Driver Dropdown
                        DropdownButtonFormField2<int>(
                          value: selectedIndex,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: "Driver",
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: drivers.asMap().entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value.name),
                            );
                          }).toList(),
                          onChanged: (index) {
                            setState(() {
                              selectedIndex = index;
                              final driver = drivers[index!];

                              /// 🔥 AUTO FILL
                              nameCtrl.text = driver.name;
                              rfIdCtrl.text = driver.rfid;
                              phoneCtrl.text = driver.phone;
                              emailCtrl.text = driver.email;
                            });
                          },
                        ),

                        verticalSpace(height: 2.h),

                        /// Editable Fields
                        MaintenanceField(
                          title: "Driver Name",
                          hint: "Enter driver name",
                          controller: nameCtrl,
                        ),
                        verticalSpace(height: 2.h),

                        MaintenanceField(
                          title: "RFID",
                          hint: "Enter RFID",
                          controller: rfIdCtrl,
                        ),
                        verticalSpace(height: 2.h),

                        MaintenanceField(
                          title: "Phone",
                          hint: "03xxxxxxxxx",
                          controller: phoneCtrl,
                        ),
                        verticalSpace(height: 2.h),

                        MaintenanceField(
                          title: "Email",
                          hint: "driver@email.com",
                          controller: emailCtrl,
                        ),

                        verticalSpace(height: 4.h),

                        /// Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: "Cancel",
                                backgroundColor: Colors.transparent,
                                textColor: AppColors.textBlack,
                                height: 4.5.h,
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
                                            height: 4.5.h,
                                            onPressed: () {
                                              if (selectedIndex == null) {
                                                AppSnackBar.error(
                                                    message:
                                                        "Please select a driver");
                                                return;
                                              }

                                              final driver =
                                                  drivers[selectedIndex!];

                                              driverProvider
                                                  .editDriver(
                                                driverId: driver.id.toString(),
                                                name: nameCtrl.text.trim(),
                                                rfid: rfIdCtrl.text.trim(),
                                                phone: phoneCtrl.text.trim(),
                                                email: emailCtrl.text.trim(),
                                                description: '',
                                              )
                                                  .then((_) {
                                                Navigator.pop(ctx);
                                              });
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
Future<void> showDeleteDriverPopup(BuildContext context)
async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

  final driverProvider = Provider.of<DriverProvider>(context, listen: false);
  driverProvider.getDriverUser(deviceId: "");

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final Set<int> selectedIndexes = {};

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title
                      Center(
                        child: Text(
                          "Delete Driver",
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                      ),

                      verticalSpace(height: 2.h),

                      Text(
                        "Select Drivers",
                        style: AppStyles.semiboldTextStyle(context).copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      verticalSpace(height: 1.h),

                      /// 🔥 Driver List
                      SizedBox(
                        height: 50.h,
                        child: ListView.builder(
                          itemCount: drivers.length,
                          itemBuilder: (context, index) {
                            final driver = drivers[index];
                            final isSelected = selectedIndexes.contains(index);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedIndexes.remove(index);
                                  } else {
                                    selectedIndexes.add(index);
                                  }
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 1.2.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 3.w, vertical: 1.2.h),
                                decoration: BoxDecoration(
                                  color:
                                      isDark ? theme.cardColor : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.red
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driver.name,
                                      style:
                                          AppStyles.semiboldTextStyle(context)
                                              .copyWith(
                                        color: onSurface,
                                      ),
                                    ),
                                    if (driver.email.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: .5.h),
                                        child: Text(
                                          driver.email,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      /// Selected Count
                      if (selectedIndexes.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 1.h),
                          child: Text(
                            "${selectedIndexes.length} driver(s) selected",
                            style: TextStyle(
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      verticalSpace(height: 3.h),

                      /// Buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Cancel",
                              backgroundColor: Colors.transparent,
                              textColor: AppColors.textBlack,
                              height: 4.5.h,
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ),
                          horizontalSpace(width: 3.w),
                          Expanded(
                            child: CustomButton(
                              backgroundColor: AppColors.red,
                              text: "Delete",
                              height: 4.5.h,
                              onPressed: () {
                                if (selectedIndexes.isEmpty) {
                                  AppSnackBar.error(
                                    message:
                                        "Please select at least one driver",
                                  );
                                  return;
                                }

                                final selectedDrivers = selectedIndexes
                                    .map((i) => drivers[i])
                                    .toList();

                                for (final driver in selectedDrivers) {
                                  // driverProvider.deleteDriver(
                                  //   driverId: driver.id.toString(),
                                  // );
                                }

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
}

///IMMOBILIZER
Future<void> showDeviceCommandsPopup(
    BuildContext context,
    String deviceId,
    )
async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

  final commandsProvider =
  Provider.of<GetDeviceCommandsProvider>(context, listen: false);

  await commandsProvider.getDeviceCommandMethod(deviceId: deviceId);

  GetDeviceCommandsModel? selectedCommand;
  TextEditingController? messageController;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor:
        isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Consumer<GetDeviceCommandsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return SizedBox(
                      height: 20.h,
                      child: Center(
                        child: AppLoadings.circleLoading(),
                      ),
                    );
                  }

                  ///  Ignore Engine stop & Engine resume
                  final commands = (provider.getDeviceCommands ?? [])
                      .where(
                        (cmd) =>
                    cmd.title.toLowerCase() != 'engine stop' &&
                        cmd.title.toLowerCase() != 'engine resume',
                  )
                      .toList();

                  if (commands.isEmpty) {
                    return SizedBox(
                      height: 20.h,
                      child: const Center(
                        child: Text("No commands available"),
                      ),
                    );
                  }

                  final isCustomSelected =
                      selectedCommand?.title == 'Custom command';

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title
                      Center(
                        child: Text(
                          "IMMOBILIZER",
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                      ),

                      verticalSpace(height: 2.h),

                      Text(
                        "Select Command",
                        style:
                        AppStyles.semiboldTextStyle(context).copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      verticalSpace(height: 1.h),

                      /// Commands list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: commands.length,
                        itemBuilder: (context, index) {
                          final command = commands[index];

                          return RadioListTile<GetDeviceCommandsModel>(
                            value: command,
                            groupValue: selectedCommand,
                            title: Text(
                              command.title,
                              style:
                              AppStyles.regularTextStyle(context),
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectedCommand = value;
                                print("selectedCommand${selectedCommand?.title??""}");

                                messageController?.dispose();
                                messageController = null;

                                /// Create controller only for Custom
                                if (selectedCommand!.title
                                    .toLowerCase() ==
                                    'custom') {
                                  messageController =
                                      TextEditingController();
                                }
                              });
                            },
                          );
                        },
                      ),
                      if (isCustomSelected) ...[
                        verticalSpace(height: 2.h),
                        Text(
                          "Message",
                          style: AppStyles.semiboldTextStyle(context),
                        ),
                        verticalSpace(height: 0.8.h),
                        TextField(
                          controller: messageController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Enter custom command message",
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],

                      verticalSpace(height: 3.h),

                      /// Buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Cancel",
                              backgroundColor: Colors.transparent,
                              textColor: AppColors.textBlack,
                              height: 4.5.h,
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ),
                          horizontalSpace(width: 3.w),
                          Expanded(
                            child: CustomButton(
                              text: "Send",
                              backgroundColor:
                              ConstantColor.primaryColor,
                              height: 4.5.h,
                              onPressed: selectedCommand == null
                                  ? null
                                  : () {
                                provider.sendDeviceCommandMethod(deviceId: deviceId,commandType: selectedCommand?.type??"");
                                final message =
                                    messageController?.text;

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

  messageController?.dispose();
}


/// Add Expense Popup
Future<void> showAddExpensePopup(BuildContext context)
async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        "Add Expense",
                        style: AppStyles.boldTextStyle(context).copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ),
                    verticalSpace(height: 1.5.h),

                    Text(
                      "Category",
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: onSurface),
                    ),
                    verticalSpace(height: .5.h),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      hint: const Text("Select category"),
                      items: expenseCategories
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => selectedCategory = v);
                        if (v != "Other") otherCategoryCtrl.clear();
                      },
                    ),
                    verticalSpace(height: 1.5.h),
                    if (selectedCategory == "Other") ...[
                      MaintenanceField(
                        title: "Specify Category",
                        hint: "Enter other category",
                        controller: otherCategoryCtrl,
                      ),
                      verticalSpace(height: 1.5.h),
                    ],

                    // Amount
                    MaintenanceField(
                      title: "Amount (Rs)",
                      hint: "0",
                      controller: amountCtrl,
                    ),
                    verticalSpace(height: 1.5.h),

                    // Date & Time in one responsive row
                    Row(
                      children: [
                        Expanded(
                          child: MaintenanceField(
                            title: "Expense Date",
                            hint: expenseDate == null
                                ? "Pick date"
                                : "${expenseDate!.day}/${expenseDate!.month}/${expenseDate!.year}",
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
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null)
                                setState(() => expenseTime = time);
                            },
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.5.h),

                    // Supplier & Buyer in one responsive row
                    Row(
                      children: [
                        Expanded(
                          child: MaintenanceField(
                            title: "Supplier",
                            hint: "Shell, PSO, etc.",
                            controller: supplierCtrl,
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: MaintenanceField(
                            title: "Buyer",
                            hint: "Enter buyer name",
                            controller: buyerCtrl,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.5.h),

                    // Device Type Dropdown (full width)
                    Text(
                      "Device Type",
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: onSurface),
                    ),
                    verticalSpace(height: 1.h),
                    DropdownButtonFormField<String>(
                      value: selectedDeviceType,
                      hint: const Text("Select device type"),
                      items: deviceTypes
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => selectedDeviceType = v);
                        if (v != "Other") otherDeviceCtrl.clear();
                      },
                    ),
                    verticalSpace(height: 2.h),

                    if (selectedDeviceType == "Other") ...[
                      MaintenanceField(
                        title: "Specify Device Type",
                        hint: "Enter other device type",
                        controller: otherDeviceCtrl,
                      ),
                      verticalSpace(height: 1.5.h),
                    ],

                    // Description
                    MaintenanceField(
                      title: "Description",
                      hint: "Optional notes",
                      controller: notesCtrl,
                    ),
                    verticalSpace(height: 2.h), // Reduced bottom space a bit

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            backgroundColor: Colors.transparent,
                            textColor: AppColors.textBlack,
                            height: 4.5.h,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: CustomButton(
                            text: "Save",
                            height: 4.5.h,
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
Future<void> showAddMaintenancePopup(BuildContext context)
async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        "Add service",
                        style: AppStyles.boldTextStyle(context).copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ),
                    verticalSpace(height: 1.5.h),

                    // Name (full width)
                    MaintenanceField(
                      title: "Name",
                      hint: "Enter service name",
                      controller: nameCtrl,
                      height: 5.5.h,
                    ),
                    verticalSpace(height: 1.5.h),

                    // Expiration by dropdown (compact)
                    Text(
                      "Expiration by",
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: onSurface),
                    ),
                    verticalSpace(height: 0.8.h),
                    SizedBox(
                      height: 5.5.h,
                      child: DropdownButtonFormField<String>(
                        isDense: true,
                        value: expirationBy,
                        hint: const Text("Select expiration type"),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: expirationOptions
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => expirationBy = v),
                      ),
                    ),
                    verticalSpace(height: 1.5.h),
                    Row(
                      children: [
                        Expanded(
                          child: MaintenanceField(
                            title: "Interval",
                            hint: "Enter interval",
                            controller: intervalCtrl,
                            height: 5.5.h,
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: MaintenanceField(
                            title: "Last service",
                            hint: "Enter last value/date",
                            controller: lastServiceCtrl,
                            height: 5.5.h,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.5.h),

                    // Trigger event when left (full width)
                    MaintenanceField(
                      title: "Trigger event when left",
                      hint: "e.g. 1000 km",
                      controller: triggerLeftCtrl,
                      height: 5.5.h,
                    ),
                    verticalSpace(height: 1.5.h),

                    // Renew after expiration checkbox
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Renew after expiration",
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: onSurface),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 5.w),
                          height: 5.h,
                          width: 12.w,
                          child: Checkbox(
                            value: renewAfterExpiration,
                            onChanged: (val) => setState(
                                () => renewAfterExpiration = val ?? false),
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.5.h),

                    // Current odometer & Current engine hours in one row (display only - matching screenshot)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Odometer",
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: onSurface),
                              ),
                              verticalSpace(height: 0.8.h),
                              Container(
                                height: 5.5.h,
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                decoration: BoxDecoration(
                                  color: theme.cardColor.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          theme.dividerColor.withOpacity(0.4)),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  currentOdometer,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: onSurface.withOpacity(0.8)),
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
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: onSurface),
                              ),
                              verticalSpace(height: 0.8.h),
                              Container(
                                height: 5.5.h,
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                decoration: BoxDecoration(
                                  color: theme.cardColor.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          theme.dividerColor.withOpacity(0.4)),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  currentEngineHours,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: onSurface.withOpacity(0.8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(height: 1.5.h),

                    // Description
                    MaintenanceField(
                      title: "Description",
                      hint: "Optional notes",
                      controller: descriptionCtrl,
                      height: 5.5.h,
                    ),
                    verticalSpace(height: 1.5.h),

                    // Email
                    MaintenanceField(
                      title: "Email",
                      hint: "notification@email.com",
                      controller: emailCtrl,
                      height: 5.5.h,
                    ),
                    verticalSpace(height: 2.5.h),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            backgroundColor: Colors.transparent,
                            textColor: AppColors.textBlack,
                            height: 4.5.h,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: CustomButton(
                            text: "Save",
                            height: 4.5.h,
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
    BuildContext context, String deviceId)
async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

  final driverProvider = Provider.of<DriverProvider>(context, listen: false);
  driverProvider.getDriverUser(deviceId: "");

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      int? selectedIndex;
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
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
                      Center(
                        child: Text(
                          "Assign Driver",
                          style: AppStyles.boldTextStyle(context).copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                      ),
                      verticalSpace(height: 2.h),
                      Text(
                        "Select Driver",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: onSurface,
                        ),
                      ),
                      verticalSpace(height: 1.h),
                      SizedBox(
                        width: 100.w,
                        child: DropdownButtonFormField2<int>(
                          value: selectedIndex,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: "Select Driver",
                          ),
                          isExpanded: true,
                          items: drivers.asMap().entries.map((entry) {
                            int index = entry.key;
                            final driver = entry.value;
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text(driver.name),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() {
                              selectedIndex = v;
                            });
                          },
                        ),
                      ),
                      verticalSpace(height: 4.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Cancel",
                              backgroundColor: Colors.transparent,
                              textColor: AppColors.textBlack,
                              height: 4.5.h,
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
                                          height: 4.5.h,
                                          onPressed: () {
                                            print("device id :$deviceId");
                                            if (selectedIndex != null) {
                                              final selectedDriver =
                                                  drivers[selectedIndex ?? 0];
                                              debugPrint(
                                                  "✅ Assign Driver - Selected: ${selectedDriver.name}, ID: ${selectedDriver.id}");
                                              driverProvider
                                                  .assignDriver(
                                                      driverId: selectedDriver
                                                          .id
                                                          .toString(),
                                                      deviceId: deviceId)
                                                  .then((_) {});
                                              Navigator.pop(
                                                  ctx, selectedDriver);
                                            } else {
                                              AppSnackBar.error(
                                                  message:
                                                      "Please select a driver");
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
Future<void> showAddReminderPopup(BuildContext context)
async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;
  final titleCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  String? selectedReminderType = 'Custom';
  DateTime? reminderDueDate;
  bool isRecurring = false;
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

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        "Add Reminder",
                        style: AppStyles.boldTextStyle(context).copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ),
                    verticalSpace(height: 2.h),

                    // Type label and dropdown
                    Text(
                      "Type",
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: onSurface),
                    ),
                    verticalSpace(height: 1.h),
                    DropdownButtonFormField<String>(
                      value: selectedReminderType,
                      hint: const Text("Select type"),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.5.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      items: reminderTypes
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
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
                    verticalSpace(height: 2.h),

                    // Title field
                    MaintenanceField(
                      title: "Title",
                      hint: "Reminder title",
                      controller: titleCtrl,
                    ),
                    verticalSpace(height: 2.h),

                    // Due Date picker
                    MaintenanceField(
                      title: "Due Date",
                      hint: reminderDueDate == null
                          ? "dd/mm/yyyy"
                          : "${reminderDueDate!.day.toString().padLeft(2, '0')}/${reminderDueDate!.month.toString().padLeft(2, '0')}/${reminderDueDate!.year}",
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          initialDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => reminderDueDate = date);
                        }
                      },
                    ),
                    verticalSpace(height: 2.h),

                    // Recurring switch
                    Row(
                      children: [
                        Icon(Icons.loop, color: onSurface),
                        horizontalSpace(width: 2.w),
                        Text(
                          "Recurring",
                          style: TextStyle(
                              fontSize: 15.sp,
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
                    verticalSpace(height: 2.h),

                    // Optional description
                    MaintenanceField(
                      title: "Description",
                      hint: "Optional notes",
                      controller: notesCtrl,
                    ),
                    verticalSpace(height: 4.h),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            backgroundColor: Colors.transparent,
                            textColor: AppColors.textBlack,
                            height: 4.5.h,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        horizontalSpace(width: 3.w),
                        Expanded(
                          child: CustomButton(
                            text: "Add Reminder",
                            height: 4.5.h,
                            onPressed: () {
                              debugPrint(
                                  "Add Reminder - Type: $selectedReminderType");
                              debugPrint(
                                  "Add Reminder - Title: ${titleCtrl.text}");
                              debugPrint(
                                  "Add Reminder - Due Date: $reminderDueDate");
                              debugPrint(
                                  "Add Reminder - Recurring: $isRecurring");
                              debugPrint(
                                  "Add Reminder - Notes: ${notesCtrl.text}");
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

/// Driver Detail Popup
Future<void> showDriverDetailPopup(
    BuildContext context, {
      required String deviceId,
    }) async {
  final theme = Theme.of(context);
  final onSurface = theme.colorScheme.onSurface;

  final driverProvider =
  Provider.of<DriverProvider>(context, listen: false);
  await driverProvider.getDriverUser(deviceId: deviceId);

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Consumer<DriverProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          final drivers =
              provider.getDriverModel?.items.drivers.data ?? [];
          Datum? matchedDriver;
          try {
            matchedDriver = drivers.firstWhere(
                  (d) => d.deviceId == deviceId,
            );
          } catch (_) {
            matchedDriver = null;
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  verticalSpace(height: 2.h),

                  /// Title
                  Text(
                    "Driver Details",
                    style: AppStyles.boldTextStyle(context).copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),

                  Divider(color: AppColors.grey),

                  ///  No driver assigned
                  if (matchedDriver == null) ...[
                    verticalSpace(height: 3.h),
                    const Icon(Icons.person_off, size: 50, color: Colors.grey),
                    verticalSpace(height: 1.h),
                    const Text(
                      "No driver assigned",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    verticalSpace(height: 3.h),
                  ]

                  /// ✅ Driver found
                  else ...[
                    verticalSpace(height: 1.5.h),

                    _infoRow(
                      icon: Icons.person,
                      value: matchedDriver.name,
                      context: context,
                      boxColor: Colors.blue.withOpacity(0.12),
                      iconColor: Colors.blue,
                    ),

                    Divider(color: AppColors.grey.withOpacity(0.3)),

                    _infoRow(
                      icon: Icons.phone,
                      value: matchedDriver.phone,
                      context: context,
                      boxColor: Colors.green.withOpacity(0.12),
                      iconColor: Colors.green,
                    ),

                    Divider(color: AppColors.grey.withOpacity(0.3)),

                    _infoRow(
                      icon: Icons.email,
                      value: matchedDriver.email,
                      context: context,
                      boxColor: Colors.orange.withOpacity(0.12),
                      iconColor: Colors.orange,
                    ),

                    Divider(color: AppColors.grey.withOpacity(0.3)),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: Text(
                        matchedDriver.description ??
                            "No description available",
                      ),
                    ),

                    verticalSpace(height: 2.h),
                  ],

                  /// Close button
                  CustomButton(
                    text: "Close",
                    height: 4.h,
                    width: 45.w,
                    onPressed: () => Navigator.pop(ctx),
                  ),

                  verticalSpace(height: 2.h),
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
Widget _infoRow({
  required IconData icon,
  required String value,
  required BuildContext context,
  int maxLines = 1,
  Color? boxColor,
  Color? iconColor,
})
{
  final theme = Theme.of(context);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        height: 3.5.h,
        width: 8.w,
        decoration: BoxDecoration(
          color: boxColor ?? theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(5.px),
        ),
        child: Icon(
          icon,
          size: icon == Icons.person ? 3.h : 2.5.h,
          color: iconColor ?? theme.colorScheme.primary,
        ),
      ),
      horizontalSpace(width: 3.w),
      Expanded(
        child: Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: icon == Icons.person
              ? AppStyles.semiboldTextStyle(context)
              : AppStyles.regularTextStyle(context),
        ),
      ),
      // Action icons only for phone row
      if (icon == Icons.phone)
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(5.px),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.email, color: Colors.orange),
            ),
            horizontalSpace(width: 2.w),
            Container(
              padding: EdgeInsets.all(5.px),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 8),
                ],
              ),
              child: Icon(FontAwesomeIcons.whatsapp, color: AppColors.green),
            ),
            horizontalSpace(width: 2.w),
            Container(
              padding: EdgeInsets.all(5.px),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 8),
                ],
              ),
              child: Icon(Icons.phone, color: AppColors.green),
            ),
          ],
        ),
    ],
  );
}

/// Alert Settings Popup
Future<void> showAlertSettingsPopup(BuildContext context)
async {
  final theme = Theme.of(context);
  final onSurface = theme.colorScheme.onSurface;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 3.w),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.px)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              verticalSpace(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Alert Settings",
                    style: AppStyles.boldTextStyle(context).copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
              verticalSpace(height: 2.4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.grey.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 8),
                  ],
                ),
                child: Consumer<AlertSettingsProvider>(
                  builder: (context, provider, child) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _tile(
                              context,
                              "Excess Parking",
                              provider.excessParking,
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
                      ),
                    );
                  },
                ),
              ),
              verticalSpace(height: 2.h),
              CustomButton(
                text: "Close",
                height: 4.5.h,
                width: 42.w,
                onPressed: () => Navigator.pop(context),
              ),
              verticalSpace(height: 2.h),
            ],
          ),
        ),
      );
    },
  );
}

Widget _tile(
    BuildContext context, String title, bool value, VoidCallback onTap)
{
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final onSurface = theme.colorScheme.onSurface;

  return AnimatedContainer(
    padding: EdgeInsets.only(left: 4.w),
    duration: const Duration(milliseconds: 300),
    margin: EdgeInsets.only(bottom: 1.5.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: theme.cardColor,
      boxShadow: [
        if (!isDark)
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2)),
      ],
    ),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        title,
        style: AppStyles.regularTextStyle(context).copyWith(color: onSurface),
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
Future<void> showGeofenceSettingsPopup(BuildContext context)
async {
  final theme = Theme.of(context);
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
        insetPadding: EdgeInsets.symmetric(horizontal: 3.w),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.px)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              verticalSpace(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Assign Geofence",
                    style: AppStyles.boldTextStyle(context).copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
              verticalSpace(height: 2.4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                constraints: BoxConstraints(maxHeight: 50.h),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.grey.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 8),
                  ],
                ),
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
              verticalSpace(height: 2.h),
              CustomButton(
                text: "Close",
                height: 4.5.h,
                width: 42.w,
                onPressed: () => Navigator.pop(context),
              ),
              verticalSpace(height: 2.h),
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2)),
      ],
    ),
    child: ListTile(
      contentPadding: EdgeInsets.only(right: 2.w),
      onTap: isLoading ? null : onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withOpacity(0.2),
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
            .copyWith(color: onSurface.withOpacity(0.7), fontSize: 12.sp),
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
