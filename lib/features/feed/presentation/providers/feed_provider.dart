import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/feed_repository.dart';
import '../../data/models/post_model.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(ref.watch(supabaseClientProvider));
});

final feedProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  return ref.watch(feedRepositoryProvider).getFeed();
});

final myLikedPostIdsProvider = FutureProvider.autoDispose<Set<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return ref.watch(feedRepositoryProvider).getMyLikedPostIds(user.id);
});