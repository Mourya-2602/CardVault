class ReplacementInfo {
  const ReplacementInfo({required this.requested, required this.status});

  factory ReplacementInfo.fromJson(Map<String, dynamic> json) {
    return ReplacementInfo(
      requested: json['requested'] as bool,
      status: json['status'] as String,
    );
  }

  final bool requested;
  final String status;
}
