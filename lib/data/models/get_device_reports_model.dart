class ReportTypeModel {
  final int? status;
  final List<ReportTypeItem>? items;

  const ReportTypeModel({this.status, this.items});

  factory ReportTypeModel.fromJson(Map<String, dynamic> json) {
    return ReportTypeModel(
      status: json['status'] as int?,
      items: json['items'] != null
          ? (json['items'] as List)
          .map((e) => ReportTypeItem.fromJson(e))
          .toList()
          : null,
    );
  }
}

class ReportTypeItem {
  final int? type;
  final String? name;
  final List<dynamic>? formats;
  final List<dynamic>? fields;

  const ReportTypeItem({this.type, this.name, this.formats, this.fields});

  factory ReportTypeItem.fromJson(Map<String, dynamic> json) {
    return ReportTypeItem(
      type: json['type'] as int?,
      name: json['name'] as String?,
      formats: json['formats'] as List<dynamic>?,
      fields: json['fields'] as List<dynamic>?,
    );
  }
}

class Items {
  final int? type;
  final String? name;
  final List<dynamic>? formats;
  final List<dynamic>? fields;
  const Items({this.type, this.name, this.formats, this.fields});
  Items copyWith(
      {int? type,
        String? name,
        List<dynamic>? formats,
        List<dynamic>? fields}) {
    return Items(
        type: type ?? this.type,
        name: name ?? this.name,
        formats: formats ?? this.formats,
        fields: fields ?? this.fields);
  }

  Map<String, Object?> toJson() {
    return {'type': type, 'name': name, 'formats': formats, 'fields': fields};
  }

  static Items fromJson(Map<String, Object?> json) {
    return Items(
        type: json['type'] == null ? null : json['type'] as int,
        name: json['name'] == null ? null : json['name'] as String,
        formats:
        json['formats'] == null ? null : json['formats'] as List<dynamic>,
        fields:
        json['fields'] == null ? null : json['fields'] as List<dynamic>);
  }

  @override
  String toString() {
    return '''Items(
                type:$type,
name:$name,
formats:$formats,
fields:$fields
    ) ''';
  }

  @override
  bool operator ==(Object other) {
    return other is Items &&
        other.runtimeType == runtimeType &&
        other.type == type &&
        other.name == name &&
        other.formats == formats &&
        other.fields == fields;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, type, name, formats, fields);
  }
}
