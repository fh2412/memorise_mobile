import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorise_mobile/ui/memories/views/create_memory_view.dart';
import 'package:memorise_mobile/ui/memories/views/join_memory_view.dart';
import 'package:memorise_mobile/ui/user/views/memory_invite_view.dart';
import 'package:memorise_mobile/ui/user/views/user_screen_view.dart';
import '../ui/auth/views/login_view.dart';
import '../ui/home/views/home_view.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final bool loggedIn = FirebaseAuth.instance.currentUser != null;
      final bool loggingIn = state.matchedLocation == '/login';

      // 1. If not logged in, send them to login
      if (!loggedIn) {
        if (loggingIn) return null;

        // Capture the location they were TRYING to hit (e.g., /join/xyz)
        final fromLocation = state.matchedLocation;

        // Redirect to login, but append the original destination as a query parameter
        return '/login?from=$fromLocation';
      }

      // 2. If logged in but sitting on the login page...
      if (loggingIn) {
        // Check if we have a "from" destination in the URL
        final from = state.uri.queryParameters['from'];

        // If "from" exists and isn't just the home page, go there. Otherwise, go home.
        return (from != null && from != '/') ? from : '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => HomeView()),
      GoRoute(path: '/login', builder: (context, state) => LoginView()),
      GoRoute(path: '/user', builder: (context, state) => UserScreenView()),
      GoRoute(
        path: '/memory/create',
        builder: (context, state) => CreateMemoryScreen(),
      ),
      GoRoute(
        path: '/invite/:memoryId',
        name: 'invite',
        builder: (context, state) {
          final memoryId = state.pathParameters['memoryId']!;
          return MemoryInviteScreen(memoryId: memoryId);
        },
      ),
      GoRoute(
        path: '/join/:token',
        name: 'join-memory',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return JoinMemoryScreen(token: token);
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
