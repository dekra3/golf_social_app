import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/groups_provider.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myGroupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'Discover groups',
            onPressed: () => context.push('/groups/discover'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/groups/create'),
        child: const Icon(Icons.add),
      ),
      body: myGroupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load groups: $err')),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(
              child: Text(
                'No groups yet — create one or tap the compass to discover public groups.',
              ),
            );
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                leading: Icon(group.isPrivate ? Icons.lock : Icons.public),
                title: Text(group.name),
                subtitle: group.description != null ? Text(group.description!) : null,
                onTap: () => context.push('/groups/${group.id}'),
              );
            },
          );
        },
      ),
    );
  }
}