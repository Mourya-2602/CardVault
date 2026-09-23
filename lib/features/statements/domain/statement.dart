import '../../../core/utils/date_format.dart';
import '../../../core/utils/json.dart';

class StatementTransaction {
  const StatementTransaction({
    required this.id,
    required this.date,
    required this.merchant,
    required this.amountPaise,
    required this.category,
  });

  factory StatementTransaction.fromJson(Map<String, dynamic> json) {
    return StatementTransaction(
      id: json['id'] as String,
      date: parseUtcToLocal(json['date'] as String),
      merchant: json['merchant'] as String,
      amountPaise: requirePaise(json['amountPaise'], 'amountPaise'),
      category: json['category'] as String,
    );
  }

  final String id;
  final DateTime date;
  final String merchant;
  final int amountPaise;
  final String category;
}

class Statement {
  const Statement({
    required this.month,
    required this.openingPaise,
    required this.closingPaise,
    required this.transactions,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'] as List<dynamic>? ?? const [];
    return Statement(
      month: json['month'] as String,
      openingPaise: requirePaise(json['openingPaise'], 'openingPaise'),
      closingPaise: requirePaise(json['closingPaise'], 'closingPaise'),
      transactions: rawTransactions
          .map((item) => StatementTransaction.fromJson(asJsonMap(item)))
          .toList(growable: false),
    );
  }

  final String month;
  final int openingPaise;
  final int closingPaise;
  final List<StatementTransaction> transactions;
}
