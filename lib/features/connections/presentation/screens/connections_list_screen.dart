import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/connections_provider.dart';

class ConnectionsListScreen extends ConsumerWidget {
  const ConnectionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider);
    final accepted = ref.watch(acceptedConnectionsProvider);
    final incoming = ref.watch(incomingRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My connections'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${incoming.length}'),
              isLabelVisible: incoming.isNotEmpty,
              child: const Icon(Icons.mail_outline),
            ),
            tooltip: 'Requests',
            onPressed: () => context.push('/connections/requests'),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Find golfers',
            onPressed: () => context.push('/connections/search'),
          ),
        ],
      ),
      body: accepted.isEmpty
          ? const Center(child: Text('No connections yet — tap the search icon to find golfers.'))
          : ListView.builder(
              itemCount: accepted.length,
              itemBuilder: (context, index) {
                final connection = accepted[index];
                final other = me != null ? connection.otherProfile(me.id) : connection.requester;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        other.avatarUrl != null ? NetworkImage(other.avatarUrl!) : null,
                    child: other.avatarUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(other.fullName ?? other.username),
                  subtitle: Text('@${other.username}'),
                  onTap: () => context.push('/connections/${other.id}/rounds'),
                );
              },
            ),
    );
  }
}