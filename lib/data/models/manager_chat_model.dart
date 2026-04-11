class ManagerChatThread {
  final int id;
  final int managerId;
  final int customerId;
  final int? operatorId;
  final int? deviceId;
  final String deviceName;
  final String status;
  final String subject;
  final String category;
  final int supportUnreadCount;
  final int customerUnreadCount;
  final DateTime? lastMessageAt;
  final String lastMessageByType;

  const ManagerChatThread({
    required this.id,
    required this.managerId,
    required this.customerId,
    required this.operatorId,
    required this.deviceId,
    required this.deviceName,
    required this.status,
    required this.subject,
    required this.category,
    required this.supportUnreadCount,
    required this.customerUnreadCount,
    required this.lastMessageAt,
    required this.lastMessageByType,
  });

  factory ManagerChatThread.fromJson(Map<String, dynamic> json) {
    return ManagerChatThread(
      id: _toInt(json['id']),
      managerId: _toInt(json['manager_id']),
      customerId: _toInt(json['customer_id']),
      operatorId: _toNullableInt(json['operator_id']),
      deviceId: _toNullableInt(json['device_id']),
      deviceName: _toText(json['device_name']),
      status: _toText(json['status']),
      subject: _toText(json['subject']),
      category: _toText(json['category']),
      supportUnreadCount: _toInt(json['support_unread_count']),
      customerUnreadCount: _toInt(json['customer_unread_count']),
      lastMessageAt: _tryParseDateTime(json['last_message_at']),
      lastMessageByType: _toText(json['last_message_by_type']),
    );
  }
}

class ManagerChatMessage {
  final int id;
  final int senderId;
  final String senderType;
  final String message;
  final DateTime? createdAt;
  final bool isPending;

  const ManagerChatMessage({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.message,
    required this.createdAt,
    this.isPending = false,
  });

  bool get isCustomer => senderType == 'customer';
  bool get isSystem => senderType == 'system';
  bool get isSupport => senderType == 'manager' || senderType == 'operator';

  ManagerChatMessage copyWith({
    int? id,
    int? senderId,
    String? senderType,
    String? message,
    DateTime? createdAt,
    bool? isPending,
  }) {
    return ManagerChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isPending: isPending ?? this.isPending,
    );
  }

  factory ManagerChatMessage.fromJson(Map<String, dynamic> json) {
    return ManagerChatMessage(
      id: _toInt(json['id']),
      senderId: _toInt(json['sender_id']),
      senderType: _toText(json['sender_type']),
      message: _toText(json['message']),
      createdAt: _tryParseDateTime(json['created_at']),
    );
  }

  factory ManagerChatMessage.optimistic({
    required String message,
  }) {
    return ManagerChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      senderId: 0,
      senderType: 'customer',
      message: message,
      createdAt: DateTime.now(),
      isPending: true,
    );
  }
}

class ManagerChatCreatePayload {
  final String subject;
  final String category;
  final int? deviceId;

  const ManagerChatCreatePayload({
    this.subject = 'Support Chat',
    this.category = 'Support',
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (subject.trim().isNotEmpty) 'subject': subject.trim(),
      if (category.trim().isNotEmpty) 'category': category.trim(),
      if (deviceId != null) 'device_id': deviceId,
    };
  }
}

class ManagerChatSendPayload {
  final String message;
  final int? deviceId;
  final String? subject;
  final String? category;
  final Map<String, dynamic>? attachment;

  const ManagerChatSendPayload({
    required this.message,
    this.deviceId,
    this.subject,
    this.category,
    this.attachment,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message': message.trim(),
      if (deviceId != null) 'device_id': deviceId,
      if (subject != null && subject!.trim().isNotEmpty) 'subject': subject!.trim(),
      if (category != null && category!.trim().isNotEmpty)
        'category': category!.trim(),
      if (attachment != null) 'attachment': attachment,
    };
  }
}

class ManagerChatThreadResponse {
  final ManagerChatThread? thread;

  const ManagerChatThreadResponse({
    required this.thread,
  });

  factory ManagerChatThreadResponse.fromJson(Map<String, dynamic> json) {
    final rawThread = json['thread'];
    if (rawThread is Map) {
      return ManagerChatThreadResponse(
        thread: ManagerChatThread.fromJson(_normalizeMap(rawThread)),
      );
    }
    return const ManagerChatThreadResponse(thread: null);
  }
}

class ManagerChatMessagesResponse {
  final List<ManagerChatMessage> items;

  const ManagerChatMessagesResponse({
    required this.items,
  });

  factory ManagerChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      return const ManagerChatMessagesResponse(items: <ManagerChatMessage>[]);
    }

    return ManagerChatMessagesResponse(
      items: rawItems
          .whereType<Map>()
          .map((item) => ManagerChatMessage.fromJson(_normalizeMap(item)))
          .toList(),
    );
  }
}

Map<String, dynamic> _normalizeMap(Map source) {
  final normalized = <String, dynamic>{};
  source.forEach((key, value) {
    if (key == null) return;
    normalized[key.toString()] = value;
  });
  return normalized;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  final parsed = _toInt(value);
  return parsed == 0 && value.toString().trim().isEmpty ? null : parsed;
}

String _toText(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

DateTime? _tryParseDateTime(dynamic value) {
  final text = _toText(value);
  if (text.isEmpty) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}
