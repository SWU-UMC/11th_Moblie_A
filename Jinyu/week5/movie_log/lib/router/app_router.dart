import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/services/tmdb_movie_service.dart';

import '../models/movie.dart';

import '../data/models/tmdb_movie_dto.dart';

import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';

import '../screens/start_screen.dart';
import '../screens/register_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';

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
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),

      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final movieId =
              int.tryParse(state.pathParameters['movieId'] ?? '');

          final extra = state.extra;
          Movie? resolvedMovie;

          // 1. extra로 전달된 데이터가 기존 Movie 모델인 경우
          if (extra is Movie) {
            resolvedMovie = extra;
          } 
          // 2. extra로 전달된 데이터가 TMDB DTO인 경우 (Mapper를 이용해 변환)
          else if (extra is TmdbMovieDto) {
            resolvedMovie = extra.toDomain();
          }

          return MovieDetailScreen(
            movieId: movieId,
            movie: resolvedMovie,
          );
        },
      ),

      ShellRoute(
        builder: (context, state, child) {
          return TabScreen(
            currentIndex: _indexFromLocation(
              state.uri.path,
            ),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) {
              return ChangeNotifierProvider(
                create: (context) =>
                    MovieHomeViewModel(
                      context.read<TmdbMovieService>(),
                    )..loadPopular(),
                child: const HomeScreen(),
              );
            },
          ),

          GoRoute(
            path: '/movies',
            builder: (context, state) {
              return ChangeNotifierProvider(
                create: (context) =>
                    MovieListViewModel(
                      context.read<TmdbMovieService>(),
                    )..loadInitial(),
                child: const MovieListScreen(),
              );
            },
          ),

          GoRoute(
            path: '/my',
            builder: (context, state) =>
                const ProfileScreen(),
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