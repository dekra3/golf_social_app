import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/data/models/profile_model.dart';
import '../providers/connections_provider.dart';

class GolferSearchScreen extends ConsumerStatefulWidget {
  const GolferSearchScreen({super.key});

  @override
  ConsumerState<GolferSearchScreen> createState() => _GolferSearchScreenState();
}

class _GolferSearchScreenState extends ConsumerState<GolferSearchScreen> {
  final _controller = TextEditingController();
  List<Profile>? _results;
  bool _searching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final results = await ref.read(connectionsRepositoryProvider).searchGolfers(query);
      setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  String? _statusFor(String otherUserId, String myUserId, List<dynamic> myConnections) {
    for (final c in myConnections) {
      if (c.otherProfile(myUserId).id == otherUserId) return c.status as String;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider);
    final myConnections = ref.watch(myConnectionsProvider).value ?? [];
    final results = _results;

    return Scaffold(
      appBar: AppBar(title: const Text('Find golfers')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search by username',
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_searching) const CircularProgressIndicator(),
            if (results != null)
              Expanded(
                child: results.isEmpty
                    ? const Center(child: Text('No golfers found'))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final profile = results[index];
                          if (me != null && profile.id == me.id) return const SizedBox.shrink();
                          final status =
                              me == null ? null : _statusFor(profile.id, me.id, myConnections);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: profile.avatarUrl != null
                                  ? NetworkImage(profile.avatarUrl!)
                                  : null,
                              child: profile.avatarUrl == null ? const Icon(Icons.person) : null,
                            ),
                            title: Text(profile.fullName ?? profile.username),
                            subtitle: Text('@${profile.username}'),
                            trailing: _ActionButton(me: me, profile: profile, status: status),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({required this.me, required this.profile, required this.status});

  final dynamic me;
  final Profile profile;
  final String? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (me == null) return const SizedBox.shrink();

    switch (status) {
      case 'accepted':
        return const Text('Connected');
      case 'pending':
        return const Text('Pending');
      case 'declined':
        return const Text('Declined');
      default:
        return TextButton(
          onPressed: () async {
            await ref
                .read(connectionsRepositoryProvider)
                .sendRequest(requesterId: me.id, addresseeId: profile.id);
            ref.invalidate(myConnectionsProvider);
          },
          child: const Text('Connect'),
        );
    }
  }
}