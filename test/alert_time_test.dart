import 'package:flutter_test/flutter_test.dart';
import 'package:trackerapp/data/models/get_alerts_list_model.dart';

void main() {
  test('Alert time parsing converts UTC time to local time correctly', () {
    final jsonMap = {
      "id": 1,
      "type": "overSpeed",
      "time": "2026-10-09 09:50:29",
      "message": "Speeding test",
      "address": "",
      "course": 0,
      "latitude": 24.86,
      "longitude": 67.01,
      "speed": 90,
      "detail": "",
      "device_name": "Car 1",
      "device_id": 123
    };

    final item = Item.fromJson(jsonMap);
    expect(item.time, isNotNull);
    expect(item.time!.toUtc().hour, 9);
    expect(item.time!.toUtc().minute, 50);
  });
}
