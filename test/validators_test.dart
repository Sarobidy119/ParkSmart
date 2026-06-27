import 'package:flutter_test/flutter_test.dart';
import 'package:parksmart/core/utils/validators.dart';

void main() {
  group('isValidEmail', () {
    test('accepts common email formats', () {
      expect(isValidEmail('user@example.com'), isTrue);
      expect(isValidEmail(' USER+test@sub.example.mg '), isTrue);
      expect(isValidEmail('dev@test.local'), isTrue);
    });

    test('rejects clearly unusable emails', () {
      expect(isValidEmail(''), isFalse);
      expect(isValidEmail('user'), isFalse);
      expect(isValidEmail('user@'), isFalse);
      expect(isValidEmail('@example.com'), isFalse);
      expect(isValidEmail('user@@example.com'), isFalse);
      expect(isValidEmail('user example@test.com'), isFalse);
      expect(isValidEmail('user@example..com'), isFalse);
    });
  });
}
