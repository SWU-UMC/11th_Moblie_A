import 'package:go_router/go_router.dart';
import '../screen/home_screen.dart';
import '../screen/movie_detail_screen.dart';

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
        path: '/movies/:movieId',
        builder: (context, state) {
          final movieId = int.tryParse(state.pathParameters['movieId'] ?? '');
          return MovieDetailScreen(movieId: movieId ?? -1);
        },
      ),
    ],
  );
}