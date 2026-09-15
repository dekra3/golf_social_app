import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../courses/presentation/providers/courses_provider.dart';
import '../../data/models/hole_score_model.dart';
import '../../data/models/round_model.dart';
import '../providers/rounds_provider.dart';

class RoundSummaryScreen extends ConsumerStatefulWidget {
  const RoundSummaryScreen({super.key, required this.roundId});

  final String roundId;

  @override
  ConsumerState<RoundSummaryScreen> createState() => _RoundSummaryScreenState();
}

class _RoundSummaryScreenState extends ConsumerState<RoundSummaryScreen> {
  Round? _round;
  List<HoleScore>? _scores;
  Map<int, int>? _parsByHole;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final round = await ref.read(roundsRepositoryProvider).getRoundById(widget.roundId);
    final scores = await ref.read(roundsRepositoryProvider).getHoleScores(widget.roundId);

    Map<int, int>? pars;
    if (round.teeId != null) {
      final holes = await ref.read(coursesRepositoryProvider).getHolesForTee(round.teeId!);
      pars = {for (final h in holes) h.holeNumber: h.par};
    }

    setState(() {
      _round = round;
      _scores = scores;
      _parsByHole = pars;
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this round?'),
        content: const Text('This removes the round and all its hole scores. This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(roundsRepositoryProvider).deleteRound(widget.roundId);
    ref.invalidate(roundHistoryProvider);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final round = _round;
    final scores = _scores;
    if (round == null || scores == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final totalPar = _parsByHole?.values.fold<int>(0, (a, b) => a + b);
    final diff =
        (round.totalScore != null && totalPar != null) ? round.totalScore! - totalPar : null;
    final diffLabel = diff == null
        ? ''
        : diff == 0
            ? 'Even par'
            : diff > 0
                ? '+$diff'
                : '$diff';

    return Scaffold(
      appBar: AppBar(
        title: Text(round.courseName ?? 'Round summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit round',
            onPressed: () async {
              await context.push('/rounds/${widget.roundId}/edit');
              _load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete round',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Text('${round.totalScore ?? '-'}', style: Theme.of(context).textTheme.headlineSmall),
                if (diffLabel.isNotEmpty) Text(diffLabel),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...scores.map((score) {
            final par = _parsByHole?[score.holeNumber];
            return ListTile(
              leading: Text('Hole ${score.holeNumber}'),
              title: par != null ? Text('Par $par') : null,
              trailing: Text('${score.strokes}', style: const TextStyle(fontWeight: FontWeight.w600)),
            );
          }),
        ],
      ),
    );
  }
}