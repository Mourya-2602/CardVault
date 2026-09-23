T parseEnum<T extends Enum>(List<T> values, Object? raw) {
  final name = raw?.toString().trim().toLowerCase();
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Unknown ${T.toString()} value: $raw');
}

Map<String, dynamic> asJsonMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected a JSON object.');
}

int requirePaise(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('$field must be an integer paise amount.');
}
