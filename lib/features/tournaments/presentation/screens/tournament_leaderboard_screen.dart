import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../rounds/presentation/providers/rounds_provider.dart';

class TournamentLeaderboardScreen extends ConsumerWidget {
  const TournamentLeaderboardScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: FutureBuilder(
        future: ref.read(roundsRepositoryProvider).getRoundsForTournament(tournamentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Could not load leaderboard: ${snapshot.error}'));
          }
          final rounds = snapshot.data ?? [];
          if (rounds.isEmpty) {
            return const Center(child: Text('No rounds logged for this tournament yet.'));
          }
          return ListView.builder(
            itemCount: rounds.length,
            itemBuilder: (context, index) {
              final round = rounds[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(round.fullName ?? round.username ?? 'Unknown'),
                subtitle: round.username != null ? Text('@${round.username}') : null,
                trailing: Text(
                  round.totalScore?.toString() ?? 'In progress',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            },
          );
        },
      ),
    );
  }
}