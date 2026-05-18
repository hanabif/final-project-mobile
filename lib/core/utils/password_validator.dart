/// Password strength levels
enum PasswordStrength { weak, fair, good, strong }

/// Utility class for password validation and strength checking
class PasswordValidator {
  /// Minimum password length required
  static const int minLength = 8;

  /// Check if a password is strong
  /// Requirements:
  /// - At least 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character (!@#$%^&*-_=+)
  static bool isStrongPassword(String password) {
    if (password.length < minLength) return false;
    if (!_hasUppercase(password)) return false;
    if (!_hasLowercase(password)) return false;
    if (!_hasNumber(password)) return false;
    if (!_hasSpecialCharacter(password)) return false;
    return true;
  }

  /// Validate password and return error message if invalid
  /// Returns null if password is valid
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (!_hasUppercase(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!_hasLowercase(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!_hasNumber(password)) {
      return 'Password must contain at least one number';
    }
    if (!_hasSpecialCharacter(password)) {
      return 'Password must contain at least one special character (!@#\$%^&*-_=+)';
    }
    return null;
  }

  /// Get password strength level
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;
    
    int strengthScore = 0;

    if (password.length >= minLength) strengthScore++;
    if (password.length >= 12) strengthScore++;
    if (_hasUppercase(password)) strengthScore++;
    if (_hasLowercase(password)) strengthScore++;
    if (_hasNumber(password)) strengthScore++;
    if (_hasSpecialCharacter(password)) strengthScore++;

    if (strengthScore <= 2) return PasswordStrength.weak;
    if (strengthScore <= 3) return PasswordStrength.fair;
    if (strengthScore <= 4) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  static bool _hasUppercase(String s) => s.contains(RegExp(r'[A-Z]'));
  static bool _hasLowercase(String s) => s.contains(RegExp(r'[a-z]'));
  static bool _hasNumber(String s) => s.contains(RegExp(r'[0-9]'));
  static bool _hasSpecialCharacter(String s) =>
      s.contains(RegExp(r'[!@#$%^&*\-_=+]'));
}
