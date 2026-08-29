// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rounds/presentation/providers/rounds_provider.dart';
import '../../data/models/tournament_entry_model.dart';
import '../../data/models/tournament_model.dart';
import '../providers/tournaments_provider.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  const TournamentDetailScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  ConsumerState<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen> {
  Tournament? _tournament;
  List<TournamentEntry>? _entries;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tournament =
          await ref.read(tournamentsRepositoryProvider).getTournamentById(widget.tournamentId);
      final entries =
          await ref.read(tournamentsRepositoryProvider).getEntries(widget.tournamentId);
      setState(() {
        _tournament = tournament;
        _entries = entries;
      });
    } catch (e) {
      setState(() => _error = 'Could not load tournament: $e');
    }
  }

  Future<void> _startRound() async {
    final tournament = _tournament;
    final user = ref.read(currentUserProvider);
    if (tournament == null || user == null) return;
    if (tournament.courseId == null || tournament.teeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This tournament has no course/tee set.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final round = await ref.read(roundsRepositoryProvider).startRound(
            userId: user.id,
            courseId: tournament.courseId!,
            teeId: tournament.teeId!,
            tournamentId: tournament.id,
          );
      if (mounted) context.push('/rounds/${round.id}/score/${tournament.teeId}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tournament = _tournament;
    final entries = _entries;

    if (_error != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(_error!)));
    }
    if (tournament == null || entries == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isEntrant = user != null && entries.any((e) => e.userId == user.id);
    final dateStr =
        '${tournament.startDate.month}/${tournament.startDate.day}/${tournament.startDate.year}';

    return Scaffold(
      appBar: AppBar(title: Text(tournament.name)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            tournament.format.replaceAll('_', ' '),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${tournament.courseName ?? 'No course set'} · ${tournament.teeName ?? 'No tee set'}',
          ),
          const SizedBox(height: 4),
          Text('Starts $dateStr'),
          const SizedBox(height: 24),
          if (user != null)
            isEntrant
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _busy ? null : _startRound,
                        child: const Text('Start my round'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () async {
                                await ref
                                    .read(tournamentsRepositoryProvider)
                                    .leaveTournament(tournament.id, user.id);
                                ref.invalidate(myTournamentsProvider);
                                if (mounted) context.pop();
                              },
                        child: const Text('Withdraw'),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(tournamentsRepositoryProvider)
                          .joinTournament(tournament.id, user.id);
                      ref.invalidate(myTournamentsProvider);
                      await _load();
                    },
                    child: const Text('Join tournament'),
                  ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.push('/tournaments/${tournament.id}/leaderboard'),
            child: const Text('View leaderboard'),
          ),
          const SizedBox(height: 24),
          Text('Entrants (${entries.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...entries.map(
            (e) => ListTile(
              leading: CircleAvatar(
                backgroundImage: e.avatarUrl != null ? NetworkImage(e.avatarUrl!) : null,
                child: e.avatarUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(e.fullName ?? e.username),
              subtitle: Text('@${e.username}'),
            ),
          ),
        ],
      ),
    );
  }
}