class GetReportModel {
  int? status;
  int? statusCode;
  String? message;
  dynamic errors;
  String? url;
  GetReportModel({
    this.status,
    this.statusCode,
    this.message,
    this.errors,
    this.url,
  });

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  GetReportModel.fromJson(Map<String, dynamic> json) {
    status = _asInt(json["status"]);
    statusCode = _asInt(json["statusCode"]);
    message = json["message"]?.toString();
    errors = json["errors"];
    url = json["url"]?.toString();
  }

  bool get isSuccess => status == 1 && (url ?? '').trim().isNotEmpty;

  String _extractErrorText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) {
      if (value.isEmpty) return '';
      return _extractErrorText(value.first);
    }
    if (value is Map) {
      if (value.isEmpty) return '';
      return _extractErrorText(value.values.first);
    }
    return value.toString();
  }

  String get bestErrorMessage {
    final fromErrors = _extractErrorText(errors).trim();
    if (fromErrors.isNotEmpty) return fromErrors;
    final fromMessage = (message ?? '').trim();
    if (fromMessage.isNotEmpty) return fromMessage;
    if (statusCode != null) return 'Server returned $statusCode';
    return 'Failed to generate report';
  }
}
