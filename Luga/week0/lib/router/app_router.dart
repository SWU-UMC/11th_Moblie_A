import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import '../screen/start_screen.dart';
import '../screen/sign_up_screen.dart';
import '../screen/home_screen.dart';
import '../screen/movie_list_screen.dart';
import '../screen/movie_detail_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/main_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => PopScope(
          canPop: false,
          child: const SignUpScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            currentIndex: _indexFromLocation(state.uri.path),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => PopScope(
              canPop: false,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => const MovieListScreen(),
            routes: [
              GoRoute(
                path: ':movieId',
                builder: (context, state) {
                  final movieId = int.tryParse(state.pathParameters['movieId'] ?? '');
                  return MovieDetailScreen(movieId: movieId ?? -1);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );

  static int _indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}