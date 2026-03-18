import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/task_model.dart';
import 'package:trackerapp/providers/task_provider.dart';
import 'package:trackerapp/view/tasks/task_map_picker_screen.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskItem? initialTask;
  final int? fixedDeviceId;
  final String? fixedVehicleName;

  const TaskFormScreen({
    super.key,
    this.initialTask,
    this.fixedDeviceId,
    this.fixedVehicleName,
  });

  bool get isEdit => initialTask != null;
  bool get hasFixedVehicle => fixedDeviceId != null && fixedDeviceId! > 0;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  final TextEditingController _vehicleNameController = TextEditingController();
  late final TextEditingController _deviceIdController;
  late final TextEditingController _invoiceNumberController;
  late final TextEditingController _commentController;

  late final TextEditingController _pickupAddressController;
  late final TextEditingController _pickupLatController;
  late final TextEditingController _pickupLngController;

  late final TextEditingController _deliveryAddressController;
  late final TextEditingController _deliveryLatController;
  late final TextEditingController _deliveryLngController;

  late final List<_WaypointFormItem> _waypointItems;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    final fixedVehicleName = widget.fixedVehicleName?.trim() ?? '';

    _titleController = TextEditingController(text: task?.title ?? '');
    _vehicleNameController.text = task?.vehicleName.isNotEmpty == true
        ? task!.vehicleName
        : fixedVehicleName;
    _deviceIdController = TextEditingController(
      text: task?.device?.id.toString() ?? widget.fixedDeviceId?.toString() ?? '',
    );
    _invoiceNumberController = TextEditingController(
      text: task?.invoiceNumber ?? '',
    );
    _commentController = TextEditingController(text: task?.comment ?? '');

    _pickupAddressController = TextEditingController(
      text: task?.pickup?.address ?? '',
    );
    _pickupLatController = TextEditingController(
      text: task?.pickup?.lat.toString() ?? '',
    );
    _pickupLngController = TextEditingController(
      text: task?.pickup?.lng.toString() ?? '',
    );

    _deliveryAddressController = TextEditingController(
      text: task?.delivery?.address ?? '',
    );
    _deliveryLatController = TextEditingController(
      text: task?.delivery?.lat.toString() ?? '',
    );
    _deliveryLngController = TextEditingController(
      text: task?.delivery?.lng.toString() ?? '',
    );

    _waypointItems = (task?.waypoints ?? const <TaskWaypoint>[])
        .map((wp) => _WaypointFormItem(
              address: TextEditingController(text: wp.address),
              lat: TextEditingController(text: wp.lat.toString()),
              lng: TextEditingController(text: wp.lng.toString()),
            ))
        .toList(growable: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _vehicleNameController.dispose();
    _deviceIdController.dispose();
    _invoiceNumberController.dispose();
    _commentController.dispose();
    _pickupAddressController.dispose();
    _pickupLatController.dispose();
    _pickupLngController.dispose();
    _deliveryAddressController.dispose();
    _deliveryLatController.dispose();
    _deliveryLngController.dispose();
    for (final item in _waypointItems) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;
    final hasFixedVehicle = widget.hasFixedVehicle;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(colors: [theme.cardColor, theme.cardColor])
              : AppColors.mainGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(5.w, 1.4.h, 5.w, .4.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? onSurface : AppColors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Task' : 'New Task',
                        textAlign: TextAlign.center,
                        style: AppStyles.boldTextStyle(context).copyWith(
                          color: isDark ? onSurface : AppColors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 1.2.h),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? .3 : .08),
                        blurRadius: 18,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Consumer<TaskProvider>(
                    builder: (context, provider, _) {
                      return Form(
                        key: _formKey,
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(5.w, 2.2.h, 5.w, 2.4.h),
                          children: [
                            _sectionTitle(context, 'Basic Info'),
                            _inputField(
                              context: context,
                              controller: _titleController,
                              label: 'Title',
                              prefixIcon: Icons.title_rounded,
                              validator: _requiredText,
                            ),
                            SizedBox(height: 1.2.h),
                            if (isEdit || hasFixedVehicle) ...[
                              _inputField(
                                context: context,
                                controller: _vehicleNameController,
                                label: 'Vehicle Name',
                                prefixIcon: Icons.directions_car_filled_rounded,
                                enabled: false,
                                readOnly: true,
                              ),
                              SizedBox(height: 1.2.h),
                            ] else ...[
                              _inputField(
                                context: context,
                                controller: _deviceIdController,
                                label: 'Device ID',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.directions_car_filled_rounded,
                                validator: _requiredPositiveInt,
                              ),
                              SizedBox(height: 1.2.h),
                            ],
                            _inputField(
                              context: context,
                              controller: _invoiceNumberController,
                              label: 'Invoice Number',
                              prefixIcon: Icons.receipt_long_rounded,
                            ),
                            SizedBox(height: 1.2.h),
                            _inputField(
                              context: context,
                              controller: _commentController,
                              label: 'Comment',
                              prefixIcon: Icons.notes_rounded,
                              maxLines: 3,
                            ),
                            SizedBox(height: 1.2.h),
                            _sectionTitle(context, 'Pickup'),
                            _inputField(
                              context: context,
                              controller: _pickupAddressController,
                              label: 'Pickup Address',
                              prefixIcon: Icons.place_rounded,
                              validator: _requiredText,
                              suffixIcon: Icons.map_rounded,
                              onSuffixTap: () => _pickOnMap(
                                addressController: _pickupAddressController,
                                latController: _pickupLatController,
                                lngController: _pickupLngController,
                              ),
                            ),
                            SizedBox(height: 1.2.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _inputField(
                                    context: context,
                                    controller: _pickupLatController,
                                    label: 'Pickup Lat',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                    prefixIcon: Icons.map_rounded,
                                    validator: _requiredDouble,
                                  ),
                                ),
                                SizedBox(width: 2.8.w),
                                Expanded(
                                  child: _inputField(
                                    context: context,
                                    controller: _pickupLngController,
                                    label: 'Pickup Lng',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                    prefixIcon: Icons.map_rounded,
                                    validator: _requiredDouble,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.2.h),
                            _sectionTitle(context, 'Delivery'),
                            _inputField(
                              context: context,
                              controller: _deliveryAddressController,
                              label: 'Delivery Address',
                              prefixIcon: Icons.flag_rounded,
                              validator: _requiredText,
                              suffixIcon: Icons.map_rounded,
                              onSuffixTap: () => _pickOnMap(
                                addressController: _deliveryAddressController,
                                latController: _deliveryLatController,
                                lngController: _deliveryLngController,
                              ),
                            ),
                            SizedBox(height: 1.2.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _inputField(
                                    context: context,
                                    controller: _deliveryLatController,
                                    label: 'Delivery Lat',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                    prefixIcon: Icons.map_rounded,
                                    validator: _requiredDouble,
                                  ),
                                ),
                                SizedBox(width: 2.8.w),
                                Expanded(
                                  child: _inputField(
                                    context: context,
                                    controller: _deliveryLngController,
                                    label: 'Delivery Lng',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                    prefixIcon: Icons.map_rounded,
                                    validator: _requiredDouble,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.2.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _sectionTitle(context, 'Waypoints'),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _waypointItems
                                          .add(_WaypointFormItem.empty());
                                    });
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add'),
                                ),
                              ],
                            ),
                            if (_waypointItems.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(bottom: 1.2.h),
                                child: Text(
                                  'No waypoints added',
                                  style: AppStyles.regularTextStyle(context)
                                      .copyWith(
                                    fontSize: 12.3.sp,
                                  ),
                                ),
                              )
                            else
                              ...List.generate(_waypointItems.length, (index) {
                                final item = _waypointItems[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 1.1.h),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.8.w, vertical: .9.h),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: .12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Stop ${index + 1}',
                                            style: AppStyles.semiboldTextStyle(
                                                    context)
                                                .copyWith(fontSize: 13.sp),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                final removed = _waypointItems
                                                    .removeAt(index);
                                                removed.dispose();
                                              });
                                            },
                                            icon: const Icon(
                                                Icons.delete_outline),
                                            tooltip: 'Remove',
                                          ),
                                        ],
                                      ),
                                      _inputField(
                                        context: context,
                                        controller: item.address,
                                        label: 'Address',
                                        prefixIcon: Icons.room_rounded,
                                        validator: _requiredText,
                                        suffixIcon: Icons.map_rounded,
                                        onSuffixTap: () => _pickOnMap(
                                          addressController: item.address,
                                          latController: item.lat,
                                          lngController: item.lng,
                                        ),
                                      ),
                                      SizedBox(height: .9.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _inputField(
                                              context: context,
                                              controller: item.lat,
                                              label: 'Lat',
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                decimal: true,
                                                signed: true,
                                              ),
                                              prefixIcon: Icons.map_rounded,
                                              validator: _requiredDouble,
                                            ),
                                          ),
                                          SizedBox(width: 2.8.w),
                                          Expanded(
                                            child: _inputField(
                                              context: context,
                                              controller: item.lng,
                                              label: 'Lng',
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                decimal: true,
                                                signed: true,
                                              ),
                                              prefixIcon: Icons.map_rounded,
                                              validator: _requiredDouble,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            SizedBox(height: 2.1.h),
                            provider.isSubmitting
                                ? SizedBox(
                                    height: 5.8.h,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  )
                                : CustomButton(
                                    text:
                                        isEdit ? 'Update Task' : 'Create Task',
                                    onPressed: _submit,
                                    textColor: AppColors.yellow,
                                    backgroundColor: theme.colorScheme.primary,
                                    borderRadius: 14,
                                    height: 5.8.h,
                                    fontSize: 16.sp,
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: .8.h),
      child: Text(
        title,
        style: AppStyles.semiboldTextStyle(context).copyWith(
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _inputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool enabled = true,
    bool readOnly = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return CustomTextField(
      controller: controller,
      labelText: label,
      maxLines: maxLines,
      keyboardType: keyboardType ?? TextInputType.text,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixTap: onSuffixTap,
      enabled: enabled,
      readOnly: readOnly,
      validator: validator,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
      textColor: theme.colorScheme.onSurface,
      labelColor: theme.colorScheme.onSurface.withValues(alpha: 0.62),
      borderColor: isDark
          ? Colors.white.withValues(alpha: 0.2)
          : AppColors.grey.withValues(alpha: 0.6),
      focusedBorderColor: theme.colorScheme.primary,
    );
  }

  String? _requiredText(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    return null;
  }

  String? _requiredPositiveInt(String? value) {
    final text = value?.trim() ?? '';
    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) return 'Enter valid number';
    return null;
  }

  String? _requiredDouble(String? value) {
    final text = value?.trim() ?? '';
    final parsed = double.tryParse(text);
    if (parsed == null) return 'Enter valid decimal';
    return null;
  }

  double? _toNullableDouble(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  Future<void> _pickOnMap({
    required TextEditingController addressController,
    required TextEditingController latController,
    required TextEditingController lngController,
  }) async {
    final result = await Navigator.push<TaskMapPickResult>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskMapPickerScreen(
          initialAddress: addressController.text.trim(),
          initialLat: _toNullableDouble(latController.text),
          initialLng: _toNullableDouble(lngController.text),
        ),
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      addressController.text = result.address.trim();
      latController.text = result.lat.toStringAsFixed(6);
      lngController.text = result.lng.toStringAsFixed(6);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final int resolvedDeviceId;
    if (widget.isEdit) {
      resolvedDeviceId = widget.initialTask?.device?.id ?? 0;
    } else if (widget.hasFixedVehicle) {
      resolvedDeviceId = widget.fixedDeviceId ?? 0;
    } else {
      resolvedDeviceId = int.parse(_deviceIdController.text.trim());
    }
    if (resolvedDeviceId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid device id for task'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final payload = TaskUpsertPayload(
      title: _titleController.text.trim(),
      deviceId: resolvedDeviceId,
      invoiceNumber: _invoiceNumberController.text.trim(),
      comment: _commentController.text.trim(),
      pickupAddress: _pickupAddressController.text.trim(),
      pickupAddressLat: double.parse(_pickupLatController.text.trim()),
      pickupAddressLng: double.parse(_pickupLngController.text.trim()),
      deliveryAddress: _deliveryAddressController.text.trim(),
      deliveryAddressLat: double.parse(_deliveryLatController.text.trim()),
      deliveryAddressLng: double.parse(_deliveryLngController.text.trim()),
      waypoints: _waypointItems
          .map(
            (item) => TaskWaypoint(
              address: item.address.text.trim(),
              lat: double.parse(item.lat.text.trim()),
              lng: double.parse(item.lng.text.trim()),
            ),
          )
          .toList(growable: false),
    );

    final provider = context.read<TaskProvider>();
    late final TaskActionResult result;
    if (widget.isEdit) {
      result = await provider.updateTask(
        id: widget.initialTask!.id,
        payload: payload,
      );
    } else {
      result = await provider.createTask(payload: payload);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (result.success) {
      Navigator.pop(context, true);
    }
  }
}

class _WaypointFormItem {
  final TextEditingController address;
  final TextEditingController lat;
  final TextEditingController lng;

  _WaypointFormItem({
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory _WaypointFormItem.empty() {
    return _WaypointFormItem(
      address: TextEditingController(),
      lat: TextEditingController(),
      lng: TextEditingController(),
    );
  }

  void dispose() {
    address.dispose();
    lat.dispose();
    lng.dispose();
  }
}
