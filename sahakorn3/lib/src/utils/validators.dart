class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter email';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Enter password';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String? passwordToMatch,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != passwordToMatch) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter ${fieldName.toLowerCase()}';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter phone number';
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
