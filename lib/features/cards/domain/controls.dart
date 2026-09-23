import '../../../core/utils/date_format.dart';

class CardControls {
  const CardControls({
    required this.online,
    required this.contactless,
    required this.atm,
    required this.international,
    this.internationalUntil,
  });

  factory CardControls.fromJson(Map<String, dynamic> json) {
    final until = json['internationalUntil'] as String?;
    return CardControls(
      online: json['online'] as bool,
      contactless: json['contactless'] as bool,
      atm: json['atm'] as bool,
      international: json['international'] as bool,
      internationalUntil: until == null ? null : parseUtcToLocal(until),
    );
  }

  final bool online;
  final bool contactless;
  final bool atm;
  final bool international;
  final DateTime? internationalUntil;

  Map<String, Object?> toJson() => {
    'online': online,
    'contactless': contactless,
    'atm': atm,
    'international': international,
    'internationalUntil': internationalUntil?.toUtc().toIso8601String(),
  };

  CardControls copyWith({
    bool? online,
    bool? contactless,
    bool? atm,
    bool? international,
    DateTime? internationalUntil,
  }) {
    return CardControls(
      online: online ?? this.online,
      contactless: contactless ?? this.contactless,
      atm: atm ?? this.atm,
      international: international ?? this.international,
      internationalUntil: internationalUntil ?? this.internationalUntil,
    );
  }
}
