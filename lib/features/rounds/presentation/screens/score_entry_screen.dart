import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../courses/data/models/tee_model.dart';
import '../../../courses/presentation/providers/courses_provider.dart';
import '../../data/models/hole_score_model.dart';
import '../providers/rounds_provider.dart';

class ScoreEntryScreen extends ConsumerStatefulWidget {
  const ScoreEntryScreen({super.key, required this.roundId, required this.teeId});

  final String roundId;
  final String teeId;

  @override
  ConsumerState<ScoreEntryScreen> createState() => _ScoreEntryScreenState();
}

class _ScoreEntryScreenState extends ConsumerState<ScoreEntryScreen> {
  List<Hole>? _holes;
  int _currentIndex = 0;
  final Map<int, int> _strokesByHole = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadHoles();
  }

  Future<void> _loadHoles() async {
    final holes = await ref.read(coursesRepositoryProvider).getHolesForTee(widget.teeId);
    setState(() {
      _holes = holes;
      for (final hole in holes) {
        _strokesByHole[hole.holeNumber] = hole.par; // default guess: par
      }
    });
  }

  Future<void> _saveCurrentHoleAndAdvance() async {
    final holes = _holes!;
    final hole = holes[_currentIndex];
    final strokes = _strokesByHole[hole.holeNumber]!;

    setState(() => _saving = true);
    try {
      await ref.read(roundsRepositoryProvider).upsertHoleScore(
            widget.roundId,
            HoleScore(holeNumber: hole.holeNumber, strokes: strokes),
          );

      if (_currentIndex == holes.length - 1) {
        final total = _strokesByHole.values.fold<int>(0, (a, b) => a + b);
        await ref.read(roundsRepositoryProvider).completeRound(widget.roundId, total);
        ref.invalidate(roundHistoryProvider);
        if (mounted) context.pushReplacement('/rounds/${widget.roundId}/summary');
      } else {
        setState(() => _currentIndex++);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final holes = _holes;
    if (holes == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hole = holes[_currentIndex];
    final strokes = _strokesByHole[hole.holeNumber]!;
    final isLastHole = _currentIndex == holes.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text('Hole ${hole.holeNumber} of ${holes.length}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Par ${hole.par}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: strokes > 1
                      ? () => setState(() => _strokesByHole[hole.holeNumber] = strokes - 1)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('$strokes', style: Theme.of(context).textTheme.headlineSmall),
                ),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _strokesByHole[hole.holeNumber] = strokes + 1),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saving ? null : _saveCurrentHoleAndAdvance,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isLastHole ? 'Finish round' : 'Next hole'),
            ),
            if (_currentIndex > 0)
              TextButton(
                onPressed: () => setState(() => _currentIndex--),
                child: const Text('Back'),
              ),
          ],
        ),
      ),
    );
  }
}