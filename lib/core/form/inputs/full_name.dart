import 'package:formz/formz.dart';

enum FullNameValidationError { empty, tooShort }

/// A validated full-name input used for member and staff records.
class FullName extends FormzInput<String, FullNameValidationError> {
  const FullName.pure() : super.pure('');
  const FullName.dirty([super.value = '']) : super.dirty();

  @override
  FullNameValidationError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return FullNameValidationError.empty;
    if (trimmed.length < 2) return FullNameValidationError.tooShort;
    return null;
  }
}
