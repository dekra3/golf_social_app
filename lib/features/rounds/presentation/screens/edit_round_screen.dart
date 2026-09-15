import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../courses/data/models/tee_model.dart';
import '../../../courses/presentation/providers/courses_provider.dart';
import '../../data/models/hole_score_model.dart';
import '../../data/models/round_model.dart';
import '../providers/rounds_provider.dart';

/// Unlike ScoreEntryScreen (a step-through flow meant for live scoring
/// hole by hole), this shows every hole at once — better suited for
/// quickly correcting a mis-entered score after the fact.
class EditRoundScreen extends ConsumerStatefulWidget {
  const EditRoundScreen({super.key, required this.roundId});

  final String roundId;

  @override
  ConsumerState<EditRoundScreen> createState() => _EditRoundScreenState();
}

class _EditRoundScreenState extends ConsumerState<EditRoundScreen> {
  Round? _round;
  List<Hole>? _holes;
  final Map<int, int> _strokesByHole = {};
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final round = await ref.read(roundsRepositoryProvider).getRoundById(widget.roundId);
      if (round.teeId == null) {
        setState(() => _error = 'This round has no tee on record, so holes can\'t be shown.');
        return;
      }
      final holes = await ref.read(coursesRepositoryProvider).getHolesForTee(round.teeId!);
      final scores = await ref.read(roundsRepositoryProvider).getHoleScores(widget.roundId);
      final scoresByHole = {for (final s in scores) s.holeNumber: s.strokes};

      setState(() {
        _round = round;
        _holes = holes;
        for (final hole in holes) {
          _strokesByHole[hole.holeNumber] = scoresByHole[hole.holeNumber] ?? hole.par;
        }
      });
    } catch (e) {
      setState(() => _error = 'Could not load round: $e');
    }
  }

  Future<void> _save() async {
    final holes = _holes;
    if (holes == null) return;

    setState(() => _isSaving = true);
    try {
      for (final hole in holes) {
        await ref.read(roundsRepositoryProvider).upsertHoleScore(
              widget.roundId,
              HoleScore(holeNumber: hole.holeNumber, strokes: _strokesByHole[hole.holeNumber]!),
            );
      }
      final total = _strokesByHole.values.fold<int>(0, (a, b) => a + b);
      await ref.read(roundsRepositoryProvider).completeRound(widget.roundId, total);
      ref.invalidate(roundHistoryProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final holes = _holes;

    if (_error != null) {
      return Scaffold(appBar: AppBar(title: const Text('Edit round')), body: Center(child: Text(_error!)));
    }
    if (holes == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_round?.courseName ?? 'Edit round'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: holes.length,
        itemBuilder: (context, index) {
          final hole = holes[index];
          final strokes = _strokesByHole[hole.holeNumber]!;
          return ListTile(
            title: Text('Hole ${hole.holeNumber}'),
            subtitle: Text('Par ${hole.par}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: strokes > 1
                      ? () => setState(() => _strokesByHole[hole.holeNumber] = strokes - 1)
                      : null,
                ),
                SizedBox(
                  width: 24,
                  child: Text(
                    '$strokes',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _strokesByHole[hole.holeNumber] = strokes + 1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}