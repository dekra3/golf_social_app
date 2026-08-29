import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/groups_provider.dart';

class DiscoverGroupsScreen extends ConsumerWidget {
  const DiscoverGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(discoverGroupsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Discover groups')),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load groups: $err')),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Text('No public groups to discover yet.'));
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                leading: const Icon(Icons.public),
                title: Text(group.name),
                subtitle: group.description != null ? Text(group.description!) : null,
                trailing: TextButton(
                  onPressed: user == null
                      ? null
                      : () async {
                          await ref.read(groupsRepositoryProvider).addMember(group.id, user.id);
                          ref.invalidate(myGroupsProvider);
                          ref.invalidate(discoverGroupsProvider);
                          if (context.mounted) context.push('/groups/${group.id}');
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