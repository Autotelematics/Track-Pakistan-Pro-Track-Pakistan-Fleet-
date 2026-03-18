import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/repositories/admin_push_notification_repository.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/white_labeling/colors.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/custom_text_field.dart';

class AdminPushNotificationScreen extends StatefulWidget {
  const AdminPushNotificationScreen({super.key});

  @override
  State<AdminPushNotificationScreen> createState() =>
      _AdminPushNotificationScreenState();
}

class _AdminPushNotificationScreenState
    extends State<AdminPushNotificationScreen> {
  final _repo = AdminPushNotificationRepository();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _fcmController = TextEditingController();
  final _priorityController = TextEditingController(text: "10");
  final _soundController = TextEditingController();
  final _dataController = TextEditingController();
  final _dailyTimeController = TextEditingController();
  final _weeklyDayController = TextEditingController();
  final _weeklyTimeController = TextEditingController();
  final _monthlyDayController = TextEditingController();
  final _monthlyTimeController = TextEditingController();
  final _yearlyMonthController = TextEditingController();
  final _yearlyDayController = TextEditingController();
  final _yearlyTimeController = TextEditingController();
  final _customDateController = TextEditingController();
  final _customTimeController = TextEditingController();

  bool _isSending = false;
  bool _sendToAll = false;
  bool _scheduleEnabled = false;
  String _scheduleType = "daily";
  bool _isLoadingUsers = false;
  List<AdminUserWithTokensItem> _usersWithTokens = const [];
  List<AdminUserWithTokensItem> _selectedUsers = const [];
  List<Map<String, dynamic>> _history = const [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadUsersWithTokens();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _fcmController.dispose();
    _priorityController.dispose();
    _soundController.dispose();
    _dataController.dispose();
    _dailyTimeController.dispose();
    _weeklyDayController.dispose();
    _weeklyTimeController.dispose();
    _monthlyDayController.dispose();
    _monthlyTimeController.dispose();
    _yearlyMonthController.dispose();
    _yearlyDayController.dispose();
    _yearlyTimeController.dispose();
    _customDateController.dispose();
    _customTimeController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    final raw =
        MySharedPreferences.getStringList(adminPushNotificationHistoryKey);
    final parsed = <Map<String, dynamic>>[];
    for (final row in raw) {
      try {
        final decoded = jsonDecode(row);
        if (decoded is Map<String, dynamic>) parsed.add(decoded);
      } catch (_) {}
    }
    setState(() {
      _history = parsed;
    });
  }

  Future<void> _saveHistoryItem(Map<String, dynamic> item) async {
    final current = List<Map<String, dynamic>>.from(_history);
    current.insert(0, item);
    if (current.length > 100) {
      current.removeRange(100, current.length);
    }
    final encoded = current.map(jsonEncode).toList(growable: false);
    await MySharedPreferences.setStringList(
        adminPushNotificationHistoryKey, encoded);
    if (!mounted) return;
    setState(() {
      _history = current;
    });
  }

  Future<void> _loadUsersWithTokens() async {
    setState(() {
      _isLoadingUsers = true;
    });
    final token = MySharedPreferences.getString(authTokenKey).trim();
    final users = await _repo.getAdminUsersWithTokens(token: token);
    if (!mounted) return;
    setState(() {
      _usersWithTokens = users;
      final selectedIds = _selectedUsers.map((user) => user.userId).toSet();
      _selectedUsers = users
          .where((u) => selectedIds.contains(u.userId))
          .toList(growable: false);
      _isLoadingUsers = false;
    });
  }

  Future<void> _openUserPicker() async {
    if (_sendToAll) return;
    final searchController = TextEditingController();
    final selected = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        List<AdminUserWithTokensItem> filtered = _usersWithTokens;
        final selectedIds = _selectedUsers.map((user) => user.userId).toSet();
        return StatefulBuilder(
          builder: (context, setLocalState) {
            void onSearchChanged(String value) {
              final q = value.trim().toLowerCase();
              setLocalState(() {
                filtered = _usersWithTokens.where((user) {
                  return user.userEmail.toLowerCase().contains(q) ||
                      user.userId.toString().contains(q);
                }).toList(growable: false);
              });
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 4.w,
                  right: 4.w,
                  top: 1.2.h,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 1.2.h,
                ),
                child: SizedBox(
                  height: 70.h,
                  child: Column(
                    children: [
                      Text(
                        "Select Users",
                        style: AppStyles.semiboldTextStyle(context)
                            .copyWith(fontSize: 16.sp),
                      ),
                      SizedBox(height: 1.h),
                      TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        decoration: InputDecoration(
                          labelText: "Search by email or id",
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  "No users found.",
                                  style: AppStyles.regularTextStyle(context),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (_, index) {
                                  final item = filtered[index];
                                  final isSelected =
                                      selectedIds.contains(item.userId);
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () {
                                      setLocalState(() {
                                        if (isSelected) {
                                          selectedIds.remove(item.userId);
                                        } else {
                                          selectedIds.add(item.userId);
                                        }
                                      });
                                    },
                                    title: Text(
                                      item.userEmail,
                                      style:
                                          AppStyles.semiboldTextStyle(context),
                                    ),
                                    subtitle: Text(
                                      "ID: ${item.userId} • Tokens: ${item.fcmTokens.length}",
                                      style:
                                          AppStyles.regularTextStyle(context),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (item.activeStatus == 1)
                                          const Icon(Icons.check_circle,
                                              color: Colors.green)
                                        else
                                          const Icon(Icons.cancel,
                                              color: Colors.red),
                                        SizedBox(width: 2.w),
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (_) {
                                            setLocalState(() {
                                              if (isSelected) {
                                                selectedIds.remove(item.userId);
                                              } else {
                                                selectedIds.add(item.userId);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      SizedBox(height: .8.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(
                            sheetContext,
                            selectedIds.toList(growable: false),
                          ),
                          child: Text(
                            "Apply (${selectedIds.length} selected)",
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
      },
    );
    searchController.dispose();

    if (selected == null || !mounted) return;
    setState(() {
      final idSet = selected.toSet();
      _selectedUsers = _usersWithTokens
          .where((u) => idSet.contains(u.userId))
          .toList(growable: false);
    });
  }

  String? _validateRecipients() {
    if (_sendToAll) return null;
    final hasUserSelection = _selectedUsers.isNotEmpty;
    final token = _fcmController.text.trim();
    if (!hasUserSelection && token.isEmpty) {
      return "Select target user(s) or enter FCM token(s), or enable Send to All";
    }
    return null;
  }

  String? _validateScheduleFields() {
    if (!_scheduleEnabled) return null;

    bool isEmpty(TextEditingController c) => c.text.trim().isEmpty;
    switch (_scheduleType) {
      case "daily":
        return isEmpty(_dailyTimeController)
            ? "daily_time is required for daily schedule"
            : null;
      case "weekly":
        if (isEmpty(_weeklyDayController)) return "weekly_day is required";
        return isEmpty(_weeklyTimeController)
            ? "weekly_time is required"
            : null;
      case "monthly":
        if (isEmpty(_monthlyDayController)) return "monthly_day is required";
        return isEmpty(_monthlyTimeController)
            ? "monthly_time is required"
            : null;
      case "yearly":
        if (isEmpty(_yearlyMonthController)) return "yearly_month is required";
        if (isEmpty(_yearlyDayController)) return "yearly_day is required";
        return isEmpty(_yearlyTimeController)
            ? "yearly_time is required"
            : null;
      case "custom":
        if (isEmpty(_customDateController)) return "custom_date is required";
        return isEmpty(_customTimeController)
            ? "custom_time is required"
            : null;
      default:
        return "Invalid schedule type";
    }
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final recipientError = _validateRecipients();
    if (recipientError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(recipientError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final scheduleError = _validateScheduleFields();
    if (scheduleError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(scheduleError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _isSending = true;
    });

    final token = MySharedPreferences.getString(authTokenKey).trim();
    final selectedUserIds =
        _selectedUsers.map((e) => e.userId).toList(growable: false);
    final result = await _repo.sendPushNotification(
      token: token,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      sendToAll: _sendToAll ? 1 : 0,
      targetUserId:
          selectedUserIds.length == 1 ? selectedUserIds.first.toString() : null,
      targetUserIds: selectedUserIds,
      fcmToken: _fcmController.text.trim(),
      priority: _priorityController.text.trim().isEmpty
          ? "10"
          : _priorityController.text.trim(),
      sound: _soundController.text.trim(),
      data: _dataController.text.trim(),
      scheduleEnabled: _scheduleEnabled ? 1 : 0,
      scheduleType: _scheduleEnabled ? _scheduleType : null,
      dailyTime: _dailyTimeController.text.trim(),
      weeklyDay: _weeklyDayController.text.trim(),
      weeklyTime: _weeklyTimeController.text.trim(),
      monthlyDay: _monthlyDayController.text.trim(),
      monthlyTime: _monthlyTimeController.text.trim(),
      yearlyMonth: _yearlyMonthController.text.trim(),
      yearlyDay: _yearlyDayController.text.trim(),
      yearlyTime: _yearlyTimeController.text.trim(),
      customDate: _customDateController.text.trim(),
      customTime: _customTimeController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _isSending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (result.success) {
      await _saveHistoryItem({
        "sent_at": DateTime.now().toIso8601String(),
        "title": _titleController.text.trim(),
        "body": _bodyController.text.trim(),
        "send_to_all": _sendToAll ? "1" : "0",
        "target_user_ids": selectedUserIds,
        "fcm_token": _fcmController.text.trim(),
        "priority": _priorityController.text.trim().isEmpty
            ? "10"
            : _priorityController.text.trim(),
        "sound": _soundController.text.trim(),
        "data": _dataController.text.trim(),
        "schedule_enabled": _scheduleEnabled ? "1" : "0",
        "schedule_type": _scheduleEnabled ? _scheduleType : "",
      });
    }
  }

  Widget _textField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    VoidCallback? onTap,
    bool enabled = true,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomTextField(
      controller: controller,
      labelText: label,
      maxLines: maxLines,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixTap: onSuffixTap,
      onTap: onTap,
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

  DateTime _safeInitialDate(String value) {
    try {
      if (value.trim().isNotEmpty) {
        return DateFormat('yyyy-MM-dd').parseStrict(value.trim());
      }
    } catch (_) {}
    return DateTime.now();
  }

  TimeOfDay _safeInitialTime(String value) {
    final parts = value.trim().split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null &&
          minute != null &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return TimeOfDay.now();
  }

  Future<DateTime?> _pickDateBottomSheet(
    DateTime? initial, {
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
    DateTime tempDate = initial ?? DateTime.now();
    final minimum = dateOnly(minDate ?? DateTime.now());
    final maximum = dateOnly(maxDate ?? DateTime(2100));
    tempDate = dateOnly(tempDate);
    if (tempDate.isBefore(minimum)) tempDate = minimum;
    if (tempDate.isAfter(maximum)) tempDate = maximum;

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2433) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 1.h, bottom: .6.h),
                width: 10.w,
                height: .45.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
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
                  minimumDate: minimum,
                  maximumDate: maximum,
                  onDateTimeChanged: (value) => tempDate = value,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<TimeOfDay?> _pickTimeBottomSheet(
    TimeOfDay? initial, {
    DateTime? selectedDate,
  }) async {
    final now = DateTime.now();
    final pickedDate = selectedDate ?? now;
    DateTime tempTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      initial?.hour ?? now.hour,
      initial?.minute ?? now.minute,
    );
    if (!tempTime.isAfter(now)) {
      tempTime = now.add(const Duration(minutes: 1));
    }

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: 34.h,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2433) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 1.h, bottom: .6.h),
                width: 10.w,
                height: .45.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
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
                      onPressed: () {
                        final selected = DateTime(
                          tempTime.year,
                          tempTime.month,
                          tempTime.day,
                          tempTime.hour,
                          tempTime.minute,
                        );
                        if (!selected.isAfter(DateTime.now())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Please select a future time, not past."),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(ctx, tempTime);
                      },
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
                  use24hFormat: false,
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

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await _pickDateBottomSheet(
      _safeInitialDate(controller.text),
      minDate: DateTime.now(),
      maxDate: DateTime(2100),
    );
    if (picked == null) return;
    controller.text = DateFormat('yyyy-MM-dd').format(picked);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickTime(
    TextEditingController controller, {
    DateTime? selectedDate,
  }) async {
    final picked = await _pickTimeBottomSheet(
      _safeInitialTime(controller.text),
      selectedDate: selectedDate,
    );
    if (picked == null) return;
    final now = DateTime.now();
    final dt =
        DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    controller.text = DateFormat('HH:mm').format(dt);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickWeeklyDate() async {
    final picked = await _pickDateBottomSheet(
      DateTime.now(),
      minDate: DateTime.now(),
      maxDate: DateTime(2100),
    );
    if (picked == null) return;
    _weeklyDayController.text = picked.weekday.toString();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickMonthlyDate() async {
    final picked = await _pickDateBottomSheet(
      DateTime.now(),
      minDate: DateTime.now(),
      maxDate: DateTime(2100),
    );
    if (picked == null) return;
    _monthlyDayController.text = picked.day.toString();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickYearlyDate() async {
    final picked = await _pickDateBottomSheet(
      DateTime.now(),
      minDate: DateTime.now(),
      maxDate: DateTime(2100),
    );
    if (picked == null) return;
    _yearlyMonthController.text = picked.month.toString();
    _yearlyDayController.text = picked.day.toString();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                      icon: Icon(Icons.arrow_back,
                          color: isDark ? onSurface : AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        "Send Firebase Notification",
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
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(5.w, 2.2.h, 5.w, 2.4.h),
                      children: [
                        _textField(
                          context: context,
                          controller: _titleController,
                          label: "Title",
                          prefixIcon: Icons.title_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Title is required"
                              : null,
                        ),
                        SizedBox(height: 1.2.h),
                        _textField(
                          context: context,
                          controller: _bodyController,
                          label: "Body",
                          prefixIcon: Icons.notes_rounded,
                          maxLines: 3,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Body is required"
                              : null,
                        ),
                        SizedBox(height: 1.2.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                opacity: _sendToAll ? 0.45 : 1,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: (_sendToAll || _isLoadingUsers)
                                      ? null
                                      : _openUserPicker,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: "Target User(s) (optional)",
                                      prefixIcon: const Icon(
                                          Icons.person_search_rounded),
                                      suffixIcon: _isLoadingUsers
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                            )
                                          : IconButton(
                                              onPressed: _sendToAll
                                                  ? null
                                                  : _loadUsersWithTokens,
                                              icon: const Icon(Icons.refresh),
                                            ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      _selectedUsers.isEmpty
                                          ? "Tap to select user(s)"
                                          : "${_selectedUsers.length} user(s) selected",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          AppStyles.regularTextStyle(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.2.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                opacity: _sendToAll ? 0.45 : 1,
                                child: _textField(
                                  context: context,
                                  controller: _fcmController,
                                  label: "FCM Token(s) (comma/newline)",
                                  prefixIcon: Icons.vpn_key_rounded,
                                  maxLines: 2,
                                  enabled: !_sendToAll,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Container(
                              margin: EdgeInsets.only(top: .8.h),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.2.w, vertical: .4.h),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: .12),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Checkbox(
                                    value: _sendToAll,
                                    onChanged: (value) {
                                      setState(() {
                                        _sendToAll = value ?? false;
                                      });
                                    },
                                  ),
                                  Text(
                                    "Send to All",
                                    style: AppStyles.regularTextStyle(context)
                                        .copyWith(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!_sendToAll && _selectedUsers.isNotEmpty) ...[
                          SizedBox(height: .8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: .12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Saved FCM Tokens for selected users",
                                  style: AppStyles.semiboldTextStyle(context),
                                ),
                                SizedBox(height: .6.h),
                                ..._selectedUsers.map(
                                  (user) => Padding(
                                    padding: EdgeInsets.only(bottom: .75.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${user.userEmail} (ID: ${user.userId})",
                                          style: AppStyles.semiboldTextStyle(
                                              context),
                                        ),
                                        SizedBox(height: .25.h),
                                        if (user.fcmTokens.isEmpty)
                                          Text(
                                            "No saved token found.",
                                            style: AppStyles.regularTextStyle(
                                                context),
                                          )
                                        else
                                          ...user.fcmTokens.asMap().entries.map(
                                                (entry) => Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: .35.h),
                                                  child: Text(
                                                    "${entry.key + 1}. ${entry.value}",
                                                    style: AppStyles
                                                        .regularTextStyle(
                                                            context),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 1.2.h),
                        _textField(
                          context: context,
                          controller: _priorityController,
                          label: "Priority (5 or 10)",
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.low_priority_rounded,
                          validator: (v) {
                            final value = (v ?? "").trim();
                            if (value.isEmpty) return null;
                            if (value == "5" || value == "10") return null;
                            return "Priority must be 5 or 10";
                          },
                        ),
                        SizedBox(height: 1.2.h),
                        _textField(
                          context: context,
                          controller: _soundController,
                          label: "Sound (optional)",
                          prefixIcon: Icons.music_note_rounded,
                        ),
                        SizedBox(height: 1.2.h),
                        _textField(
                          context: context,
                          controller: _dataController,
                          label: "Data (array/JSON string, optional)",
                          prefixIcon: Icons.data_object_rounded,
                          maxLines: 2,
                        ),
                        SizedBox(height: 1.2.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.2.h),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: .12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Enable Schedule",
                                      style: AppStyles.regularTextStyle(context)
                                          .copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: _scheduleEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _scheduleEnabled = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_scheduleEnabled) ...[
                                SizedBox(height: 1.h),
                                DropdownButtonFormField<String>(
                                  initialValue: _scheduleType,
                                  decoration: InputDecoration(
                                    labelText: "Schedule Type",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: "daily", child: Text("daily")),
                                    DropdownMenuItem(
                                        value: "weekly", child: Text("weekly")),
                                    DropdownMenuItem(
                                        value: "monthly",
                                        child: Text("monthly")),
                                    DropdownMenuItem(
                                        value: "yearly", child: Text("yearly")),
                                    DropdownMenuItem(
                                        value: "custom", child: Text("custom")),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      _scheduleType = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 1.2.h),
                                if (_scheduleType == "daily")
                                  _textField(
                                    context: context,
                                    controller: _dailyTimeController,
                                    label: "daily_time (e.g. 10:30)",
                                    prefixIcon: Icons.schedule_rounded,
                                    suffixIcon: Icons.access_time_rounded,
                                    onTap: () =>
                                        _pickTime(_dailyTimeController),
                                    onSuffixTap: () =>
                                        _pickTime(_dailyTimeController),
                                    readOnly: true,
                                  ),
                                if (_scheduleType == "weekly") ...[
                                  _textField(
                                    context: context,
                                    controller: _weeklyDayController,
                                    label: "weekly_day (pick date -> 1-7)",
                                    prefixIcon: Icons.calendar_today_rounded,
                                    suffixIcon: Icons.calendar_month_rounded,
                                    onTap: _pickWeeklyDate,
                                    onSuffixTap: _pickWeeklyDate,
                                    readOnly: true,
                                  ),
                                  SizedBox(height: 1.2.h),
                                  _textField(
                                    context: context,
                                    controller: _weeklyTimeController,
                                    label: "weekly_time (e.g. 10:30)",
                                    prefixIcon: Icons.schedule_rounded,
                                    suffixIcon: Icons.access_time_rounded,
                                    onTap: () =>
                                        _pickTime(_weeklyTimeController),
                                    onSuffixTap: () =>
                                        _pickTime(_weeklyTimeController),
                                    readOnly: true,
                                  ),
                                ],
                                if (_scheduleType == "monthly") ...[
                                  _textField(
                                    context: context,
                                    controller: _monthlyDayController,
                                    label: "monthly_day (pick date -> 1-31)",
                                    prefixIcon: Icons.calendar_month_rounded,
                                    suffixIcon: Icons.calendar_month_rounded,
                                    onTap: _pickMonthlyDate,
                                    onSuffixTap: _pickMonthlyDate,
                                    readOnly: true,
                                  ),
                                  SizedBox(height: 1.2.h),
                                  _textField(
                                    context: context,
                                    controller: _monthlyTimeController,
                                    label: "monthly_time (e.g. 10:30)",
                                    prefixIcon: Icons.schedule_rounded,
                                    suffixIcon: Icons.access_time_rounded,
                                    onTap: () =>
                                        _pickTime(_monthlyTimeController),
                                    onSuffixTap: () =>
                                        _pickTime(_monthlyTimeController),
                                    readOnly: true,
                                  ),
                                ],
                                if (_scheduleType == "yearly") ...[
                                  _textField(
                                    context: context,
                                    controller: _yearlyMonthController,
                                    label: "yearly_month (pick date -> 1-12)",
                                    prefixIcon: Icons.event_rounded,
                                    suffixIcon: Icons.calendar_month_rounded,
                                    onTap: _pickYearlyDate,
                                    onSuffixTap: _pickYearlyDate,
                                    readOnly: true,
                                  ),
                                  SizedBox(height: 1.2.h),
                                  _textField(
                                    context: context,
                                    controller: _yearlyDayController,
                                    label: "yearly_day (auto from date picker)",
                                    prefixIcon: Icons.event_note_rounded,
                                    suffixIcon: Icons.calendar_month_rounded,
                                    onTap: _pickYearlyDate,
                                    onSuffixTap: _pickYearlyDate,
                                    readOnly: true,
                                  ),
                                  SizedBox(height: 1.2.h),
                                  _textField(
                                    context: context,
                                    controller: _yearlyTimeController,
                                    label: "yearly_time (e.g. 10:30)",
                                    prefixIcon: Icons.schedule_rounded,
                                    suffixIcon: Icons.access_time_rounded,
                                    onTap: () =>
                                        _pickTime(_yearlyTimeController),
                                    onSuffixTap: () =>
                                        _pickTime(_yearlyTimeController),
                                    readOnly: true,
                                  ),
                                ],
                                if (_scheduleType == "custom") ...[
                                  _textField(
                                    context: context,
                                    controller: _customDateController,
                                    label: "custom_date (YYYY-MM-DD)",
                                    prefixIcon: Icons.date_range_rounded,
                                    suffixIcon: Icons.calendar_month_rounded,
                                    onTap: () =>
                                        _pickDate(_customDateController),
                                    onSuffixTap: () =>
                                        _pickDate(_customDateController),
                                    readOnly: true,
                                  ),
                                  SizedBox(height: 1.2.h),
                                  _textField(
                                    context: context,
                                    controller: _customTimeController,
                                    label: "custom_time (HH:mm)",
                                    prefixIcon: Icons.access_time_rounded,
                                    suffixIcon: Icons.access_time_rounded,
                                    onTap: () => _pickTime(
                                      _customTimeController,
                                      selectedDate: _safeInitialDate(
                                          _customDateController.text),
                                    ),
                                    onSuffixTap: () => _pickTime(
                                      _customTimeController,
                                      selectedDate: _safeInitialDate(
                                          _customDateController.text),
                                    ),
                                    readOnly: true,
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 2.1.h),
                        CustomButton(
                          text: _isSending
                              ? "Sending..."
                              : _scheduleEnabled
                                  ? "Create Scheduled Notification"
                                  : "Send Notification",
                          onPressed: _isSending ? null : _send,
                          textColor: AppColors.yellow,
                          backgroundColor: theme.colorScheme.primary,
                          borderRadius: 14,
                          height: 5.8.h,
                          fontSize: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
