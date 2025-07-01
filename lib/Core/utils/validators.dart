class Validators {
  static bool isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isPasswordValid(String password) {
    return password.length >= 6;
  }

  static bool isPhoneValid(String phone) {
    // Sri Lankan phone number validation
    return RegExp(r'^(\+94|0)?[1-9][0-9]{8}$').hasMatch(phone);
  }

  static bool isNameValid(String name) {
    return name.trim().length >= 2;
  }

  static bool isOtpValid(String otp, int expectedLength) {
    return otp.length == expectedLength && RegExp(r'^[0-9]+$').hasMatch(otp);
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isEmailValid(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (!isPasswordValid(password)) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    if (!isPhoneValid(phone)) {
      return 'Please enter a valid Sri Lankan phone number';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (!isNameValid(name)) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
