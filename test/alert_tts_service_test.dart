import 'package:flutter_test/flutter_test.dart';
import 'package:trackerapp/utils/alert_tts_service.dart';

void main() {
  group('Vehicle Registration Number TTS Formatting Tests', () {
    test('Formats BKX-853 correctly', () {
      final input = 'Vehicle BKX-853 has generated an alert';
      final result = formatVehicleRegistrationNumbers(input);
      expect(result, 'Vehicle B K X 8 5 3 has generated an alert');
    });

    test('Formats ABC-123 correctly', () {
      final input = 'ABC-123';
      final result = formatVehicleRegistrationNumbers(input);
      expect(result, 'A B C 1 2 3');
    });

    test('Formats LEA-4071 correctly', () {
      final input = 'LEA-4071';
      final result = formatVehicleRegistrationNumbers(input);
      expect(result, 'L E A 4 0 7 1');
    });

    test('Formats XYZ-009 with leading zeros correctly', () {
      final input = 'XYZ-009';
      final result = formatVehicleRegistrationNumbers(input);
      expect(result, 'X Y Z 0 0 9');
    });
  });
}
