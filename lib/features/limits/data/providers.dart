import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import 'limits_repository.dart';

final limitsRepositoryProvider = Provider<LimitsRepository>((ref) {
  return LimitsRepository(ref.watch(apiClientProvider));
});
