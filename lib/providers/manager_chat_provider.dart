import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trackerapp/data/models/get_device_list_model.dart';
import 'package:trackerapp/data/models/manager_chat_model.dart';
import 'package:trackerapp/data/repositories/manager_chat_repository.dart';
import 'package:trackerapp/data/repositories/vehicle_repository.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/utils/session_guard.dart';

class ManagerChatProvider extends ChangeNotifier {
  final ManagerChatRepository _repository = ManagerChatRepository();
  final VehicleRepository _vehicleRepository = VehicleRepository();
  final int? linkedDeviceId;
  final String? linkedDeviceName;

  bool _isInitializing = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  bool _isSendingLocation = false;
  bool _isSendingPreAlert = false;
  bool _isStartingChat = false;
  String? _errorMessage;
  ManagerChatThread? _thread;
  List<ManagerChatMessage> _messages = <ManagerChatMessage>[];
  Timer? _pollTimer;
  bool _isDisposed = false;

  bool get isInitializing => _isInitializing;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  bool get isSendingLocation => _isSendingLocation;
  bool get isSendingPreAlert => _isSendingPreAlert;
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
      await _handleThreadError(
        e,
        notify: !silent,
      );
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

  Future<List<Item>> fetchDeviceOptions() async {
    final data = await _vehicleRepository.fetchVehicleData();
    final items = data?.items ?? <Item>[];
    return items.where((item) => item.id != null).toList();
  }

  Future<bool> sendLocationAttachment({
    required int deviceId,
    required String deviceName,
    required double lat,
    required double lng,
  }) async {
    if (_isSendingLocation) return false;
    _isSendingLocation = true;
    _notifySafely();

    final payload = ManagerChatSendPayload(
      message: 'Shared location for ${deviceName.trim().isEmpty ? "selected vehicle" : deviceName.trim()}',
      deviceId: deviceId,
      subject: 'Location Share',
      category: hasLinkedVehicle ? 'Complaint' : 'Support',
      attachment: <String, dynamic>{
        'type': 'location',
        'location': <String, dynamic>{
          'lat': lat,
          'lng': lng,
          'device_id': deviceId,
        },
      },
    );

    try {
      _thread ??= await _repository.createThread(
        payload: ManagerChatCreatePayload(
          subject: hasLinkedVehicle ? 'Complaint' : 'Support Chat',
          category: hasLinkedVehicle ? 'Complaint' : 'Support',
          deviceId: hasLinkedVehicle ? linkedDeviceId : deviceId,
        ),
      );
      if (_isDisposed || _thread == null) return false;

      await _repository.sendMessage(
        threadId: _thread!.id,
        payload: payload,
      );
      if (_isDisposed) return false;
      await refreshMessages(silent: true);
      if (_isDisposed) return false;
      startPolling();
      AppSnackBar.success(message: 'Location sent successfully');
      return true;
    } catch (e) {
      await _handleThreadError(e);
      return false;
    } finally {
      if (!_isDisposed) {
        _isSendingLocation = false;
        _notifySafely();
      }
    }
  }

  Future<bool> sendPreAlertAttachment({
    required int deviceId,
    required DateTime fromDate,
    required DateTime toDate,
    required String userMessage,
  }) async {
    if (_isSendingPreAlert) return false;
    _isSendingPreAlert = true;
    _notifySafely();

    final dateFormat = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final toDateFormat = DateTime(toDate.year, toDate.month, toDate.day);
    final from = '${dateFormat.year.toString().padLeft(4, '0')}-${dateFormat.month.toString().padLeft(2, '0')}-${dateFormat.day.toString().padLeft(2, '0')}';
    final to = '${toDateFormat.year.toString().padLeft(4, '0')}-${toDateFormat.month.toString().padLeft(2, '0')}-${toDateFormat.day.toString().padLeft(2, '0')}';

    final payload = ManagerChatSendPayload(
      message: 'Pre alert for vehicle',
      deviceId: deviceId,
      subject: 'Pre Alert',
      attachment: <String, dynamic>{
        'type': 'pre_alert',
        'pre_alert': <String, dynamic>{
          'device_id': deviceId,
          'from_date': from,
          'to_date': to,
          'message': userMessage.trim(),
        },
      },
    );

    try {
      _thread ??= await _repository.createThread(
        payload: ManagerChatCreatePayload(
          subject: hasLinkedVehicle ? 'Complaint' : 'Support Chat',
          category: hasLinkedVehicle ? 'Complaint' : 'Support',
          deviceId: hasLinkedVehicle ? linkedDeviceId : deviceId,
        ),
      );
      if (_isDisposed || _thread == null) return false;

      await _repository.sendMessage(
        threadId: _thread!.id,
        payload: payload,
      );
      if (_isDisposed) return false;
      await refreshMessages(silent: true);
      if (_isDisposed) return false;
      startPolling();
      AppSnackBar.success(message: 'Pre alert sent successfully');
      return true;
    } catch (e) {
      await _handleThreadError(e);
      return false;
    } finally {
      if (!_isDisposed) {
        _isSendingPreAlert = false;
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

  Future<void> _handleThreadError(
    Object error, {
    bool notify = true,
  }) async {
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
    await _handleError(
      error,
      notify: notify,
    );
  }

  Future<void> _handleError(
    Object error, {
    bool notify = true,
  }) async {
    final message = _normalizeError(error);
    if (notify) {
      _errorMessage = message;
      _notifySafely();
    }

    if (_isDisposed) return;

    if (error is ManagerChatApiException && error.statusCode == 401) {
      await SessionGuard.forceLogout(
        message: 'Session expired. Please login again.',
      );
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
    if (error is SocketException) {
      return 'Network unavailable. Please check your internet connection.';
    }
    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    if (error is http.ClientException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('failed host lookup') || msg.contains('socketexception')) {
        return 'Network unavailable. Please check your internet connection.';
      }
      return 'Unable to connect to server. Please try again.';
    }
    final raw = error.toString().trim();
    final lowerRaw = raw.toLowerCase();
    if (lowerRaw.contains('failed host lookup') ||
        lowerRaw.contains('socketexception')) {
      return 'Network unavailable. Please check your internet connection.';
    }
    if (raw.startsWith('Exception:')) {
      return raw.replaceFirst('Exception:', '').trim();
    }
    return raw.isEmpty ? 'Request failed' : raw;
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
