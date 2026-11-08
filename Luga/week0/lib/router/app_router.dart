import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../data/services/tmdb_movie_service.dart';
import '../view_model/movie_home_view_model.dart';
import '../view_model/movie_detail_view_model.dart';
import '../view_model/movie_list_model.dart';
import '../screen/start_screen.dart';
import '../screen/sign_up_screen.dart';
import '../screen/home_screen.dart';
import '../screen/movie_list_screen.dart';
import '../screen/movie_detail_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/main_screen.dart';
import '../screen/my_ratings_screen.dart';
import '../data/services/rating_api_service.dart';
import '../view_model/my_ratings_view_model.dart';

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
              final movieId = int.tryParse(state.pathParameters['movieId'] ?? '') ?? -1;
              return ChangeNotifierProvider<MovieDetailViewModel>(
                  key: ValueKey(movieId),
                  create: (context) => MovieDetailViewModel(
                      context.read<TmdbMovieService>(),
                      movieId,
                  )..load(),
                  child: MovieDetailScreen(movieId: movieId),
              );
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
              child: ChangeNotifierProvider<MovieHomeViewModel>(
                create: (context) => MovieHomeViewModel(
                  context.read<TmdbMovieService>(),
                )..loadPopular(),
                child: const HomeScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) =>
                ChangeNotifierProvider<MovieListViewModel>(
              create: (context) => MovieListViewModel(
                context.read<TmdbMovieService>(),
              )..loadInitial(),
              child: const MovieListScreen(),
            ),
          ),
          GoRoute(
            path: '/my/ratings',
            builder: (context, state) => ChangeNotifierProvider<MyRatingsViewModel>(
              create: (context) => MyRatingsViewModel(
                context.read<RatingApiService>(),
                context.read<TmdbMovieService>(),
                1,
              )..load(),
              child: const MyRatingsScreen(),
            ),
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