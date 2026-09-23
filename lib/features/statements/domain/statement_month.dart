import '../../../core/utils/json.dart';

class StatementMonth {
  const StatementMonth({
    required this.month,
    required this.openingPaise,
    required this.closingPaise,
  });

  factory StatementMonth.fromJson(Map<String, dynamic> json) {
    return StatementMonth(
      month: json['month'] as String,
      openingPaise: requirePaise(json['openingPaise'], 'openingPaise'),
      closingPaise: requirePaise(json['closingPaise'], 'closingPaise'),
    );
  }

  final String month;
  final int openingPaise;
  final int closingPaise;
}
