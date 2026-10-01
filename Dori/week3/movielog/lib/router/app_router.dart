import 'package:go_router/go_router.dart';

import '../screens/start_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/main_screen.dart';
import '../screens/my_page_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/start',
    routes: [
      // 시작 화면
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartScreen(),
      ),

      // 회원가입
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // 하단 NavigationBar가 유지되는 영역
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            child: child,
          );
        },
        routes: [
          // 홈
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),

          // 영화 목록
          GoRoute(
            path: '/movies',
            builder: (context, state) => const MovieListScreen(),
          ),

          // 마이페이지
          GoRoute(
            path: '/my',
            builder: (context, state) => const MyPageScreen(),
          ),
        ],
      ),

      // 영화 상세
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final movieId = state.pathParameters['movieId']!;

          return MovieDetailScreen(
            movieId: movieId,
          );
        },
      ),
    ],
  );
}