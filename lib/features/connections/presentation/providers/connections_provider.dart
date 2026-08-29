import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/connections_repository.dart';
import '../../data/models/connection_model.dart';

final connectionsRepositoryProvider = Provider<ConnectionsRepository>((ref) {
  return ConnectionsRepository(ref.watch(supabaseClientProvider));
});

/// Every connection involving the current user, any status. Incoming and
/// accepted lists below are just filtered views of this one query, so a
/// single invalidate() after any action keeps everything in sync.
final myConnectionsProvider = FutureProvider.autoDispose<List<Connection>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(connectionsRepositoryProvider).getAllMyConnections(user.id);
});

final incomingRequestsProvider = Provider.autoDispose<List<Connection>>((ref) {
  final user = ref.watch(currentUserProvider);
  final all = ref.watch(myConnectionsProvider).value ?? [];
  if (user == null) return [];
  return all.where((c) => c.status == 'pending' && c.addresseeId == user.id).toList();
});

final acceptedConnectionsProvider = Provider.autoDispose<List<Connection>>((ref) {
  final all = ref.watch(myConnectionsProvider).value ?? [];
  return all.where((c) => c.status == 'accepted').toList();
});