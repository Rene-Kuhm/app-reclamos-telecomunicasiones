import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name@example.co.uk'), null);
        expect(Validators.validateEmail('user+tag@example.com'), null);
      });

      test('should return error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
      });

      test('should return error for invalid email format', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('invalid@'), isNotNull);
        expect(Validators.validateEmail('@example.com'), isNotNull);
        expect(Validators.validateEmail('user @example.com'), isNotNull);
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        expect(Validators.validatePassword('Password123'), null);
        expect(Validators.validatePassword('MyP@ssw0rd'), null);
        expect(Validators.validatePassword('SecurePass1'), null);
      });

      test('should return error for empty password', () {
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword(null), isNotNull);
      });

      test('should return error for short password', () {
        expect(Validators.validatePassword('Pass1'), isNotNull);
        expect(Validators.validatePassword('1234567'), isNotNull);
      });

      test('should return error for password without uppercase', () {
        expect(Validators.validatePassword('password123'), isNotNull);
      });

      test('should return error for password without numbers', () {
        expect(Validators.validatePassword('Password'), isNotNull);
      });
    });

    group('validateRequired', () {
      test('should return null for non-empty value', () {
        expect(Validators.validateRequired('test'), null);
        expect(Validators.validateRequired('  value  '), null);
      });

      test('should return error for empty value', () {
        expect(Validators.validateRequired(''), isNotNull);
        expect(Validators.validateRequired('   '), isNotNull);
        expect(Validators.validateRequired(null), isNotNull);
      });
    });

    group('validatePhone', () {
      test('should return null for valid phone', () {
        expect(Validators.validatePhone('1234567890'), null);
        expect(Validators.validatePhone('987654321'), null);
      });

      test('should return error for empty phone', () {
        expect(Validators.validatePhone(''), isNotNull);
        expect(Validators.validatePhone(null), isNotNull);
      });

      test('should return error for short phone', () {
        expect(Validators.validatePhone('12345'), isNotNull);
      });
    });

    group('validateName', () {
      test('should return null for valid name', () {
        expect(Validators.validateName('John'), null);
        expect(Validators.validateName('María José'), null);
        expect(Validators.validateName('O\'Brien'), null);
      });

      test('should return error for empty name', () {
        expect(Validators.validateName(''), isNotNull);
        expect(Validators.validateName(null), isNotNull);
      });

      test('should return error for short name', () {
        expect(Validators.validateName('A'), isNotNull);
      });
    });
  });
}
