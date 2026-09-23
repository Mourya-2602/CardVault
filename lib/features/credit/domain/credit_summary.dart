import '../../../core/utils/date_format.dart';
import '../../../core/utils/json.dart';

class CreditSummary {
  const CreditSummary({
    required this.limitPaise,
    required this.availablePaise,
    required this.outstandingPaise,
    required this.minDuePaise,
    required this.dueDate,
  });

  factory CreditSummary.fromJson(Map<String, dynamic> json) {
    return CreditSummary(
      limitPaise: requirePaise(json['limitPaise'], 'limitPaise'),
      availablePaise: requirePaise(json['availablePaise'], 'availablePaise'),
      outstandingPaise: requirePaise(
        json['outstandingPaise'],
        'outstandingPaise',
      ),
      minDuePaise: requirePaise(json['minDuePaise'], 'minDuePaise'),
      dueDate: parseUtcToLocal(json['dueDate'] as String),
    );
  }

  final int limitPaise;
  final int availablePaise;
  final int outstandingPaise;
  final int minDuePaise;
  final DateTime dueDate;

  bool isDueWithinDays(int days, DateTime now) {
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.add(Duration(days: days));
    return !due.isBefore(today) && !due.isAfter(cutoff);
  }
}
