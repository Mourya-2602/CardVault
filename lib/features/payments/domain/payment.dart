import '../../../core/utils/json.dart';

class BillPaymentResult {
  const BillPaymentResult({
    required this.paymentId,
    required this.amountPaise,
    required this.outstandingPaise,
    required this.status,
    this.debitCount,
  });

  factory BillPaymentResult.fromJson(Map<String, dynamic> json) {
    return BillPaymentResult(
      paymentId: json['paymentId'] as String,
      amountPaise: requirePaise(json['amountPaise'], 'amountPaise'),
      outstandingPaise: requirePaise(
        json['outstandingPaise'],
        'outstandingPaise',
      ),
      status: json['status'] as String,
      debitCount: json['debitCount'] as int?,
    );
  }

  final String paymentId;
  final int amountPaise;
  final int outstandingPaise;
  final String status;
  final int? debitCount;
}
