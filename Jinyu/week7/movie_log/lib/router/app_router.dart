import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/services/tmdb_movie_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/models/tmdb_movie_dto.dart';

import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/movie_detail_view_model.dart'; // MovieDetailViewModel 임포트 확인
import '../view_models/my_ratings_view_model.dart';
import '../view_models/learning_member_session.dart'; // 학습용 회원 세션

import '../screens/start_screen.dart';
import '../screens/register_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/main_screen.dart'; // 본인 프로젝트에 맞게 TabScreen 또는 MainScreen 사용
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart'; // MovieDetailScreen 임포트 확인
import '../screens/my_ratings_screen.dart';

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
            routes: [
              // 7주차 가이드에 맞춘 /movies/:movieId 하위 라우트 및 상세 로더 적용
              GoRoute(
                path: ':movieId',
                parentNavigatorKey: rootNavigatorKey, // 하단 바 위로 전체 화면 덮기
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['movieId'] ?? '');
                  if (id == null || id < 1) {
                    return const Scaffold(
                      body: Center(child: Text('영화 ID가 올바르지 않습니다.')),
                    );
                  }
                  final extra = state.extra;
                  return MovieDetailLoader(
                    movieId: id,
                    initialMovie: extra is TmdbMovieDto && extra.id == id ? extra : null,
                  );
                },
              ),
            ],
          ),

          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // 2. /my/ratings 하위 라우트: 가입된 실제 memberId 연동
              GoRoute(
                path: 'ratings', // 최종 경로: /my/ratings
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = context.read<LearningMemberSession>().memberId;
                  if (id == null) {
                    return Scaffold(
                      appBar: AppBar(centerTitle: true, title: const Text('내가 등록한 평점')),
                      body: const Center(child: Text('학습용 회원가입이 필요합니다.')),
                    );
                  }
                  return ChangeNotifierProvider<MyRatingsViewModel>(
                    create: (context) => MyRatingsViewModel(
                      context.read<RatingApiService>(),
                      context.read<TmdbMovieService>(),
                      id, // LearningMemberSession에서 가져온 실제 회원 ID 주입
                    )..load(),
                    child: const MyRatingsScreen(),
                  );
                },
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

// 7주차 가이드에 맞춘 영화 상세 로더 위젯
class MovieDetailLoader extends StatefulWidget {
  const MovieDetailLoader({super.key, required this.movieId, this.initialMovie});
  final int movieId;
  final TmdbMovieDto? initialMovie;

  @override
  State<MovieDetailLoader> createState() => _MovieDetailLoaderState();
}

class _MovieDetailLoaderState extends State<MovieDetailLoader> {
  late final Future<TmdbMovieDto> _movieFuture;

  @override
  void initState() {
    super.initState();
    _movieFuture = widget.initialMovie != null
        ? Future.value(widget.initialMovie!)
        : context.read<TmdbMovieService>().fetchMovieDetail(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TmdbMovieDto>(
      future: _movieFuture, // build마다 새 Future를 만들지 않습니다.
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('영화를 불러오지 못했습니다.')),
          );
        }
        return ChangeNotifierProvider<MovieDetailViewModel>(
          create: (context) => MovieDetailViewModel(
            context.read<RatingApiService>(),
            context.read<LearningMemberSession>().memberId,
            snapshot.data!,
          ),
          child: const MovieDetailScreen(),
        );
      },
    );
  }
}