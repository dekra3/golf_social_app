import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/round_model.dart';
import '../../data/rounds_repository.dart';

final roundsRepositoryProvider = Provider<RoundsRepository>((ref) {
  return RoundsRepository(ref.watch(supabaseClientProvider));
});

final roundHistoryProvider = FutureProvider.autoDispose<List<Round>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(roundsRepositoryProvider).getRoundsForUser(user.id);
});