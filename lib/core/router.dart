import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/connections/presentation/screens/connection_requests_screen.dart';
import '../features/connections/presentation/screens/connection_rounds_screen.dart';
import '../features/connections/presentation/screens/golfer_search_screen.dart';
import '../features/courses/presentation/screens/add_course_screen.dart';
import '../features/courses/presentation/screens/add_tee_screen.dart';
import '../features/courses/presentation/screens/course_detail_screen.dart';
import '../features/courses/presentation/screens/course_list_screen.dart';
import '../features/feed/presentation/screens/create_post_screen.dart';
import '../features/feed/presentation/screens/post_detail_screen.dart';
import '../features/groups/presentation/screens/create_group_screen.dart';
import '../features/groups/presentation/screens/discover_groups_screen.dart';
import '../features/groups/presentation/screens/group_detail_screen.dart';
import '../features/groups/presentation/screens/invite_to_group_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/rounds/presentation/screens/round_summary_screen.dart';
import '../features/rounds/presentation/screens/score_entry_screen.dart';
import '../features/rounds/presentation/screens/start_round_screen.dart';
import '../features/tournaments/presentation/screens/create_tournament_screen.dart';
import '../features/tournaments/presentation/screens/discover_tournaments_screen.dart';
import '../features/tournaments/presentation/screens/tournament_detail_screen.dart';
import '../features/tournaments/presentation/screens/tournament_leaderboard_screen.dart';
import 'home_shell.dart';

/// Turns the Supabase auth stream into a [Listenable] so go_router
/// re-evaluates its redirect logic whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isSignedIn = ref.read(currentUserProvider) != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!isSignedIn && !isAuthRoute) return '/login';
      if (isSignedIn && isAuthRoute) return '/home';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
      GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
      GoRoute(path: '/courses', builder: (context, state) => const CourseListScreen()),
      GoRoute(path: '/courses/add', builder: (context, state) => const AddCourseScreen()),
      GoRoute(
        path: '/courses/:courseId',
        builder: (context, state) =>
            CourseDetailScreen(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        path: '/courses/:courseId/add-tee',
        builder: (context, state) => AddTeeScreen(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        path: '/rounds/start/:courseId',
        builder: (context, state) =>
            StartRoundScreen(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        path: '/rounds/:roundId/score/:teeId',
        builder: (context, state) => ScoreEntryScreen(
          roundId: state.pathParameters['roundId']!,
          teeId: state.pathParameters['teeId']!,
        ),
      ),
      GoRoute(
        path: '/rounds/:roundId/summary',
        builder: (context, state) =>
            RoundSummaryScreen(roundId: state.pathParameters['roundId']!),
      ),
      GoRoute(path: '/connections/search', builder: (context, state) => const GolferSearchScreen()),
      GoRoute(
        path: '/connections/requests',
        builder: (context, state) => const ConnectionRequestsScreen(),
      ),
      GoRoute(
        path: '/connections/:userId/rounds',
        builder: (context, state) =>
            ConnectionRoundsScreen(userId: state.pathParameters['userId']!),
      ),
      GoRoute(path: '/groups/discover', builder: (context, state) => const DiscoverGroupsScreen()),
      GoRoute(path: '/groups/create', builder: (context, state) => const CreateGroupScreen()),
      GoRoute(
        path: '/groups/:groupId',
        builder: (context, state) => GroupDetailScreen(groupId: state.pathParameters['groupId']!),
      ),
      GoRoute(
        path: '/groups/:groupId/invite',
        builder: (context, state) =>
            InviteToGroupScreen(groupId: state.pathParameters['groupId']!),
      ),
      GoRoute(
        path: '/tournaments/discover',
        builder: (context, state) => const DiscoverTournamentsScreen(),
      ),
      GoRoute(
        path: '/tournaments/create',
        builder: (context, state) => const CreateTournamentScreen(),
      ),
      GoRoute(
        path: '/tournaments/:tournamentId',
        builder: (context, state) =>
            TournamentDetailScreen(tournamentId: state.pathParameters['tournamentId']!),
      ),
      GoRoute(
        path: '/tournaments/:tournamentId/leaderboard',
        builder: (context, state) =>
            TournamentLeaderboardScreen(tournamentId: state.pathParameters['tournamentId']!),
      ),
      GoRoute(path: '/feed/create', builder: (context, state) => const CreatePostScreen()),
      GoRoute(
        path: '/feed/:postId',
        builder: (context, state) => PostDetailScreen(postId: state.pathParameters['postId']!),
      ),
    ],
  );
});