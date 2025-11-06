/// Form validation utilities
class Validators {
  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }

    return null;
  }

  /// Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  /// Strong password validation
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase) {
      return 'La contraseña debe tener al menos una mayúscula';
    }

    if (!hasLowercase) {
      return 'La contraseña debe tener al menos una minúscula';
    }

    if (!hasDigit) {
      return 'La contraseña debe tener al menos un número';
    }

    if (!hasSpecialChar) {
      return 'La contraseña debe tener al menos un carácter especial';
    }

    return null;
  }

  /// Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Required field validation
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName es requerido'
          : 'Este campo es requerido';
    }
    return null;
  }

  /// Phone number validation (Argentina format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }

    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Ingresa un teléfono válido (10-15 dígitos)';
    }

    return null;
  }

  /// DNI validation (Argentina)
  static String? validateDNI(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DNI es requerido';
    }

    final dniRegex = RegExp(r'^[0-9]{7,8}$');
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (!dniRegex.hasMatch(cleanedValue)) {
      return 'Ingresa un DNI válido (7-8 dígitos)';
    }

    return null;
  }

  /// Number validation
  static String? validateNumber(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName es requerido'
          : 'Este campo es requerido';
    }

    if (double.tryParse(value) == null) {
      return 'Ingresa un número válido';
    }

    return null;
  }

  /// Min length validation
  static String? validateMinLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName es requerido'
          : 'Este campo es requerido';
    }

    if (value.length < minLength) {
      return fieldName != null
          ? '$fieldName debe tener al menos $minLength caracteres'
          : 'Debe tener al menos $minLength caracteres';
    }

    return null;
  }

  /// Max length validation
  static String? validateMaxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return fieldName != null
          ? '$fieldName debe tener máximo $maxLength caracteres'
          : 'Debe tener máximo $maxLength caracteres';
    }

    return null;
  }

  /// URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'La URL es requerida';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Ingresa una URL válida';
    }

    return null;
  }

  /// CUIT/CUIL validation (Argentina)
  static String? validateCUITCUIL(String? value) {
    if (value == null || value.isEmpty) {
      return 'El CUIT/CUIL es requerido';
    }

    final cuitRegex = RegExp(r'^[0-9]{2}-[0-9]{8}-[0-9]$');

    if (!cuitRegex.hasMatch(value)) {
      return 'Ingresa un CUIT/CUIL válido (XX-XXXXXXXX-X)';
    }

    return null;
  }

  /// Postal code validation (Argentina)
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'El código postal es requerido';
    }

    final postalCodeRegex = RegExp(r'^[0-9]{4}$');

    if (!postalCodeRegex.hasMatch(value)) {
      return 'Ingresa un código postal válido (4 dígitos)';
    }

    return null;
  }

  /// Combine multiple validators
  static String? combine(List<String? Function(String?)> validators, String? value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
