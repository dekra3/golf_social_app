import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/post_model.dart';
import '../providers/feed_provider.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);
    final likedIds = ref.watch(myLikedPostIdsProvider).value ?? <String>{};
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/feed/create'),
        child: const Icon(Icons.add),
      ),
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load feed: $err')),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Text('No posts yet — share a round to get things started.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(feedProvider);
              ref.invalidate(myLikedPostIdsProvider);
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _PostCard(
                  post: post,
                  isLiked: likedIds.contains(post.id),
                  currentUserId: user?.id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  const _PostCard({required this.post, required this.isLiked, required this.currentUserId});

  final Post post;
  final bool isLiked;
  final String? currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = post.createdAt;
    final dateStr = '${date.month}/${date.day}/${date.year}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.avatarUrl != null ? NetworkImage(post.avatarUrl!) : null,
                  child: post.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.fullName ?? post.username,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            if (post.content != null && post.content!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(post.content!),
            ],
            if (post.imageUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.imageUrl!, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: currentUserId == null
                      ? null
                      : () async {
                          final repo = ref.read(feedRepositoryProvider);
                          if (isLiked) {
                            await repo.unlikePost(post.id, currentUserId!);
                          } else {
                            await repo.likePost(post.id, currentUserId!);
                          }
                          ref.invalidate(feedProvider);
                          ref.invalidate(myLikedPostIdsProvider);
                        },
                ),
                Text('${post.likeCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.mode_comment_outlined),
                  onPressed: () => context.push('/feed/${post.id}'),
                ),
                Text('${post.commentCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}