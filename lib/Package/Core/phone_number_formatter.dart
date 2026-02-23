class PhoneNumberFormatter {
  /// Converts various Libyan phone number formats to international format: 00218919005626
  static String formatLibyanPhone(String phone) {
    if (phone.isEmpty) return phone;

    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Handle different input formats
    String normalized = '';

    if (digitsOnly.startsWith('00218')) {
      // 00218919005626 -> already in correct format
      normalized = digitsOnly;
    } else if (digitsOnly.startsWith('218')) {
      // 218919005626 -> 00218919005626
      normalized = '00$digitsOnly';
    } else if (digitsOnly.startsWith('0') && digitsOnly.length == 10) {
      // 0919005626 -> 00218919005626
      normalized = '00218${digitsOnly.substring(1)}';
    } else if (digitsOnly.length == 9) {
      // 919005626 -> 00218919005626
      normalized = '00218$digitsOnly';
    } else {
      return phone; // Return original if format is unrecognized
    }

    // Validate length (should be 14 digits: 00218 + 9 digits)
    if (normalized.length != 14 || !normalized.startsWith('00218')) {
      return phone; // Return original if invalid
    }

    return normalized; // Returns: 00218919005626
  }

  /// Converts international format (00218919005626) to local format (0919005626)
  static String toLocalFormat(String phone) {
    if (phone.isEmpty) return phone;

    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Handle different input formats
    if (digitsOnly.startsWith('00218')) {
      // 00218919005626 -> 0919005626
      return '0${digitsOnly.substring(5)}';
    } else if (digitsOnly.startsWith('218')) {
      // 218919005626 -> 0919005626
      return '0${digitsOnly.substring(3)}';
    } else if (digitsOnly.startsWith('0') && digitsOnly.length == 10) {
      // 0919005626 -> already in local format
      return digitsOnly;
    } else if (digitsOnly.length == 9) {
      // 919005626 -> 0919005626
      return '0$digitsOnly';
    }

    return phone; // Return original if format is unrecognized
  }

  /// Validates if the phone number is a valid Libyan number
  static bool isValidLibyanPhone(String phone) {
    String digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Remove country code prefixes to get local number
    if (digitsOnly.startsWith('00218')) {
      digitsOnly = digitsOnly.substring(5);
    } else if (digitsOnly.startsWith('218')) {
      digitsOnly = digitsOnly.substring(3);
    } else if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.substring(1);
    }

    // Should be 9 digits
    if (digitsOnly.length != 9) return false;

    // Valid Libyan operator codes: 91, 92, 93, 94, 95, 21
    List<String> validOperators = ['91', '92', '93', '94', '95', '21'];
    String operatorCode = digitsOnly.substring(0, 2);

    return validOperators.contains(operatorCode);
  }

  /// Gets only digits in international format (00218919005626)
  static String getDigitsOnly(String phone) {
    String digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.startsWith('00218')) {
      return digitsOnly; // 00218919005626
    } else if (digitsOnly.startsWith('218')) {
      return '00$digitsOnly'; // 00218919005626
    } else if (digitsOnly.startsWith('0') && digitsOnly.length == 10) {
      return '00218${digitsOnly.substring(1)}'; // 00218919005626
    } else if (digitsOnly.length == 9) {
      return '00218$digitsOnly'; // 00218919005626
    }

    return digitsOnly;
  }

  /// Formats phone for display with separators: +218 91-9005626
  static String formatForDisplay(String phone) {
    String international = formatLibyanPhone(phone);

    if (international.length != 14 || !international.startsWith('00218')) {
      return phone;
    }

    // Extract parts: 00218 91 9005626
    String operatorCode = international.substring(5, 7); // 91, 92, etc.
    String subscriberNumber = international.substring(7); // 9005626

    // Format: +218 91-9005626
    return '+218 $operatorCode-$subscriberNumber';
  }
}