String? validateRequired(String? value, {String label = 'This field'}) {
  if (value == null || value.trim().isEmpty) {
    return '$label is required.';
  }
  return null;
}

String? validateInternationalUntil(DateTime? value, DateTime now) {
  if (value == null) return null;
  final today = DateTime(now.year, now.month, now.day);
  final selected = DateTime(value.year, value.month, value.day);
  if (selected.isBefore(today)) {
    return 'Choose today or a future date.';
  }
  return null;
}

int clampPaise(int value, int maximum) => value.clamp(0, maximum);
