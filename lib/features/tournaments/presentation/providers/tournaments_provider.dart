import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/tournament_model.dart';
import '../../data/tournaments_repository.dart';

final tournamentsRepositoryProvider = Provider<TournamentsRepository>((ref) {
  return TournamentsRepository(ref.watch(supabaseClientProvider));
});

final myTournamentsProvider = FutureProvider.autoDispose<List<Tournament>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(tournamentsRepositoryProvider).getMyTournaments(user.id);
});

final discoverTournamentsProvider = FutureProvider.autoDispose<List<Tournament>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(tournamentsRepositoryProvider).getDiscoverableTournaments(user.id);
});