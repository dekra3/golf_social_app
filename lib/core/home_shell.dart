import 'package:flutter/material.dart';

import '../features/connections/presentation/screens/connections_list_screen.dart';
import '../features/feed/presentation/screens/feed_screen.dart';
import '../features/groups/presentation/screens/group_list_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/rounds/presentation/screens/round_history_screen.dart';
import '../features/tournaments/presentation/screens/tournament_list_screen.dart';

/// Bottom-tab shell shown after login.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    ProfileScreen(),
    RoundHistoryScreen(),
    ConnectionsListScreen(),
    GroupListScreen(),
    TournamentListScreen(),
    FeedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.golf_course), label: 'Rounds'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Connections'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Groups'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Tournaments'),
          NavigationDestination(icon: Icon(Icons.dynamic_feed), label: 'Feed'),
        ],
      ),
    );
  }
}