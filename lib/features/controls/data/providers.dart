import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import 'controls_repository.dart';

final controlsRepositoryProvider = Provider<ControlsRepository>((ref) {
  return ControlsRepository(ref.watch(apiClientProvider));
});
