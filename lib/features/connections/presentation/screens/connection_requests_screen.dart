import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/connections_provider.dart';

class ConnectionRequestsScreen extends ConsumerWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider);
    final incoming = ref.watch(incomingRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Connection requests')),
      body: incoming.isEmpty
          ? const Center(child: Text('No pending requests'))
          : ListView.builder(
              itemCount: incoming.length,
              itemBuilder: (context, index) {
                final connection = incoming[index];
                final other = me != null ? connection.otherProfile(me.id) : connection.requester;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        other.avatarUrl != null ? NetworkImage(other.avatarUrl!) : null,
                    child: other.avatarUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(other.fullName ?? other.username),
                  subtitle: Text('@${other.username}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await ref
                              .read(connectionsRepositoryProvider)
                              .respondToRequest(connection.id, true);
                          ref.invalidate(myConnectionsProvider);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await ref
                              .read(connectionsRepositoryProvider)
                              .respondToRequest(connection.id, false);
                          ref.invalidate(myConnectionsProvider);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}