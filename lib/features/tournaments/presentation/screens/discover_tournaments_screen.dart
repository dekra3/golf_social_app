import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/tournaments_provider.dart';

class DiscoverTournamentsScreen extends ConsumerWidget {
  const DiscoverTournamentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(discoverTournamentsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Discover tournaments')),
      body: tournamentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load tournaments: $err')),
        data: (tournaments) {
          if (tournaments.isEmpty) {
            return const Center(child: Text('No open tournaments to discover yet.'));
          }
          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final t = tournaments[index];
              final dateStr = '${t.startDate.month}/${t.startDate.day}/${t.startDate.year}';
              return ListTile(
                title: Text(t.name),
                subtitle: Text('${t.courseName ?? 'Unknown course'} • $dateStr'),
                trailing: TextButton(
                  onPressed: user == null
                      ? null
                      : () async {
                          await ref
                              .read(tournamentsRepositoryProvider)
                              .joinTournament(t.id, user.id);
                          ref.invalidate(myTournamentsProvider);
                          ref.invalidate(discoverTournamentsProvider);
                          if (context.mounted) context.push('/tournaments/${t.id}');
                        },
                  child: const Text('Join'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}