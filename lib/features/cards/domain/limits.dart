import '../../../core/utils/json.dart';

class CardLimits {
  const CardLimits({
    required this.atmDailyPaise,
    required this.posDailyPaise,
    required this.onlineDailyPaise,
    required this.maxPaise,
  });

  factory CardLimits.fromJson(Map<String, dynamic> json) {
    return CardLimits(
      atmDailyPaise: requirePaise(json['atmDailyPaise'], 'atmDailyPaise'),
      posDailyPaise: requirePaise(json['posDailyPaise'], 'posDailyPaise'),
      onlineDailyPaise: requirePaise(
        json['onlineDailyPaise'],
        'onlineDailyPaise',
      ),
      maxPaise: requirePaise(json['maxPaise'], 'maxPaise'),
    );
  }

  final int atmDailyPaise;
  final int posDailyPaise;
  final int onlineDailyPaise;
  final int maxPaise;

  Map<String, Object?> toJson() => {
    'atmDailyPaise': atmDailyPaise,
    'posDailyPaise': posDailyPaise,
    'onlineDailyPaise': onlineDailyPaise,
    'maxPaise': maxPaise,
  };
}
