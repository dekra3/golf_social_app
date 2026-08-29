import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/tournament_entry_model.dart';
import 'models/tournament_model.dart';

class TournamentsRepository {
  TournamentsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Tournament>> getMyTournaments(String userId) async {
    final data = await _client
        .from('tournament_entries')
        .select('tournaments(*, courses(name), tees(name))')
        .eq('user_id', userId);
    return (data as List)
        .map((row) => Tournament.fromJson(row['tournaments'] as Map<String, dynamic>))
        .toList();
  }

  /// Open tournaments (no group) the user hasn't joined yet. Group-scoped
  /// tournaments aren't discoverable this way — those surface through the
  /// group itself, matching how private groups work.
  Future<List<Tournament>> getDiscoverableTournaments(String userId) async {
    final joinedRows =
        await _client.from('tournament_entries').select('tournament_id').eq('user_id', userId);
    final joinedIds = (joinedRows as List).map((r) => r['tournament_id'] as String).toSet();

    final data = await _client
        .from('tournaments')
        .select('*, courses(name), tees(name)')
        .filter('group_id', 'is', null)
        .order('start_date');
    return (data as List)
        .map((row) => Tournament.fromJson(row))
        .where((t) => !joinedIds.contains(t.id))
        .toList();
  }

  Future<Tournament> createTournament({
    required String name,
    required String format,
    required String courseId,
    required String teeId,
    required DateTime startDate,
    DateTime? endDate,
    String? groupId,
    required String createdBy,
  }) async {
    final row = await _client
        .from('tournaments')
        .insert({
          'name': name,
          'format': format,
          'course_id': courseId,
          'tee_id': teeId,
          'start_date': startDate.toIso8601String().split('T').first,
          'end_date': endDate?.toIso8601String().split('T').first,
          'group_id': groupId,
          'created_by': createdBy,
        })
        .select('*, courses(name), tees(name)')
        .single();
    return Tournament.fromJson(row);
  }

  Future<Tournament> getTournamentById(String tournamentId) async {
    final row = await _client
        .from('tournaments')
        .select('*, courses(name), tees(name)')
        .eq('id', tournamentId)
        .single();
    return Tournament.fromJson(row);
  }

  Future<List<TournamentEntry>> getEntries(String tournamentId) async {
    final data = await _client
        .from('tournament_entries')
        .select('*, profiles(username, full_name, avatar_url)')
        .eq('tournament_id', tournamentId)
        .order('joined_at');
    return (data as List).map((row) => TournamentEntry.fromJson(row)).toList();
  }

  Future<void> joinTournament(String tournamentId, String userId) async {
    await _client
        .from('tournament_entries')
        .insert({'tournament_id': tournamentId, 'user_id': userId});
  }

  Future<void> leaveTournament(String tournamentId, String userId) async {
    await _client
        .from('tournament_entries')
        .delete()
        .eq('tournament_id', tournamentId)
        .eq('user_id', userId);
  }
}