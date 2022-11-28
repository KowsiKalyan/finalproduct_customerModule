class StringValidation {
  static String? validatePincode(String value, String? msg1) {
    if (value.isEmpty) {
      return msg1;
    } else {
      return null;
    }
  }

  static String? validateUserName(String value, String? msg1, String? msg2) {
    if (value.isEmpty) {
      return msg1;
    }
    if (value.length <= 1) {
      return msg2;
    }
    return null;
  }

  static String? validateMob(String value, String? msg1, String? msg2) {
    if (value.isEmpty) {
      return msg1;
    }
    if (value.length < 6) {
      return msg2;
    }
    return null;
  }

  static String? validateCountryCode(String value, String msg1, String msg2) {
    if (value.isEmpty) {
      return msg1;
    }
    if (value.isEmpty) {
      return msg2;
    }
    return null;
  }

  static String? validatePass(String value, String? msg1, String? msg2) {
    if (value.isEmpty) {
      return msg1;
    } else if (value.length <= 5) {
      return msg2;
    } else {
      return null;
    }
  }

  static String? validateAltMob(String value, String? msg) {
    if (value.isNotEmpty && value.length < 9) {
      return msg;
    }
    return null;
  }

  static String? validateField(String value, String? msg) {
    if (value.isEmpty) {
      return msg;
    } else {
      return null;
    }
  }

  static String? validateEmail(String value, String? msg1, String? msg2) {
    if (value.isEmpty) {
      return msg1;
    } else if (!RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
            r'*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+'
            r'[a-z0-9](?:[a-z0-9-]*[a-z0-9])?')
        .hasMatch(value)) {
      return msg2;
    } else {
      return null;
    }
  }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
