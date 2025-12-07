class Validators {
  static bool isEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  static bool isPhone(String phone) {
    final regex = RegExp(r'^[0-9]{10,11}$');
    return regex.hasMatch(phone);
  }

  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (isEmpty(value)) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (isEmpty(value)) {
      return 'Email is required';
    }
    if (!isEmail(value!)) {
      return 'Invalid email format';
    }
    return null;
  }
}
