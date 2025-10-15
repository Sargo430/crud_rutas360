import 'package:file_picker/file_picker.dart';

/// Helper centralizado para validaciones de campos de texto, numeros y archivos.
class InputValidators {
  static const double minChileLatitude = -56;
  static const double maxChileLatitude = -17;
  static const double minChileLongitude = -76;
  static const double maxChileLongitude = -66;
  static const int minDescriptionLength = 20;
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10 MB

  static final Set<String> _prohibitedWords = {
    'puta',
    'puto',
    'mierda',
    'idiota',
    'estupido',
    'imbecil',
    'maldito',
    'cabron',
    'gil',
    'weon',
    'culiao',
    'hueon',
    'culiado',
    'perra',
  };

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[\u00E1\u00E0\u00E4\u00E2]"), 'a')
        .replaceAll(RegExp(r"[\u00E9\u00E8\u00EB\u00EA]"), 'e')
        .replaceAll(RegExp(r"[\u00ED\u00EC\u00EF\u00EE]"), 'i')
        .replaceAll(RegExp(r"[\u00F3\u00F2\u00F6\u00F4]"), 'o')
        .replaceAll(RegExp(r"[\u00FA\u00F9\u00FC\u00FB]"), 'u')
        .replaceAll('\u00F1', 'n');
  }

  /// Valida una latitud dentro de los rangos permitidos para Chile.
  static String? validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese la latitud';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Ingresa un numero valido';
    }
    if (parsed < minChileLatitude || parsed > maxChileLatitude) {
      return 'La latitud debe estar entre -56 y -17 (Chile)';
    }
    return null;
  }

  /// Valida una longitud dentro del rango permitido.
  static String? validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese la longitud';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Ingresa un numero valido';
    }
    if (parsed < minChileLongitude || parsed > maxChileLongitude) {
      return 'La longitud debe estar entre -76 y -66 (Chile)';
    }
    return null;
  }

  /// Verifica si un texto contiene vocabulario inapropiado.
  static bool containsProhibitedLanguage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }
    final sanitized = _normalize(value)
        .replaceAll(RegExp(r'[^a-z\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    return sanitized.any(_prohibitedWords.contains);
  }

  /// Valida un campo de texto generico y bloquea lenguaje inapropiado.
  static String? validateTextField(
    String? value, {
    required String emptyMessage,
    bool isRequired = true,
  }) {
    if ((value == null || value.trim().isEmpty)) {
      return isRequired ? emptyMessage : null;
    }
    if (containsProhibitedLanguage(value)) {
      return 'Por favor evita usar lenguaje inapropiado.';
    }
    return null;
  }

  /// Valida la longitud minima y lenguaje para descripciones.
  static String? validateDescriptionField(
    String? value, {
    bool isRequired = true,
    String emptyMessage =
        'Por favor ingrese la descripcion del punto de interes',
  }) {
    final baseValidation = validateTextField(
      value,
      emptyMessage: emptyMessage,
      isRequired: isRequired,
    );
    if (baseValidation != null) {
      return baseValidation;
    }
    if (value != null && value.trim().length < minDescriptionLength) {
      return 'La descripcion debe tener al menos $minDescriptionLength caracteres.';
    }
    return null;
  }

  /// Revisa si un archivo seleccionado supera el limite de 10 MB.
  static bool isFileTooLarge(PlatformFile? file) {
    if (file == null) {
      return false;
    }
    final size = file.size;
    return size > maxImageSizeBytes;
  }
}
