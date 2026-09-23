import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import 'bill_payment_repository.dart';

final billPaymentRepositoryProvider = Provider<BillPaymentRepository>((ref) {
  return BillPaymentRepository(ref.watch(apiClientProvider));
});
