import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/hole_score_model.dart';
import 'models/round_model.dart';

class RoundsRepository {
  RoundsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Round>> getRoundsForUser(String userId) async {
    final data = await _client
        .from('rounds')
        .select('*, courses(name)')
        .eq('user_id', userId)
        .order('played_at', ascending: false);
    return (data as List).map((row) => Round.fromJson(row)).toList();
  }

  Future<Round> getRoundById(String roundId) async {
    final data =
        await _client.from('rounds').select('*, courses(name)').eq('id', roundId).single();
    return Round.fromJson(data);
  }

  Future<Round> startRound({
    required String userId,
    required String courseId,
    required String teeId,
    String? tournamentId,
  }) async {
    final row = await _client
        .from('rounds')
        .insert({
          'user_id': userId,
          'course_id': courseId,
          'tee_id': teeId,
          'tournament_id': tournamentId,
        })
        .select()
        .single();
    return Round.fromJson(row);
  }

  /// All rounds tagged to a tournament, ordered for a leaderboard —
  /// lowest total_score first, in-progress (null) rounds last.
  /// Requires the Phase 5 RLS policy granting entrants visibility into
  /// each other's tournament rounds.
  Future<List<Round>> getRoundsForTournament(String tournamentId) async {
    final data = await _client
        .from('rounds')
        .select('*, courses(name), profiles(username, full_name)')
        .eq('tournament_id', tournamentId)
        .order('total_score', ascending: true);
    return (data as List).map((row) => Round.fromJson(row)).toList();
  }

  /// Upserts a single hole's score — safe to call repeatedly as the user
  /// moves through the round, not just once at the end.
  Future<void> upsertHoleScore(String roundId, HoleScore score) async {
    await _client
        .from('hole_scores')
        .upsert(score.toInsertJson(roundId), onConflict: 'round_id,hole_number');
  }

  Future<List<HoleScore>> getHoleScores(String roundId) async {
    final data = await _client
        .from('hole_scores')
        .select()
        .eq('round_id', roundId)
        .order('hole_number');
    return (data as List).map((row) => HoleScore.fromJson(row)).toList();
  }

  Future<void> completeRound(String roundId, int totalScore) async {
    await _client.from('rounds').update({'total_score': totalScore}).eq('id', roundId);
  }
}