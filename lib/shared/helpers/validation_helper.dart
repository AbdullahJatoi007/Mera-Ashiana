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

  // ✨ Whole number check — for counts like beds/baths, or optional fields
  // like floor/total floors. Set required:false for optional fields —
  // an empty value then passes silently instead of showing "required".
  static String? validateWholeNumber(
    String? value, {
    String fieldLabel = 'This field',
    int max = 50,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldLabel is required' : null;
    }
    final n = int.tryParse(value.trim());
    if (n == null) {
      return 'Enter a valid number';
    }
    if (n < 0) {
      return 'Must be 0 or more';
    }
    if (n > max) {
      return '$fieldLabel can\'t exceed $max';
    }
    return null;
  }

  // ✨ Decimal-friendly number check — for price/area, or optional
  // numeric fields. Set required:false for optional fields.
  static String? validateDecimalNumber(
    String? value, {
    String fieldLabel = 'This field',
    double max = 999999999,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldLabel is required' : null;
    }
    final n = double.tryParse(value.trim());
    if (n == null) {
      return 'Enter a valid number';
    }
    if (n <= 0) {
      return 'Must be greater than 0';
    }
    if (n > max) {
      return '$fieldLabel is unrealistically large';
    }
    return null;
  }

  // ✨ Year Built — optional. Rejects non-numbers and anything outside a
  // sane construction-year range.
  static String? validateYear(String? value, {String fieldLabel = 'Year'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional field
    }
    final n = int.tryParse(value.trim());
    final currentYear = DateTime.now().year;
    if (n == null) {
      return 'Enter a valid year';
    }
    if (n < 1900 || n > currentYear + 1) {
      return 'Enter a year between 1900 and ${currentYear + 1}';
    }
    return null;
  }

  // ✨ Pakistani postal/zip code — optional. 5 digits when provided.
  static String? validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional field
    }
    if (!RegExp(r'^\d{5}$').hasMatch(value.trim())) {
      return 'Enter a valid 5-digit postal code';
    }
    return null;
  }
}
