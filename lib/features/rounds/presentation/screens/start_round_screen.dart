import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../courses/data/models/tee_model.dart';
import '../../../courses/presentation/providers/courses_provider.dart';
import '../providers/rounds_provider.dart';

/// Starts a round for the given course. If the course has only one tee,
/// starts immediately; if it has several, shows a picker first — this is
/// also the natural hook point for tournaments to specify which tee
/// everyone plays from.
class StartRoundScreen extends ConsumerStatefulWidget {
  const StartRoundScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<StartRoundScreen> createState() => _StartRoundScreenState();
}

class _StartRoundScreenState extends ConsumerState<StartRoundScreen> {
  List<Tee>? _tees;
  bool _starting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTees();
  }

  Future<void> _loadTees() async {
    try {
      final tees = await ref.read(coursesRepositoryProvider).getTeesForCourse(widget.courseId);
      if (tees.isEmpty) {
        setState(() => _error = 'This course has no tees set up.');
        return;
      }
      setState(() => _tees = tees);
      if (tees.length == 1) {
        _startWithTee(tees.first);
      }
    } catch (e) {
      setState(() => _error = 'Could not load tees: $e');
    }
  }

  Future<void> _startWithTee(Tee tee) async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final round = await ref.read(roundsRepositoryProvider).startRound(
            userId: user.id,
            courseId: widget.courseId,
            teeId: tee.id,
          );

      if (mounted) context.pushReplacement('/rounds/${round.id}/score/${tee.id}');
    } catch (e) {
      setState(() {
        _error = 'Could not start round: $e';
        _starting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Start round')),
        body: Center(child: Text(_error!)),
      );
    }

    final tees = _tees;
    if (tees == null || _starting || tees.length == 1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Starting round...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Multiple tees — let the user pick which one to play from.
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your tee')),
      body: ListView.builder(
        itemCount: tees.length,
        itemBuilder: (context, index) {
          final tee = tees[index];
          final details = [
            'Par ${tee.par}',
            if (tee.yardage != null) '${tee.yardage} yds',
            if (tee.rating != null) 'Rating ${tee.rating}',
            if (tee.slope != null) 'Slope ${tee.slope}',
          ].join(' • ');
          return ListTile(
            title: Text(tee.name),
            subtitle: Text(details),
            onTap: () => _startWithTee(tee),
          );
        },
      ),
    );
  }
}