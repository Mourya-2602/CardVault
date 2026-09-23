class MoneyFormatException implements Exception {
  const MoneyFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Largest whole-rupee part we accept (11 digits) to reject overflow input.
const int maxRupeeDigits = 11;

int parsePaise(String? input, {bool allowNegative = false}) {
  final normalized = input?.trim().replaceAll(',', '') ?? '';
  if (normalized.isEmpty) {
    throw const MoneyFormatException('Enter an amount.');
  }
  final isNegative = normalized.startsWith('-');
  if (!allowNegative && isNegative) {
    throw const MoneyFormatException('Amount cannot be negative.');
  }

  final unsignedValue = isNegative ? normalized.substring(1) : normalized;
  if (unsignedValue.isEmpty) {
    throw const MoneyFormatException('Enter a valid amount.');
  }
  final parts = unsignedValue.split('.');
  if (parts.length > 2 || parts.any((part) => part.isEmpty)) {
    throw const MoneyFormatException('Enter a valid amount.');
  }
  final wholeDigits = parts.first;
  if (wholeDigits.length > maxRupeeDigits ||
      !RegExp(r'^\d+$').hasMatch(wholeDigits)) {
    throw const MoneyFormatException('Enter a valid amount.');
  }
  final whole = int.parse(wholeDigits);
  final decimal = parts.length == 1 ? '' : parts.last;
  if (decimal.length > 2 ||
      (decimal.isNotEmpty && !RegExp(r'^\d+$').hasMatch(decimal))) {
    throw const MoneyFormatException('Enter up to two decimal places.');
  }

  final decimalPaise = decimal.padRight(2, '0');
  final paise =
      whole * 100 + int.parse(decimalPaise.isEmpty ? '0' : decimalPaise);
  return isNegative ? -paise : paise;
}

String formatPaise(int paise, {bool includeSymbol = true}) {
  final absolute = paise.abs();
  final whole = absolute ~/ 100;
  final decimals = (absolute % 100).toString().padLeft(2, '0');
  final sign = paise < 0 ? '-' : '';
  final formattedWhole = formatIndianInteger(whole);
  return '$sign${includeSymbol ? '₹' : ''}$formattedWhole.$decimals';
}

String formatIndianInteger(int value) {
  final digits = value.abs().toString();
  if (digits.length <= 3) {
    return '${value < 0 ? '-' : ''}$digits';
  }
  final lastThree = digits.substring(digits.length - 3);
  var prefix = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (prefix.length > 2) {
    groups.insert(0, prefix.substring(prefix.length - 2));
    prefix = prefix.substring(0, prefix.length - 2);
  }
  if (prefix.isNotEmpty) groups.insert(0, prefix);
  return '${value < 0 ? '-' : ''}${groups.join(',')},$lastThree';
}
