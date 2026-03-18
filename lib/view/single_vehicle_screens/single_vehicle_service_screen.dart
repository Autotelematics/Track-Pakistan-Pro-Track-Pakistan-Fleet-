import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/device_service_model.dart';
import 'package:trackerapp/utils/app_validation_dialog.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/maintenance_widgets/maintenance_field.dart';

Future<ServiceFormData?> showServiceFormDialog(
  BuildContext context, {
  DeviceService? initialService,
}) async {
  if (!context.mounted) return null;
  return showDialog<ServiceFormData>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      child: _AddServiceSheet(initialService: initialService),
    ),
  );
}

class ServiceFormData {
  final String name;
  final String expirationBy;
  final String interval;
  final String lastService;
  final String? triggerEventLeft;
  final bool renewAfterExpiration;
  final bool expires;
  final DateTime? expiresDate;
  final bool remind;
  final DateTime? remindDate;
  final String? email;
  final String? mobilePhone;
  final String? description;

  const ServiceFormData({
    required this.name,
    required this.expirationBy,
    required this.interval,
    required this.lastService,
    this.triggerEventLeft,
    required this.renewAfterExpiration,
    required this.expires,
    required this.expiresDate,
    required this.remind,
    required this.remindDate,
    this.email,
    this.mobilePhone,
    this.description,
  });
}

class _AddServiceSheet extends StatefulWidget {
  final DeviceService? initialService;

  const _AddServiceSheet({this.initialService});

  @override
  State<_AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<_AddServiceSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _intervalCtrl = TextEditingController();
  final _lastServiceCtrl = TextEditingController();
  final _triggerEventLeftCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobilePhoneCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String _expirationBy = 'odometer';
  bool _renewAfterExpiration = false;
  bool _expires = false;
  DateTime? _expiresDate;
  bool _remind = false;
  DateTime? _remindDate;
  DateTime? _lastServiceDate;

  DateTime? _tryParseFlexibleDate(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final direct = DateTime.tryParse(text);
    if (direct != null) return direct;
    if (text.length >= 10) {
      return DateTime.tryParse(text.substring(0, 10));
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialService;
    if (initial != null) {
      _nameCtrl.text = initial.name;
      _expirationBy = initial.expirationBy.trim().isEmpty
          ? 'odometer'
          : initial.expirationBy.trim();
      _intervalCtrl.text = initial.interval;
      _lastServiceCtrl.text = initial.lastService;
      if (_expirationBy == 'days') {
        _lastServiceDate = _tryParseFlexibleDate(initial.lastService);
      }
      _triggerEventLeftCtrl.text = initial.triggerEventLeft;
      _renewAfterExpiration = initial.renewAfterExpiration;
      _expires = initial.expires;
      _expiresDate = initial.expiresDate;
      _remind = initial.remind;
      _remindDate = initial.remindDate;
      _emailCtrl.text = initial.email;
      _mobilePhoneCtrl.text = initial.mobilePhone;
      _descriptionCtrl.text = initial.description;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _intervalCtrl.dispose();
    _lastServiceCtrl.dispose();
    _triggerEventLeftCtrl.dispose();
    _emailCtrl.dispose();
    _mobilePhoneCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final compactFieldHeight = 4.4.h;
    final compactTitleSize = 13.6.sp;
    final compactInputSize = 13.2.sp;

    return Padding(
      padding: EdgeInsets.only(
        left: 4.2.w,
        right: 4.2.w,
        top: 1.8.h,
        bottom: viewInsets.bottom + 2.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
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
                        widget.initialService == null
                            ? 'Add Service'
                            : 'Edit Service',
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
                controller: _nameCtrl,
                title: 'Name',
                hint: 'Enter service name',
                height: compactFieldHeight,
                titleFontSize: compactTitleSize,
                fieldFontSize: compactInputSize,
                hintFontSize: compactInputSize,
                titleBottomSpacing: .65.h,
                inputVerticalPadding: 1.0.h,
              ),
              verticalSpace(height: 1.0.h),
              Text(
                'Expiration by',
                style: TextStyle(
                  fontSize: compactTitleSize,
                  fontWeight: FontWeight.w500,
                  color: onSurface,
                ),
              ),
              verticalSpace(height: .65.h),
              SizedBox(
                height: compactFieldHeight,
                child: DropdownButtonFormField<String>(
                  isDense: true,
                  initialValue: _expirationBy,
                  style: TextStyle(
                    fontSize: compactInputSize,
                    color: onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: .7.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'odometer', child: Text('Odometer')),
                    DropdownMenuItem(
                        value: 'engine_hours', child: Text('Engine Hours')),
                    DropdownMenuItem(value: 'days', child: Text('Date/Days')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _expirationBy = value;
                      if (_expirationBy == 'days') {
                        _lastServiceDate ??=
                            _tryParseFlexibleDate(_lastServiceCtrl.text);
                      }
                    });
                  },
                ),
              ),
              verticalSpace(height: 1.0.h),
              MaintenanceField(
                controller: _intervalCtrl,
                title: 'Interval',
                hint: 'e.g. 5000',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                height: compactFieldHeight,
                titleFontSize: compactTitleSize,
                fieldFontSize: compactInputSize,
                hintFontSize: compactInputSize,
                titleBottomSpacing: .65.h,
                inputVerticalPadding: 1.0.h,
              ),
              verticalSpace(height: 1.0.h),
              _expirationBy == 'days'
                  ? MaintenanceField(
                      title: 'Last Service Date',
                      hint: _lastServiceDate == null
                          ? 'Pick date'
                          : DateFormat('dd MMM yyyy').format(_lastServiceDate!),
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _lastServiceDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked == null) return;
                        setState(() {
                          _lastServiceDate = picked;
                          _lastServiceCtrl.text =
                              DateFormat('yyyy-MM-dd').format(picked);
                        });
                      },
                    )
                  : MaintenanceField(
                      controller: _lastServiceCtrl,
                      title: 'Last Service',
                      hint: 'e.g. 12000',
                      keyboardType: TextInputType.text,
                      height: compactFieldHeight,
                      titleFontSize: compactTitleSize,
                      fieldFontSize: compactInputSize,
                      hintFontSize: compactInputSize,
                      titleBottomSpacing: .65.h,
                      inputVerticalPadding: 1.0.h,
                    ),
              verticalSpace(height: 1.0.h),
              MaintenanceField(
                controller: _triggerEventLeftCtrl,
                title: 'Trigger Event Left',
                hint: 'Optional',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                height: compactFieldHeight,
                titleFontSize: compactTitleSize,
                fieldFontSize: compactInputSize,
                hintFontSize: compactInputSize,
                titleBottomSpacing: .65.h,
                inputVerticalPadding: 1.0.h,
              ),
              verticalSpace(height: 1.0.h),
              MaintenanceField(
                controller: _descriptionCtrl,
                title: 'Description',
                hint: 'Optional notes',
                height: compactFieldHeight,
                titleFontSize: compactTitleSize,
                fieldFontSize: compactInputSize,
                hintFontSize: compactInputSize,
                titleBottomSpacing: .65.h,
                inputVerticalPadding: 1.0.h,
              ),
              verticalSpace(height: .9.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Renew after expiration',
                      style: TextStyle(
                        fontSize: 13.2.sp,
                        color: onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _renewAfterExpiration,
                    onChanged: (value) {
                      setState(() => _renewAfterExpiration = value);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Expires',
                      style: TextStyle(
                        fontSize: 13.2.sp,
                        color: onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _expires,
                    onChanged: (value) {
                      setState(() {
                        _expires = value;
                        if (!value) {
                          _expiresDate = null;
                        }
                      });
                    },
                  ),
                ],
              ),
              if (_expires)
                Padding(
                  padding: EdgeInsets.only(bottom: .85.h),
                  child: MaintenanceField(
                    title: 'Expires Date',
                    hint: _expiresDate == null
                        ? 'Pick date'
                        : DateFormat('dd MMM yyyy').format(_expiresDate!),
                    height: compactFieldHeight,
                    titleFontSize: compactTitleSize,
                    fieldFontSize: compactInputSize,
                    hintFontSize: compactInputSize,
                    titleBottomSpacing: .65.h,
                    inputVerticalPadding: 1.0.h,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expiresDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _expiresDate = picked);
                      }
                    },
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Remind',
                      style: TextStyle(
                        fontSize: 13.2.sp,
                        color: onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _remind,
                    onChanged: (value) {
                      setState(() {
                        _remind = value;
                        if (!value) {
                          _remindDate = null;
                        }
                      });
                    },
                  ),
                ],
              ),
              if (_remind)
                Padding(
                  padding: EdgeInsets.only(bottom: .85.h),
                  child: MaintenanceField(
                    title: 'Remind Date',
                    hint: _remindDate == null
                        ? 'Pick date'
                        : DateFormat('dd MMM yyyy').format(_remindDate!),
                    height: compactFieldHeight,
                    titleFontSize: compactTitleSize,
                    fieldFontSize: compactInputSize,
                    hintFontSize: compactInputSize,
                    titleBottomSpacing: .65.h,
                    inputVerticalPadding: 1.0.h,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _remindDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _remindDate = picked);
                      }
                    },
                  ),
                ),
              MaintenanceField(
                controller: _emailCtrl,
                title: 'Email',
                hint: 'Optional (use ; for multiple)',
                keyboardType: TextInputType.emailAddress,
                height: compactFieldHeight,
                titleFontSize: compactTitleSize,
                fieldFontSize: compactInputSize,
                hintFontSize: compactInputSize,
                titleBottomSpacing: .65.h,
                inputVerticalPadding: 1.0.h,
              ),
              verticalSpace(height: 1.0.h),
              MaintenanceField(
                controller: _mobilePhoneCtrl,
                title: 'Mobile Phone',
                hint: 'Optional (use ; for multiple)',
                keyboardType: TextInputType.phone,
                height: compactFieldHeight,
                titleFontSize: compactTitleSize,
                fieldFontSize: compactInputSize,
                hintFontSize: compactInputSize,
                titleBottomSpacing: .65.h,
                inputVerticalPadding: 1.0.h,
              ),
              verticalSpace(height: 1.4.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      backgroundColor: Colors.transparent,
                      textColor: onSurface.withValues(alpha: .82),
                      height: 4.4.h,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  horizontalSpace(width: 3.w),
                  Expanded(
                    child: CustomButton(
                      text: widget.initialService == null ? 'Save' : 'Update',
                      height: 4.4.h,
                      onPressed: () async {
                        final name = _nameCtrl.text.trim();
                        final interval = _intervalCtrl.text.trim();
                        final lastService = _lastServiceCtrl.text.trim();
                        if (name.isEmpty ||
                            interval.isEmpty ||
                            lastService.isEmpty) {
                          await showValidationErrorDialog(
                            context,
                            message:
                                'Name, Interval and Last Service are required',
                          );
                          return;
                        }

                        if (_expirationBy == 'days' &&
                            _lastServiceDate == null) {
                          await showValidationErrorDialog(
                            context,
                            message: 'Please select Last Service date',
                          );
                          return;
                        }

                        final triggerText = _triggerEventLeftCtrl.text.trim();
                        if (triggerText.isNotEmpty) {
                          final intervalNum = double.tryParse(interval);
                          final triggerNum = double.tryParse(triggerText);
                          if (intervalNum == null || triggerNum == null) {
                            await showValidationErrorDialog(
                              context,
                              message:
                                  'Interval and Trigger Event Left must be numeric',
                            );
                            return;
                          }
                          if (triggerNum >= intervalNum) {
                            await showValidationErrorDialog(
                              context,
                              message:
                                  'Trigger Event Left must be less than Interval',
                            );
                            return;
                          }
                        }

                        if (_expires && _expiresDate == null) {
                          await showValidationErrorDialog(
                            context,
                            message: 'Please select expires date',
                          );
                          return;
                        }

                        if (_remind && _remindDate == null) {
                          await showValidationErrorDialog(
                            context,
                            message: 'Please select remind date',
                          );
                          return;
                        }

                        Navigator.pop(
                          context,
                          ServiceFormData(
                            name: name,
                            expirationBy: _expirationBy,
                            interval: interval,
                            lastService: lastService,
                            triggerEventLeft:
                                _triggerEventLeftCtrl.text.trim().isEmpty
                                    ? null
                                    : _triggerEventLeftCtrl.text.trim(),
                            renewAfterExpiration: _renewAfterExpiration,
                            expires: _expires,
                            expiresDate: _expiresDate,
                            remind: _remind,
                            remindDate: _remindDate,
                            email: _emailCtrl.text.trim().isEmpty
                                ? null
                                : _emailCtrl.text.trim(),
                            mobilePhone: _mobilePhoneCtrl.text.trim().isEmpty
                                ? null
                                : _mobilePhoneCtrl.text.trim(),
                            description: _descriptionCtrl.text.trim().isEmpty
                                ? null
                                : _descriptionCtrl.text.trim(),
                          ),
                        );
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
  }
}
