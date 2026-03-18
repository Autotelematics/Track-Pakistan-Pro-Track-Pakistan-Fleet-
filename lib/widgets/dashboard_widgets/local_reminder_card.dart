import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/app/theme/popups.dart';
import 'package:trackerapp/data/models/local_reminder_model.dart';
import 'package:trackerapp/providers/reminder_provider.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/widgets/dashboard_widgets/dashboard_scale.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';

class LocalReminderCard extends StatelessWidget {
  const LocalReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final activeCount = context.select<ReminderProvider, int>(
      (provider) => provider.reminders
          .where((r) => r.repeatType != "none" || !r.dueAt.isBefore(now))
          .length,
    );
    final pastCount = context.select<ReminderProvider, int>(
      (provider) => provider.reminders
          .where((r) => r.repeatType == "none" && r.dueAt.isBefore(now))
          .length,
    );

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
          Text(
            "Local Reminders",
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 15.sp,
            ),
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
                _reminderRow(
                  context,
                  title: "Active reminders",
                  icon: Icons.notifications_active_outlined,
                  iconColor: const Color(0xFF2563EB),
                  count: activeCount.toString(),
                  onTap: () =>
                      _showReminderListSheet(context, showActive: true),
                ),
                Divider(
                    height: 1.7.h, color: onSurface.withValues(alpha: 0.12)),
                _reminderRow(
                  context,
                  title: "Past reminders",
                  icon: Icons.history_rounded,
                  iconColor: const Color(0xFF6B7280),
                  count: pastCount.toString(),
                  onTap: () =>
                      _showReminderListSheet(context, showActive: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reminderRow(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required String count,
    required VoidCallback onTap,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final iconScale = dashboardIconScale(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: .15.h),
        child: Row(
          children: [
            Container(
              height: 3.3.h,
              width: 3.3.h,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: (17 * iconScale).sp),
            ),
            horizontalSpace(width: 2.2.w),
            Expanded(
              child: Text(
                title,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 0.45.h),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: iconColor.withValues(alpha: 0.28)),
              ),
              child: Text(
                "$count Items",
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5.sp,
                ),
              ),
            ),
            horizontalSpace(width: .7.h),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: (15 * iconScale).sp,
              color: onSurface.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteReminder(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Reminder"),
        content: const Text("Are you sure you want to delete this reminder?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showReminderListSheet(
    BuildContext context, {
    required bool showActive,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final title = showActive ? "Active reminders" : "Past reminders";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Consumer<ReminderProvider>(
          builder: (sheetContext, provider, __) {
            final now = DateTime.now();
            final reminders = provider.reminders.where((r) {
              return showActive
                  ? (r.repeatType != "none" || !r.dueAt.isBefore(now))
                  : (r.repeatType == "none" && r.dueAt.isBefore(now));
            }).toList()
              ..sort((a, b) => showActive
                  ? a.dueAt.compareTo(b.dueAt)
                  : b.dueAt.compareTo(a.dueAt));

            return Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 72.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0E1624) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 1.2.h),
                child: Column(
                  children: [
                    Container(
                      width: 10.w,
                      height: .45.h,
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    verticalSpace(height: 1.2.h),
                    Text(
                      title,
                      style: AppStyles.semiboldTextStyle(context).copyWith(
                        fontSize: 14.sp,
                        color: onSurface,
                      ),
                    ),
                    verticalSpace(height: 1.2.h),
                    if (reminders.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Text(
                          "No reminders found",
                          style: AppStyles.regularTextStyle(context).copyWith(
                            fontSize: 13.8.sp,
                            color: onSurface.withValues(alpha: .65),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: reminders.length,
                          separatorBuilder: (_, __) =>
                              verticalSpace(height: .8.h),
                          itemBuilder: (tileContext, index) {
                            final reminder = reminders[index];
                            return _DashboardReminderTile(
                              reminder: reminder,
                              onEdit: () async {
                                Navigator.pop(tileContext);
                                await showAddReminderPopup(
                                  context,
                                  deviceId: reminder.deviceId,
                                  vehicleName: reminder.vehicleName,
                                  existingReminder: reminder,
                                );
                              },
                              onDelete: () async {
                                final confirmed =
                                    await _confirmDeleteReminder(context);
                                if (!confirmed) return;
                                await context
                                    .read<ReminderProvider>()
                                    .deleteReminder(reminder.id);
                                AppSnackBar.success(
                                    message: "Reminder deleted");
                              },
                            );
                          },
                        ),
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
}

class _DashboardReminderTile extends StatelessWidget {
  final LocalReminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DashboardReminderTile({
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final iconScale = dashboardIconScale(context);
    final dueDate = DateFormat('dd/MM/yyyy').format(reminder.dueAt);
    final dueTime = DateFormat('hh:mm a').format(reminder.dueAt);
    final description = reminder.description.trim();
    final repeatLabel = reminder.repeatType == "none"
        ? "One-time"
        : "Recurring • ${_prettyRepeat(reminder.repeatType)}";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.0.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${reminder.vehicleName} - ${reminder.title}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 13.8.sp,
                    color: onSurface,
                  ),
                ),
              ),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(1.2.w),
                  child: Icon(
                    Icons.edit_rounded,
                    size: (16.5 * iconScale).sp,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              horizontalSpace(width: .8.w),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(1.2.w),
                  child: Icon(
                    Icons.delete_rounded,
                    size: (16.8 * iconScale).sp,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(height: .35.h),
          Text(
            description.isEmpty ? "No description" : description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 13.5.sp,
              color: onSurface.withValues(alpha: .74),
            ),
          ),
          verticalSpace(height: .28.h),
          Text(
            repeatLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.regularTextStyle(context).copyWith(
              fontSize: 12.6.sp,
              fontWeight: FontWeight.w600,
              color: reminder.repeatType == "none"
                  ? onSurface.withValues(alpha: .62)
                  : const Color(0xFF2563EB),
            ),
          ),
          verticalSpace(height: .55.h),
          Row(
            children: [
              Icon(Icons.event_rounded,
                  size: (14.5 * iconScale).sp, color: const Color(0xFF2563EB)),
              horizontalSpace(width: 1.2.w),
              Text(
                dueDate,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 12.7.sp,
                  color: onSurface.withValues(alpha: .8),
                ),
              ),
              horizontalSpace(width: 3.w),
              Icon(Icons.access_time_rounded,
                  size: (14.5 * iconScale).sp, color: const Color(0xFF2563EB)),
              horizontalSpace(width: 1.2.w),
              Text(
                dueTime,
                style: AppStyles.regularTextStyle(context).copyWith(
                  fontSize: 12.7.sp,
                  color: onSurface.withValues(alpha: .8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _prettyRepeat(String repeatType) {
    switch (repeatType) {
      case "daily":
        return "Daily";
      case "weekly":
        return "Weekly";
      case "monthly":
        return "Monthly";
      case "yearly":
        return "Yearly";
      default:
        return repeatType;
    }
  }
}
