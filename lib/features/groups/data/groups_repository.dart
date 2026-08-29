import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/group_member_model.dart';
import 'models/group_model.dart';

class GroupsRepository {
  GroupsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Group>> getMyGroups(String userId) async {
    final data =
        await _client.from('group_members').select('groups(*)').eq('user_id', userId);
    return (data as List)
        .map((row) => Group.fromJson(row['groups'] as Map<String, dynamic>))
        .toList();
  }

  /// Public groups the user hasn't joined yet.
  Future<List<Group>> getDiscoverablePublicGroups(String userId) async {
    final joinedRows =
        await _client.from('group_members').select('group_id').eq('user_id', userId);
    final joinedIds = (joinedRows as List).map((r) => r['group_id'] as String).toSet();

    final data = await _client
        .from('groups')
        .select()
        .eq('is_private', false)
        .order('created_at', ascending: false);
    return (data as List)
        .map((row) => Group.fromJson(row))
        .where((g) => !joinedIds.contains(g.id))
        .toList();
  }

  Future<Group> createGroup({
    required String name,
    String? description,
    required bool isPrivate,
    required String ownerId,
  }) async {
    final row = await _client
        .from('groups')
        .insert({
          'name': name,
          'description': description,
          'is_private': isPrivate,
          'owner_id': ownerId,
        })
        .select()
        .single();
    return Group.fromJson(row);
  }

  Future<Group> getGroupById(String groupId) async {
    final row = await _client.from('groups').select().eq('id', groupId).single();
    return Group.fromJson(row);
  }

  Future<List<GroupMember>> getMembers(String groupId) async {
    final data = await _client
        .from('group_members')
        .select('*, profiles(username, full_name, avatar_url)')
        .eq('group_id', groupId)
        .order('joined_at');
    return (data as List).map((row) => GroupMember.fromJson(row)).toList();
  }

  /// Used for both self-joining a public group and an admin inviting
  /// someone to a private one — RLS decides which is actually allowed.
  Future<void> addMember(String groupId, String userId) async {
    await _client.from('group_members').insert({'group_id': groupId, 'user_id': userId});
  }

  Future<void> removeMember(String groupId, String userId) async {
    await _client.from('group_members').delete().eq('group_id', groupId).eq('user_id', userId);
  }
}