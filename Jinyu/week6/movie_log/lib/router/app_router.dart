import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/services/tmdb_movie_service.dart';
import '../data/services/rating_api_service.dart'; // 추가

import '../models/movie.dart';
import '../data/models/tmdb_movie_dto.dart';

import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/my_ratings_view_model.dart'; // 추가

import '../screens/start_screen.dart';
import '../screens/register_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/main_screen.dart'; // 본인 프로젝트에 맞게 TabScreen 또는 MainScreen 사용
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/my_ratings_screen.dart'; // 추가

class AppRouter {
  AppRouter._();

  // 1. root Navigator를 가리키는 키를 클래스에서 선언합니다.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/start',
    navigatorKey: rootNavigatorKey, // GoRouter 전체가 사용할 root Navigator로 등록
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

          if (extra is Movie) {
            resolvedMovie = extra;
          } else if (extra is TmdbMovieDto) {
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
          return TabScreen( // 기존에 사용하시던 TabScreen (또는 MainScreen) 유지
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
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // 2. /my/ratings 하위 라우트 추가 (하단 네비게이션바를 가리기 위해 parentNavigatorKey 설정)
              GoRoute(
                path: 'ratings', // 최종 경로: /my/ratings
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => ChangeNotifierProvider<MyRatingsViewModel>(
                  create: (context) => MyRatingsViewModel(
                    context.read<RatingApiService>(),
                    context.read<TmdbMovieService>(),
                    1, // 학습용 회원 ID (sampleMemberId)
                  )..load(),
                  child: const MyRatingsScreen(),
                ),
              ),
            ],
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