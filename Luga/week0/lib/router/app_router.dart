import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import '../screen/start_screen.dart';
import '../screen/sign_up_screen.dart';
import '../screen/home_screen.dart';
import '../screen/movie_list_screen.dart';
import '../screen/movie_detail_screen.dart';
import '../screen/profile_screen.dart';
import '../widget/main_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => PopScope(
          canPop: false,
          child: const SignUpScreen(),
        ),
      ),
      // 상세 화면은 하단 NavigationBar 없이 독립된 화면으로 표시
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final movieId = int.tryParse(state.pathParameters['movieId'] ?? '');
          return MovieDetailScreen(movieId: movieId ?? -1);
        },
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