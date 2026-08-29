import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/group_member_model.dart';
import '../../data/models/group_model.dart';
import '../providers/groups_provider.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  Group? _group;
  List<GroupMember>? _members;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final group = await ref.read(groupsRepositoryProvider).getGroupById(widget.groupId);
      final members = await ref.read(groupsRepositoryProvider).getMembers(widget.groupId);
      setState(() {
        _group = group;
        _members = members;
      });
    } catch (e) {
      setState(() => _error = 'Could not load group: $e');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _group = null;
      _members = null;
      _error = null;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final group = _group;
    final members = _members;

    if (_error != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(_error!)));
    }
    if (group == null || members == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    GroupMember? myMembership;
    if (user != null) {
      for (final m in members) {
        if (m.userId == user.id) {
          myMembership = m;
          break;
        }
      }
    }
    final isMember = myMembership != null;
    final isAdmin = myMembership?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Invite',
              onPressed: () => context.push('/groups/${group.id}/invite'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Icon(group.isPrivate ? Icons.lock : Icons.public, size: 18),
                const SizedBox(width: 6),
                Text(group.isPrivate ? 'Private group' : 'Public group'),
              ],
            ),
            if (group.description != null) ...[
              const SizedBox(height: 12),
              Text(group.description!),
            ],
            const SizedBox(height: 24),
            if (user != null)
              isMember
                  ? OutlinedButton(
                      onPressed: () async {
                        await ref.read(groupsRepositoryProvider).removeMember(group.id, user.id);
                        ref.invalidate(myGroupsProvider);
                        if (context.mounted) context.pop();
                      },
                      child: const Text('Leave group'),
                    )
                  : (!group.isPrivate
                      ? ElevatedButton(
                          onPressed: () async {
                            await ref.read(groupsRepositoryProvider).addMember(group.id, user.id);
                            ref.invalidate(myGroupsProvider);
                            await _refresh();
                          },
                          child: const Text('Join group'),
                        )
                      : const Text('This is a private group — ask an admin to invite you.')),
            const SizedBox(height: 24),
            Text('Members (${members.length})', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...members.map(
              (m) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: m.avatarUrl != null ? NetworkImage(m.avatarUrl!) : null,
                  child: m.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(m.fullName ?? m.username),
                subtitle: Text('@${m.username}'),
                trailing: m.isAdmin ? const Text('Admin') : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}