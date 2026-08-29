import 'package:supabase_flutter/supabase_flutter.dart';

import '../../profile/data/models/profile_model.dart';
import 'models/connection_model.dart';

class ConnectionsRepository {
  ConnectionsRepository(this._client);

  final SupabaseClient _client;

  // Embeds both sides of the connection via Postgres' default foreign-key
  // constraint names (connections_requester_id_fkey / connections_addressee_id_fkey).
  // If you renamed those constraints, update these aliases to match.
  static const _embed = '''
    id, requester_id, addressee_id, status, created_at,
    requester:profiles!connections_requester_id_fkey(id, username, full_name, avatar_url),
    addressee:profiles!connections_addressee_id_fkey(id, username, full_name, avatar_url)
  ''';

  Future<List<Profile>> searchGolfers(String query) async {
    final data = await _client.from('profiles').select().ilike('username', '%$query%').limit(20);
    return (data as List).map((row) => Profile.fromJson(row)).toList();
  }

  /// All connections involving the current user, any status — incoming,
  /// outgoing, accepted, and declined are all derived from this one query.
  Future<List<Connection>> getAllMyConnections(String userId) async {
    final data = await _client
        .from('connections')
        .select(_embed)
        .or('requester_id.eq.$userId,addressee_id.eq.$userId')
        .order('created_at', ascending: false);
    return (data as List).map((row) => Connection.fromJson(row)).toList();
  }

  Future<void> sendRequest({required String requesterId, required String addresseeId}) async {
    await _client.from('connections').insert({
      'requester_id': requesterId,
      'addressee_id': addresseeId,
    });
  }

  Future<void> respondToRequest(String connectionId, bool accept) async {
    await _client
        .from('connections')
        .update({'status': accept ? 'accepted' : 'declined'})
        .eq('id', connectionId);
  }

  Future<void> cancelRequest(String connectionId) async {
    await _client.from('connections').delete().eq('id', connectionId);
  }
}