import 'package:flutter_test/flutter_test.dart';
import 'package:complaint_resolution_app/core/utils/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    group('isStrongPassword', () {
      test('should return true for strong password', () {
        expect(PasswordValidator.isStrongPassword('Strong1!'), isTrue);
      });

      test('should return false for short password', () {
        expect(PasswordValidator.isStrongPassword('Str1!'), isFalse);
      });

      test('should return false if no uppercase', () {
        expect(PasswordValidator.isStrongPassword('strong1!'), isFalse);
      });

      test('should return false if no lowercase', () {
        expect(PasswordValidator.isStrongPassword('STRONG1!'), isFalse);
      });

      test('should return false if no number', () {
        expect(PasswordValidator.isStrongPassword('Strong!!'), isFalse);
      });

      test('should return false if no special char', () {
        expect(PasswordValidator.isStrongPassword('Strong12'), isFalse);
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        expect(PasswordValidator.validatePassword('Strong1!'), isNull);
      });

      test('should return error for empty password', () {
        expect(PasswordValidator.validatePassword(''), contains('required'));
      });

      test('should return error for short password', () {
        expect(PasswordValidator.validatePassword('Short1!'), contains('at least 8 characters'));
      });

      test('should return error if no uppercase', () {
        expect(PasswordValidator.validatePassword('nouppercase1!'), contains('uppercase'));
      });
    });

    group('getPasswordStrength', () {
      test('should return weak for empty', () {
        expect(PasswordValidator.getPasswordStrength(''), PasswordStrength.weak);
      });

      test('should return strong for complex password', () {
        expect(PasswordValidator.getPasswordStrength('VeryStrongPassword123!@#'), PasswordStrength.strong);
      });

      test('should return fair for simple but long password', () {
        // Length(2) + Lower(1) = 3 -> fair
        expect(PasswordValidator.getPasswordStrength('justlowercase'), PasswordStrength.fair);
      });
    });
  });
}
