import '../../../core/utils/json.dart';

enum CardType { debit, credit }

enum CardNetwork { visa, mastercard, rupay }

enum CardStatus { active, frozen, blocked }

class CardModel {
  const CardModel({
    required this.id,
    required this.type,
    required this.network,
    required this.maskedNumber,
    required this.expiry,
    required this.status,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String,
      type: parseEnum(CardType.values, json['type']),
      network: parseEnum(CardNetwork.values, json['network']),
      maskedNumber: json['maskedNumber'] as String,
      expiry: json['expiry'] as String,
      status: parseEnum(CardStatus.values, json['status']),
    );
  }

  final String id;
  final CardType type;
  final CardNetwork network;
  final String maskedNumber;
  final String expiry;
  final CardStatus status;

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.name,
    'network': network.name,
    'maskedNumber': maskedNumber,
    'expiry': expiry,
    'status': status.name,
  };

  CardModel copyWith({CardStatus? status}) {
    return CardModel(
      id: id,
      type: type,
      network: network,
      maskedNumber: maskedNumber,
      expiry: expiry,
      status: status ?? this.status,
    );
  }
}
