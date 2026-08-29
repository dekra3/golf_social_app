import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../connections/presentation/providers/connections_provider.dart';
import '../providers/groups_provider.dart';

/// Lets a group admin invite one of their accepted connections to the
/// group — the natural pool of people to invite to a private group.
class InviteToGroupScreen extends ConsumerWidget {
  const InviteToGroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accepted = ref.watch(acceptedConnectionsProvider);
    final me = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Invite a connection')),
      body: accepted.isEmpty
          ? const Center(child: Text('You have no connections yet to invite.'))
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
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await ref.read(groupsRepositoryProvider).addMember(groupId, other.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invited @${other.username}')),
                        );
                      }
                    },
                    child: const Text('Invite'),
                  ),
                );
              },
            ),
    );
  }
}