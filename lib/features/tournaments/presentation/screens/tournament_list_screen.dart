import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/tournaments_provider.dart';

class TournamentListScreen extends ConsumerWidget {
  const TournamentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(myTournamentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My tournaments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'Discover tournaments',
            onPressed: () => context.push('/tournaments/discover'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tournaments/create'),
        child: const Icon(Icons.add),
      ),
      body: tournamentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load tournaments: $err')),
        data: (tournaments) {
          if (tournaments.isEmpty) {
            return const Center(
              child: Text('No tournaments yet — create one or discover open tournaments.'),
            );
          }
          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final t = tournaments[index];
              final dateStr = '${t.startDate.month}/${t.startDate.day}/${t.startDate.year}';
              return ListTile(
                title: Text(t.name),
                subtitle: Text('${t.courseName ?? 'Unknown course'} • $dateStr'),
                onTap: () => context.push('/tournaments/${t.id}'),
              );
            },
          );
        },
      ),
    );
  }
}