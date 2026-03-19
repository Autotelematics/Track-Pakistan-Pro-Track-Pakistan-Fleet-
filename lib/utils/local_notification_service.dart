import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:trackerapp/data/models/local_reminder_model.dart';
import 'package:trackerapp/data/models/get_alerts_list_model.dart';
import 'package:trackerapp/data/repositories/alerts_repository.dart';
import 'package:trackerapp/utils/alert_tts_service.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/providers/alerts_provider.dart';
import 'package:trackerapp/providers/motion_bottom_bar_provider.dart';
import 'package:trackerapp/providers/reminder_provider.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/alert_location_screen.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final AlertsRepository _alertsRepository = AlertsRepository();
  bool _isInitialized = false;
  int? _pendingReminderId;
  Item? _pendingAlertItem;
  GlobalKey<NavigatorState>? _navigatorKey;
  final Map<int, Timer> _foregroundTtsTimers = {};
  static const String _fallbackIosAlertSound = 'ignition_on.caf';

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'vehicle_reminders_channel',
    'Vehicle Reminders',
    description: 'Reminder alerts for vehicle actions',
    importance: Importance.high,
  );

  Future<void> init({bool requestPermissions = true}) async {
    if (_isInitialized) return;

    tzdata.initializeTimeZones();
    try {
      final localTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _setPendingTapFromPayload(response.payload);
        unawaited(processPendingNotificationTap());
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    if (requestPermissions) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _setPendingTapFromPayload(
        launchDetails?.notificationResponse?.payload,
      );
    }

    _isInitialized = true;
  }

  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  void _setPendingTapFromPayload(String? payload) {
    if (!MySharedPreferences.getBool(isLoggedInKey)) return;
    if (payload == null || payload.trim().isEmpty) return;

    if (payload.startsWith("reminder:")) {
      final idText = payload.replaceFirst("reminder:", "");
      final parsed = int.tryParse(idText);
      if (parsed != null) {
        _pendingReminderId = parsed;
      }
      return;
    }

    if (payload.startsWith("alert:")) {
      final encoded = payload.replaceFirst("alert:", "").trim();
      if (encoded.isEmpty) return;
      try {
        final decoded = jsonDecode(encoded);
        if (decoded is Map<String, dynamic>) {
          _pendingAlertItem = Item.fromJson(decoded);
        }
      } catch (_) {
        // Ignore malformed payload and keep app flow intact.
      }
    }
  }

  void registerRemoteMessageTap(RemoteMessage message) {
    if (!MySharedPreferences.getBool(isLoggedInKey)) return;
    final payloadMap = _extractRemoteAlertPayload(message);
    if (payloadMap == null) return;
    _pendingAlertItem = Item.fromJson(payloadMap);
  }

  void processPendingReminderTap() {
    if (!MySharedPreferences.getBool(isLoggedInKey)) {
      _pendingReminderId = null;
      return;
    }
    final reminderId = _pendingReminderId;
    if (reminderId == null) return;

    final navContext = _navigatorKey?.currentContext;
    if (navContext == null) return;

    _pendingReminderId = null;
    final reminder =
        navContext.read<ReminderProvider>().reminderById(reminderId);
    if (reminder == null) return;
    final ttsBody = reminder.description.trim().isEmpty
        ? '${reminder.type} reminder is due now'
        : reminder.description.trim();
    AlertTtsService.instance.speakText(
      "Reminder details. ${reminder.vehicleName}. ${reminder.title}. $ttsBody",
      isBackground: false,
    );

    final dueDate = DateFormat('dd/MM/yyyy').format(reminder.dueAt);
    final dueTime = DateFormat('hh:mm a').format(reminder.dueAt);
    final isDark = Theme.of(navContext).brightness == Brightness.dark;
    final onSurface = Theme.of(navContext).colorScheme.onSurface;

    showDialog(
      context: navContext,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 26),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor:
              isDark ? Theme.of(ctx).scaffoldBackgroundColor : Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.blueCyan.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.blueCyan,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Reminder Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _detailLineCard("Vehicle", reminder.vehicleName, onSurface),
                const SizedBox(height: 8),
                _detailLineCard("Title", reminder.title, onSurface),
                const SizedBox(height: 8),
                _detailLineCard("Type", reminder.type, onSurface),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _detailLineCard("Due Date", dueDate, onSurface),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _detailLineCard("Due Time", dueTime, onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _detailLineCard(
                  "Description",
                  reminder.description.isEmpty ? "-" : reminder.description,
                  onSurface,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: onSurface.withValues(alpha: .14),
                        ),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: onSurface.withValues(alpha: .85),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> processPendingNotificationTap() async {
    processPendingReminderTap();
    await processPendingAlertTap();
  }

  Future<void> processPendingAlertTap() async {
    if (!MySharedPreferences.getBool(isLoggedInKey)) {
      _pendingAlertItem = null;
      return;
    }
    final tappedAlert = _pendingAlertItem;
    if (tappedAlert == null) return;

    final navContext = _navigatorKey?.currentContext;
    if (navContext == null) return;

    _pendingAlertItem = null;
    var alert = tappedAlert;
    if (tappedAlert.id > 0) {
      final latestAlert = await _fetchAlertById(tappedAlert.id);
      if (latestAlert != null) {
        alert = latestAlert;
      }
    }

    if (!navContext.mounted) return;
    navContext.read<MotionBottomBarProvider>().setIndex(3);

    final hasValidLocation = alert.latitude != 0.0 || alert.longitude != 0.0;
    if (!hasValidLocation) {
      final pendingType = alert.type.trim();
      if (pendingType.isNotEmpty) {
        navContext.read<AlertsProvider>().setPendingAlertTypeLabel(pendingType);
      }
      return;
    }

    Navigator.of(navContext, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => AlertLocationScreen(alert: alert),
      ),
    );
  }

  Future<Item?> _fetchAlertById(int alertId) async {
    final token = MySharedPreferences.getString(authTokenKey).trim();
    if (token.isEmpty) return null;
    return _alertsRepository.getAlertById(
      alertId: alertId,
      userApiHashKey: token,
    );
  }

  Widget _detailLineCard(String label, String value, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: .12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: .66),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.trim().isEmpty ? "-" : value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: .92),
            ),
          ),
        ],
      ),
    );
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'vehicle_reminders_channel',
        'Vehicle Reminders',
        channelDescription: 'Reminder alerts for vehicle actions',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  NotificationDetails _remoteAlertDetails({String? iosSound}) {
    return NotificationDetails(
      android: const AndroidNotificationDetails(
        'vehicle_reminders_channel',
        'Vehicle Reminders',
        channelDescription: 'Reminder alerts for vehicle actions',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: iosSound,
      ),
    );
  }

  tz.TZDateTime _nextTrigger(DateTime dueAt) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime.from(dueAt, tz.local);
    while (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  int _repeatIntervalDays(String repeatType) {
    switch (repeatType) {
      case "weekly":
        return 7;
      case "monthly":
        return 30;
      case "yearly":
        return 365;
      default:
        return 0;
    }
  }

  int _occurrenceCount(String repeatType) {
    switch (repeatType) {
      case "weekly":
        return 52;
      case "monthly":
        return 24;
      case "yearly":
        return 5;
      default:
        return 1;
    }
  }

  int _occurrenceId(int reminderId, int index) {
    final mixed = reminderId ^ ((index + 1) * 2654435761);
    return mixed & 0x7fffffff;
  }

  Future<void> scheduleReminder(LocalReminder reminder) async {
    await init();
    if (!MySharedPreferences.getBool(isLoggedInKey)) {
      await cancelReminder(reminder.id);
      return;
    }
    final now = DateTime.now();
    if (reminder.repeatType == "none" && reminder.dueAt.isBefore(now)) {
      _foregroundTtsTimers.remove(reminder.id)?.cancel();
      return;
    }

    final title = '${reminder.vehicleName} - ${reminder.title}';
    final body = reminder.description.isEmpty
        ? '${reminder.type} reminder is due now'
        : reminder.description;
    _scheduleForegroundReminderTts(reminder, title, body);

    if (reminder.repeatType == "daily") {
      final scheduled = _nextTrigger(reminder.dueAt);
      await _plugin.zonedSchedule(
        reminder.id,
        title,
        body,
        scheduled,
        _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: "reminder:${reminder.id}",
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return;
    }

    if (reminder.repeatType == "weekly" ||
        reminder.repeatType == "monthly" ||
        reminder.repeatType == "yearly") {
      final intervalDays = _repeatIntervalDays(reminder.repeatType);
      final occurrences = _occurrenceCount(reminder.repeatType);
      var scheduled = _nextTrigger(reminder.dueAt);
      while (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduled = scheduled.add(Duration(days: intervalDays));
      }
      for (var i = 0; i < occurrences; i++) {
        final fireAt = scheduled.add(Duration(days: intervalDays * i));
        await _plugin.zonedSchedule(
          _occurrenceId(reminder.id, i),
          title,
          body,
          fireAt,
          _details(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: "reminder:${reminder.id}",
        );
      }
      return;
    }

    final scheduled = _nextTrigger(reminder.dueAt);
    await _plugin.zonedSchedule(
      reminder.id,
      title,
      body,
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "reminder:${reminder.id}",
    );
  }

  Future<void> cancelReminder(int reminderId) async {
    await _plugin.cancel(reminderId);
    for (var i = 0; i < 120; i++) {
      await _plugin.cancel(_occurrenceId(reminderId, i));
    }
    _foregroundTtsTimers.remove(reminderId)?.cancel();
  }

  Future<void> cancelAllReminderNotifications() async {
    await init();
    final pending = await _plugin.pendingNotificationRequests();
    for (final req in pending) {
      final payload = req.payload ?? '';
      if (payload.startsWith('reminder:')) {
        await _plugin.cancel(req.id);
      }
    }
    _pendingReminderId = null;
    _pendingAlertItem = null;
    for (final timer in _foregroundTtsTimers.values) {
      timer.cancel();
    }
    _foregroundTtsTimers.clear();
  }

  Future<void> showRemoteMessageNotification(RemoteMessage message) async {
    await init();

    final title = (message.notification?.title ?? '').trim();
    final body = (message.notification?.body ?? '').trim();
    final fallbackBody = (message.data['body'] ?? message.data['message'] ?? '')
        .toString()
        .trim();
    if (title.isEmpty && body.isEmpty && fallbackBody.isEmpty) {
      return;
    }
    final resolvedTitle = title.isNotEmpty ? title : 'Notification';
    final resolvedBody = body.isNotEmpty
        ? body
        : (fallbackBody.isNotEmpty ? fallbackBody : 'New alert received');
    final iosSound = _resolveIosSoundFile(message);

    final payloadMap = _extractRemoteAlertPayload(message);
    final payload =
        payloadMap == null ? null : 'alert:${jsonEncode(payloadMap)}';

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      resolvedTitle,
      resolvedBody,
      _remoteAlertDetails(iosSound: iosSound),
      payload: payload,
    );
  }

  Map<String, dynamic>? _extractRemoteAlertPayload(RemoteMessage message) {
    final data = message.data;
    double readDouble(List<String> keys, {double fallback = 0.0}) {
      for (final key in keys) {
        final raw = data[key];
        if (raw == null) continue;
        final parsed = double.tryParse(raw.toString().trim());
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    int readInt(List<String> keys, {int fallback = 0}) {
      for (final key in keys) {
        final raw = data[key];
        if (raw == null) continue;
        final parsed = int.tryParse(raw.toString().trim());
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    String readText(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final raw = data[key]?.toString().trim() ?? '';
        if (raw.isNotEmpty) return raw;
      }
      return fallback;
    }

    final messageText = (message.notification?.body ?? '').trim().isNotEmpty
        ? (message.notification?.body ?? '').trim()
        : readText(['message', 'body', 'alert_message', 'detail']);
    final typeText = readText(
      ['type', 'alert_type', 'notification_type', 'event_type'],
      fallback: (message.notification?.title ?? '').trim(),
    );
    final payload = <String, dynamic>{
      'id': readInt(['alert_id', 'id', 'notification_id']),
      'type': typeText,
      'time': readText(['time', 'alert_time', 'created_at']),
      'message': messageText,
      'address': readText(['address', 'location', 'place']),
      'course': readInt(['course', 'heading']),
      'latitude': readDouble(['latitude', 'lat', 'y']),
      'longitude': readDouble(['longitude', 'lng', 'lon', 'x']),
      'speed': readInt(['speed']),
      'detail': readText(['detail', 'description']),
      'geofence': data['geofence'],
      'device_name': readText(
        ['device_name', 'vehicle_name', 'device'],
        fallback: (message.notification?.title ?? '').trim(),
      ),
      'device_id': readInt(['device_id']),
    };

    final hasLocation =
        payload['latitude'] != 0.0 || payload['longitude'] != 0.0;
    final hasFallbackRouteData =
        (payload['type'] as String).trim().isNotEmpty ||
            (payload['device_name'] as String).trim().isNotEmpty ||
            (payload['message'] as String).trim().isNotEmpty;
    if (!hasLocation && !hasFallbackRouteData) return null;
    return payload;
  }

  String? _resolveIosSoundFile(RemoteMessage message) {
    final data = message.data;
    final explicitSound = (data['ios_sound'] ??
            data['sound'] ??
            data['notification_sound'] ??
            '')
        .toString()
        .trim();
    if (explicitSound.isNotEmpty) {
      final normalized = _normalizeIosSound(explicitSound);
      if (normalized != 'default') {
        return normalized;
      }
    }

    final probes = <String>[
      (data['alert_type'] ?? '').toString(),
      (data['type'] ?? '').toString(),
      (data['alarm_type'] ?? '').toString(),
      (data['event'] ?? '').toString(),
      (data['event_type'] ?? '').toString(),
      (data['notification_type'] ?? '').toString(),
      (data['category'] ?? '').toString(),
      (data['title'] ?? '').toString(),
      (data['body'] ?? '').toString(),
      message.notification?.title ?? '',
      message.notification?.body ?? '',
    ];
    final haystack = probes.join(' ').toLowerCase();

    if (haystack.contains('ignition') &&
        (haystack.contains(' on') ||
            haystack.contains(' start') ||
            haystack.contains('started'))) {
      return 'ignition_on.caf';
    }
    if (haystack.contains('ignition') &&
        (haystack.contains(' off') ||
            haystack.contains(' stop') ||
            haystack.contains('stopped'))) {
      return 'ignition_off.caf';
    }
    if (haystack.contains('overspeed') ||
        haystack.contains('over speed') ||
        haystack.contains('speeding')) {
      return 'overspeed.caf';
    }
    if ((haystack.contains('power') && haystack.contains('disconnect')) ||
        haystack.contains('power_disconnected') ||
        haystack.contains('powerdisconnected')) {
      return 'power_disconnected.caf';
    }
    return _fallbackIosAlertSound;
  }

  String _normalizeIosSound(String raw) {
    var sound = raw.trim();
    if (sound.isEmpty) return _fallbackIosAlertSound;
    if (!sound.contains('.')) {
      sound = '$sound.caf';
    }
    final normalized = sound.toLowerCase();
    const allowed = <String>{
      'ignition_on.caf',
      'ignition_off.caf',
      'overspeed.caf',
      'power_disconnected.caf',
      'default',
    };
    if (!allowed.contains(normalized)) {
      return _fallbackIosAlertSound;
    }
    return normalized;
  }

  void _scheduleForegroundReminderTts(
    LocalReminder reminder,
    String title,
    String body,
  ) {
    _foregroundTtsTimers.remove(reminder.id)?.cancel();
    final now = DateTime.now();
    final nextFire = _nextTrigger(reminder.dueAt).toLocal();
    final delay = nextFire.difference(now);
    if (delay.isNegative) return;

    _foregroundTtsTimers[reminder.id] = Timer(delay, () async {
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      final appActive = lifecycle == null || lifecycle == AppLifecycleState.resumed;
      if (appActive) {
        await AlertTtsService.instance.speakText(
          "Reminder. $title. $body",
          isBackground: false,
        );
      }

      if (reminder.repeatType == "none") {
        _foregroundTtsTimers.remove(reminder.id);
        return;
      }

      final nextDue = reminder.dueAt.add(
        Duration(days: reminder.repeatType == "daily" ? 1 : _repeatIntervalDays(reminder.repeatType)),
      );
      final nextReminder = LocalReminder(
        id: reminder.id,
        deviceId: reminder.deviceId,
        vehicleName: reminder.vehicleName,
        title: reminder.title,
        type: reminder.type,
        description: reminder.description,
        dueAt: nextDue,
        isRecurring: reminder.isRecurring,
        repeatType: reminder.repeatType,
        createdAt: reminder.createdAt,
      );
      _scheduleForegroundReminderTts(nextReminder, title, body);
    });
  }
}
