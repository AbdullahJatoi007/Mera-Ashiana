class ValidationHelper {
  // NEW: Boolean check for logic outside of FormFields
  static bool isEmail(String value) {
    return validateEmail(value) == null;
  }

  // Email Regex - cleaner match
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ✨ Pakistani Phone Validation (+923xxxxxxxxx or 03xxxxxxxxx)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Allows either +92 followed by 10 digits OR a standard 11 digit number starting with 03
    final phoneRegExp = RegExp(r'^(?:\+92|0)3[0-9]{9}$');

    if (!phoneRegExp.hasMatch(value.trim())) {
      return 'Enter a valid number (e.g., 03001234567 or +923001234567)';
    }
    return null;
  }

  // Password Regex (Min 8 chars)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // Confirm Password
  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ✨ Whole number check — for counts like beds/baths.
  // Rejects empty values, non-numeric input, and negative numbers.
  static String? validateWholeNumber(
    String? value, {
    String fieldLabel = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldLabel is required';
    }
    final n = int.tryParse(value.trim());
    if (n == null) {
      return 'Enter a valid number';
    }
    if (n < 0) {
      return 'Must be 0 or more';
    }
    return null;
  }

  // ✨ Decimal-friendly number check — for price/area.
  // Rejects empty values, non-numeric input, and zero/negative numbers.
  static String? validateDecimalNumber(
    String? value, {
    String fieldLabel = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldLabel is required';
    }
    final n = double.tryParse(value.trim());
    if (n == null) {
      return 'Enter a valid number';
    }
    if (n <= 0) {
      return 'Must be greater than 0';
    }
    return null;
  }
}
