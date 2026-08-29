import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/rounds_provider.dart';

class RoundHistoryScreen extends ConsumerWidget {
  const RoundHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundsAsync = ref.watch(roundHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My rounds')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/courses'),
        icon: const Icon(Icons.add),
        label: const Text('Start round'),
      ),
      body: roundsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load rounds: $err')),
        data: (rounds) {
          if (rounds.isEmpty) {
            return const Center(
              child: Text('No rounds yet — start one to track your first score.'),
            );
          }
          return ListView.builder(
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
                onTap: () => context.push('/rounds/${round.id}/summary'),
              );
            },
          );
        },
      ),
    );
  }
}