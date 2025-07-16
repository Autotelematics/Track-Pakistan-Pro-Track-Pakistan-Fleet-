
class AlertsListModel {
  AlertsListModel({
    required this.status,
    required this.items,
  });

  final dynamic status;
  final Items items;

  factory AlertsListModel.fromJson(Map<dynamic, dynamic> json) {
    return AlertsListModel(
      status: json['status'] ?? 0, // Fallback to 0 if null
      items: Items.fromJson(json['items'] ?? {}), // Fallback to empty map
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['status'] = status;
    _data['items'] = items.toJson();
    return _data;
  }
}

class Items {
  Items({
    required this.alerts,
  });

  final List<Alerts> alerts;

  factory Items.fromJson(Map<dynamic, dynamic> json) {
    return Items(
      alerts: json['alerts'] != null
          ? List.from(json['alerts']).map((e) => Alerts.fromJson(e)).toList()
          : [], // Fallback to empty list
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['alerts'] = alerts.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Alerts {
  Alerts({
    required this.id,
    required this.userId,
    required this.active,
    required this.name,
    required this.type,
    this.schedules,
    required this.notifications,
    required this.createdAt,
    required this.updatedAt,
    required this.zone,
    required this.schedule,
    required this.command,
    required this.devices,
    required this.drivers,
    required this.geofences,
    required this.eventsCustom,
  });

  final dynamic id;
  final dynamic userId;
  final dynamic active;
  final dynamic name;
  final dynamic type;
  final dynamic schedules;
  final Notifications notifications;
  final dynamic createdAt;
  final dynamic updatedAt;
  final dynamic zone;
  final dynamic schedule;
  final Command command;
  final List<dynamic> devices;
  final List<dynamic> drivers;
  final List<dynamic> geofences;
  final List<dynamic> eventsCustom;

  factory Alerts.fromJson(Map<dynamic, dynamic> json) {
    return Alerts(
      id: json['id'] ?? 0, // Fallback to 0
      userId: json['user_id'] ?? 0, // Fallback to 0
      active: json['active'] ?? 0, // Fallback to 0
      name: json['name'] ?? '', // Fallback to empty string
      type: json['type'] ?? '', // Fallback to empty string
      schedules: json['schedules'], // Can be null
      notifications: Notifications.fromJson(json['notifications'] ?? {}), // Fallback to empty map
      createdAt: json['created_at'] ?? '', // Fallback to empty string
      updatedAt: json['updated_at'] ?? '', // Fallback to empty string
      zone: json['zone'] ?? 0, // Fallback to 0
      schedule: json['schedule'] ?? 0, // Fallback to 0
      command: Command.fromJson(json['command'] ?? {}), // Fallback to empty map
      devices: json['devices'] != null ? List.castFrom<dynamic, dynamic>(json['devices']) : [], // Fallback to empty list
      drivers: json['drivers'] != null ? List.castFrom<dynamic, dynamic>(json['drivers']) : [], // Fallback to empty list
      geofences: json['geofences'] != null ? List.castFrom<dynamic, dynamic>(json['geofences']) : [], // Fallback to empty list
      eventsCustom: json['events_custom'] != null ? List.castFrom<dynamic, dynamic>(json['events_custom']) : [], // Fallback to empty list
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['active'] = active;
    _data['name'] = name;
    _data['type'] = type;
    _data['schedules'] = schedules;
    _data['notifications'] = notifications.toJson();
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['zone'] = zone;
    _data['schedule'] = schedule;
    _data['command'] = command.toJson();
    _data['devices'] = devices;
    _data['drivers'] = drivers;
    _data['geofences'] = geofences;
    _data['events_custom'] = eventsCustom;
    return _data;
  }
}

class Notifications {
  Notifications({
    required this.sound,
    required this.autoHide,
    required this.push,
    required this.email,
    required this.webhook,
    required this.sharingEmail,
  });

  final Sound sound;
  final AutoHide autoHide;
  final Push push;
  final Email email;
  final Webhook webhook;
  final SharingEmail sharingEmail;

  factory Notifications.fromJson(Map<dynamic, dynamic> json) {
    return Notifications(
      sound: Sound.fromJson(json['sound'] ?? {'active': '0'}), // Fallback
      autoHide: AutoHide.fromJson(json['auto_hide'] ?? {'active': '0'}), // Fallback
      push: Push.fromJson(json['push'] ?? {'active': '0'}), // Fallback
      email: Email.fromJson(json['email'] ?? {'active': '0', 'input': ''}), // Fallback
      webhook: Webhook.fromJson(json['webhook'] ?? {'active': '0', 'input': ''}), // Fallback
      sharingEmail: SharingEmail.fromJson(json['sharing_email'] ?? {'active': '0', 'input': ''}), // Fallback
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['sound'] = sound.toJson();
    _data['auto_hide'] = autoHide.toJson();
    _data['push'] = push.toJson();
    _data['email'] = email.toJson();
    _data['webhook'] = webhook.toJson();
    _data['sharing_email'] = sharingEmail.toJson();
    return _data;
  }
}

class Sound {
  Sound({
    required this.active,
  });

  final dynamic active;

  factory Sound.fromJson(Map<dynamic, dynamic> json) {
    return Sound(
      active: json['active'] ?? '0', // Fallback to '0'
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    return _data;
  }
}

class AutoHide {
  AutoHide({
    required this.active,
  });

  final dynamic active;

  factory AutoHide.fromJson(Map<dynamic, dynamic> json) {
    return AutoHide(
      active: json['active'] ?? '0', // Fallback to '0'
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    return _data;
  }
}

class Push {
  Push({
    required this.active,
  });

  final dynamic active;

  factory Push.fromJson(Map<dynamic, dynamic> json) {
    return Push(
      active: json['active'] ?? '0', // Fallback to '0'
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    return _data;
  }
}

class Email {
  Email({
    required this.active,
    required this.input,
  });

  final dynamic active;
  final dynamic input;

  factory Email.fromJson(Map<dynamic, dynamic> json) {
    return Email(
      active: json['active'] ?? '0', // Fallback to '0'
      input: json['input'] ?? '', // Fallback to empty string
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    _data['input'] = input;
    return _data;
  }
}

class Webhook {
  Webhook({
    required this.active,
    required this.input,
  });

  final dynamic active;
  final dynamic input;

  factory Webhook.fromJson(Map<dynamic, dynamic> json) {
    return Webhook(
      active: json['active'] ?? '0', // Fallback to '0'
      input: json['input'] ?? '', // Fallback to empty string
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    _data['input'] = input;
    return _data;
  }
}

class SharingEmail {
  SharingEmail({
    required this.active,
    required this.input,
  });

  final dynamic active;
  final dynamic input;

  factory SharingEmail.fromJson(Map<dynamic, dynamic> json) {
    return SharingEmail(
      active: json['active'] ?? '0', // Fallback to '0'
      input: json['input'] ?? '', // Fallback to empty string
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    _data['input'] = input;
    return _data;
  }
}

class Command {
  Command({
    required this.active,
    required this.type,
  });

  final dynamic active;
  final dynamic type;

  factory Command.fromJson(Map<dynamic, dynamic> json) {
    return Command(
      active: json['active'] ?? '0', // Fallback to '0'
      type: json['type'] ?? 'custom', // Fallback to 'custom'
    );
  }

  Map<dynamic, dynamic> toJson() {
    final _data = <dynamic, dynamic>{};
    _data['active'] = active;
    _data['type'] = type;
    return _data;
  }
}