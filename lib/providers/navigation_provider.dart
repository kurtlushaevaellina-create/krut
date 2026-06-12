import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/providers/auth_provider.dart';
import 'package:track_dev/ui/auth/login_screen.dart';
import 'package:track_dev/ui/home/home_screen.dart';
import 'package:track_dev/ui/projects/projects_screen.dart';
import 'package:track_dev/ui/root/authenticated_shell.dart';
import 'package:track_dev/ui/timer/timer_screen.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const timer = '/timer';
  static const projects = '/projects';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authStateProvider, (_, _) {
    refreshNotifier.value++;
  });

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) {
        return null;
      }

      final session = authState.asData?.value;
      final isLoggedIn = session != null && !session.isExpired;
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isOnLogin) {
        return AppRoutes.login;
      }
      if (isLoggedIn && isOnLogin) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AuthenticatedShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.timer,
                builder: (context, state) => const TimerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.projects,
                builder: (context, state) => const ProjectsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
