import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/comment_model.dart';
import 'models/post_model.dart';

class FeedRepository {
  FeedRepository(this._client);

  final SupabaseClient _client;

  static const _postEmbed =
      '*, profiles(username, full_name, avatar_url), likes(count), comments(count)';

  Future<List<Post>> getFeed() async {
    final data = await _client
        .from('posts')
        .select(_postEmbed)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).map((row) => Post.fromJson(row)).toList();
  }

  /// Post IDs the current user has liked — fetched once so the feed can
  /// render filled vs. outline hearts without a per-post query.
  Future<Set<String>> getMyLikedPostIds(String userId) async {
    final data = await _client.from('likes').select('post_id').eq('user_id', userId);
    return (data as List).map((r) => r['post_id'] as String).toSet();
  }

  Future<Post> createPost({
    required String userId,
    String? content,
    String? roundId,
    String? tournamentId,
    String? imageUrl,
  }) async {
    final row = await _client
        .from('posts')
        .insert({
          'user_id': userId,
          'content': content,
          'round_id': roundId,
          'tournament_id': tournamentId,
          'image_url': imageUrl,
        })
        .select(_postEmbed)
        .single();
    return Post.fromJson(row);
  }

  Future<void> deletePost(String postId) async {
    await _client.from('posts').delete().eq('id', postId);
  }

  /// Uploads a post image to the `post-images` storage bucket and
  /// returns its public URL. Requires that bucket to exist.
  Future<String> uploadPostImage(String userId, List<int> bytes, String ext) async {
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('post-images').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('post-images').getPublicUrl(path);
  }

  Future<void> likePost(String postId, String userId) async {
    await _client.from('likes').insert({'post_id': postId, 'user_id': userId});
  }

  Future<void> unlikePost(String postId, String userId) async {
    await _client.from('likes').delete().eq('post_id', postId).eq('user_id', userId);
  }

  Future<List<Comment>> getComments(String postId) async {
    final data = await _client
        .from('comments')
        .select('*, profiles(username, full_name, avatar_url)')
        .eq('post_id', postId)
        .order('created_at');
    return (data as List).map((row) => Comment.fromJson(row)).toList();
  }

  Future<void> addComment(String postId, String userId, String content) async {
    await _client.from('comments').insert({
      'post_id': postId,
      'user_id': userId,
      'content': content,
    });
  }
}