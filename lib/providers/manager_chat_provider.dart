import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trackerapp/data/models/manager_chat_model.dart';
import 'package:trackerapp/data/repositories/fcm_token_repository.dart';
import 'package:trackerapp/data/repositories/manager_chat_repository.dart';
import 'package:trackerapp/main.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/local_notification_service.dart';
import 'package:trackerapp/utils/shared_preference.dart';
import 'package:trackerapp/view/auth_screens/login_screen.dart';

class ManagerChatProvider extends ChangeNotifier {
  final ManagerChatRepository _repository = ManagerChatRepository();
  final int? linkedDeviceId;
  final String? linkedDeviceName;

  bool _isInitializing = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  bool _isStartingChat = false;
  String? _errorMessage;
  ManagerChatThread? _thread;
  List<ManagerChatMessage> _messages = <ManagerChatMessage>[];
  Timer? _pollTimer;
  bool _isDisposed = false;

  bool get isInitializing => _isInitializing;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  bool get isStartingChat => _isStartingChat;
  String? get errorMessage => _errorMessage;
  ManagerChatThread? get thread => _thread;
  List<ManagerChatMessage> get messages => _messages;
  bool get hasThread => _thread != null;
  bool get hasMessages => _messages.isNotEmpty;
  bool get hasLinkedVehicle => linkedDeviceId != null;
  String get vehicleLabel {
    if (!hasLinkedVehicle) return '';
    final linkedName = linkedDeviceName?.trim() ?? '';
    if (linkedName.isNotEmpty) return linkedName;
    return _thread?.deviceName.trim() ?? '';
  }

  ManagerChatProvider({
    this.linkedDeviceId,
    this.linkedDeviceName,
  });

  void _notifySafely() {
    if (_isDisposed) return;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isInitializing) return;
    _isInitializing = true;
    _errorMessage = null;
    _notifySafely();

    try {
      await _fetchThread();
      if (_isDisposed) return;
      if (_thread != null) {
        await refreshMessages(silent: true);
      }
      if (_isDisposed) return;
      startPolling();
    } catch (e) {
      await _handleError(e, notify: false);
    } finally {
      if (!_isDisposed) {
        _isInitializing = false;
        _notifySafely();
      }
    }
  }

  Future<void> startChat() async {
    if (_isStartingChat || _thread != null) return;
    _isStartingChat = true;
    _errorMessage = null;
    _notifySafely();

    try {
      _thread = await _repository.createThread(
        payload: ManagerChatCreatePayload(
          subject: hasLinkedVehicle ? 'Complaint' : 'Support Chat',
          category: hasLinkedVehicle ? 'Complaint' : 'Support',
          deviceId: linkedDeviceId,
        ),
      );
      if (_isDisposed) return;
      _errorMessage = null;
      _notifySafely();
      startPolling();
    } catch (e) {
      await _handleError(e);
    } finally {
      if (!_isDisposed) {
        _isStartingChat = false;
        _notifySafely();
      }
    }
  }

  Future<void> refreshMessages({
    bool silent = false,
  }) async {
    if (_thread == null) return;
    if (_isLoadingMessages && !silent) return;

    if (!silent) {
      _isLoadingMessages = true;
      _notifySafely();
    }

    try {
      final threadId = _thread!.id;
      final items = await _repository.getMessages(threadId: threadId);
      if (_isDisposed) return;
      if (_thread == null || _thread!.id != threadId) return;
      _messages = items;
      _errorMessage = null;
      _notifySafely();
      await _repository.markRead(threadId: threadId);
      if (_isDisposed) return;
      if (_thread == null || _thread!.id != threadId) return;
      _thread = _thread!.copyWithUnreadCount();
    } catch (e) {
      await _handleThreadError(e);
    } finally {
      if (!_isDisposed && !silent) {
        _isLoadingMessages = false;
        _notifySafely();
      }
    }
  }

  Future<void> sendMessage(String rawMessage) async {
    final message = rawMessage.trim();
    if (message.isEmpty || _isSending) return;

    _isSending = true;
    _errorMessage = null;
    final optimistic = ManagerChatMessage.optimistic(message: message);
    _messages = <ManagerChatMessage>[..._messages, optimistic];
    _notifySafely();

    try {
      _thread ??= await _repository.createThread(
        payload: ManagerChatCreatePayload(
          subject: hasLinkedVehicle ? 'Complaint' : 'Support Chat',
          category: hasLinkedVehicle ? 'Complaint' : 'Support',
          deviceId: linkedDeviceId,
        ),
      );
      if (_isDisposed || _thread == null) return;
      await _repository.sendMessage(
        threadId: _thread!.id,
        payload: ManagerChatSendPayload(
          message: message,
          deviceId: linkedDeviceId,
          subject: hasLinkedVehicle ? 'Complaint' : null,
          category: hasLinkedVehicle ? 'Complaint' : null,
        ),
      );
      if (_isDisposed) return;
      await refreshMessages(silent: true);
      if (_isDisposed) return;
      startPolling();
    } catch (e) {
      if (_isDisposed) return;
      _messages = _messages.where((item) => item.id != optimistic.id).toList();
      await _handleThreadError(e);
    } finally {
      if (!_isDisposed) {
        _isSending = false;
        _notifySafely();
      }
    }
  }

  void startPolling() {
    _pollTimer?.cancel();
    if (_thread == null) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      refreshMessages(silent: true);
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _fetchThread() async {
    _thread = await _repository.getCurrentThread();
    if (_thread == null) {
      _messages = <ManagerChatMessage>[];
    }
  }

  Future<void> _handleThreadError(Object error) async {
    if (error is ManagerChatApiException && error.statusCode == 404) {
      try {
        await _fetchThread();
        if (_thread != null) {
          final items = await _repository.getMessages(threadId: _thread!.id);
          if (_isDisposed) return;
          _messages = items;
          await _repository.markRead(threadId: _thread!.id);
          if (_isDisposed) return;
          _notifySafely();
          return;
        }
      } catch (_) {}
    }
    await _handleError(error);
  }

  Future<void> _handleError(
    Object error, {
    bool notify = true,
  }) async {
    final message = _normalizeError(error);
    _errorMessage = message;
    if (notify) _notifySafely();

    if (_isDisposed) return;

    if (error is ManagerChatApiException && error.statusCode == 401) {
      AppSnackBar.error(message: 'Session expired. Please login again.');
      await _forceLogout();
      return;
    }

    if (notify) {
      AppSnackBar.error(message: message);
    }
  }

  String _normalizeError(Object error) {
    if (error is ManagerChatApiException) {
      return error.message;
    }
    final raw = error.toString().trim();
    if (raw.startsWith('Exception:')) {
      return raw.replaceFirst('Exception:', '').trim();
    }
    return raw.isEmpty ? 'Request failed' : raw;
  }

  Future<void> _forceLogout() async {
    try {
      await LocalNotificationService.instance.cancelAllReminderNotifications();
      await FcmTokenRepository().deleteLatestTokenForCurrentUser();
    } catch (_) {}

    await MySharedPreferences.logout();
    final navigator = rootNavigatorKey.currentState;
    final navContext = rootNavigatorKey.currentContext;
    if (navigator == null || navContext == null) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopPolling();
    super.dispose();
  }
}

extension on ManagerChatThread {
  ManagerChatThread copyWithUnreadCount({
    int? customerUnreadCount,
  }) {
    return ManagerChatThread(
      id: id,
      managerId: managerId,
      customerId: customerId,
      operatorId: operatorId,
      deviceId: deviceId,
      deviceName: deviceName,
      status: status,
      subject: subject,
      category: category,
      supportUnreadCount: supportUnreadCount,
      customerUnreadCount: customerUnreadCount ?? 0,
      lastMessageAt: lastMessageAt,
      lastMessageByType: lastMessageByType,
    );
  }
}
