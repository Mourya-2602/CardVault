class RevealedCard {
  const RevealedCard({
    required this.pan,
    required this.expiry,
    required this.cvv,
    required this.expiresInSeconds,
  });

  factory RevealedCard.fromJson(Map<String, dynamic> json) {
    return RevealedCard(
      pan: json['pan'] as String,
      expiry: json['expiry'] as String,
      cvv: json['cvv'] as String,
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 30,
    );
  }

  final String pan;
  final String expiry;
  final String cvv;
  final int expiresInSeconds;
}
