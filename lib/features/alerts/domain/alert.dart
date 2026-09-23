import '../../../core/utils/date_format.dart';
import '../../../core/utils/json.dart';

class TransactionAlert {
  const TransactionAlert({
    required this.id,
    required this.cardId,
    required this.merchant,
    required this.location,
    required this.amountPaise,
    required this.at,
  });

  factory TransactionAlert.fromJson(Map<String, dynamic> json) {
    return TransactionAlert(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      merchant: json['merchant'] as String,
      location: json['location'] as String,
      amountPaise: requirePaise(json['amountPaise'], 'amountPaise'),
      at: parseUtcToLocal(json['at'] as String),
    );
  }

  final String id;
  final String cardId;
  final String merchant;
  final String location;
  final int amountPaise;
  final DateTime at;
}
