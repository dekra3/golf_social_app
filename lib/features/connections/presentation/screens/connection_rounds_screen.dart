import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/data/models/profile_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../rounds/data/models/round_model.dart';
import '../../../rounds/presentation/providers/rounds_provider.dart';

/// Read-only view of a connection's rounds — no start/edit actions here.
/// Reuses RoundsRepository.getRoundsForUser, which now works for any user
/// you're an accepted connection with, thanks to the Phase 3 RLS policy.
class ConnectionRoundsScreen extends ConsumerStatefulWidget {
  const ConnectionRoundsScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<ConnectionRoundsScreen> createState() => _ConnectionRoundsScreenState();
}

class _ConnectionRoundsScreenState extends ConsumerState<ConnectionRoundsScreen> {
  Profile? _profile;
  List<Round>? _rounds;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).getProfile(widget.userId);
      final rounds = await ref.read(roundsRepositoryProvider).getRoundsForUser(widget.userId);
      setState(() {
        _profile = profile;
        _rounds = rounds;
      });
    } catch (e) {
      setState(() => _error = 'Could not load rounds: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final rounds = _rounds;

    return Scaffold(
      appBar: AppBar(title: Text(profile != null ? '@${profile.username}\'s rounds' : 'Rounds')),
      body: _error != null
          ? Center(child: Text(_error!))
          : rounds == null
              ? const Center(child: CircularProgressIndicator())
              : rounds.isEmpty
                  ? const Center(child: Text('No rounds logged yet.'))
                  : ListView.builder(
                      itemCount: rounds.length,
                      itemBuilder: (context, index) {
                        final round = rounds[index];
                        final date = round.playedAt;
                        final dateStr = '${date.month}/${date.day}/${date.year}';
                        return ListTile(
                          title: Text(round.courseName ?? 'Unknown course'),
                          subtitle: Text(dateStr),
                          trailing: Text(
                            round.totalScore?.toString() ?? 'In progress',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
    );
  }
}