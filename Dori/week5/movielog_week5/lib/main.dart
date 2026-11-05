
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/network/tmdb_client.dart';
import 'core/network/movie_log_client.dart';

import 'data/services/tmdb_movie_service.dart';
import 'data/services/member_check_service.dart';
import 'data/services/rating_api_service.dart';

import 'view_models/sign_up_view_model.dart';

import 'screens/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const MovieLogApp());
}

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 5주차 TMDB 영화 API
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(
            createTmdbClient(),
          ),
        ),

        // 6주차 닉네임·이메일 중복 확인 API
        Provider<MemberCheckService>(
          create: (_) => MemberCheckService(
            createMovieLogClient(),
          ),
        ),

        // 6주차 평점 조회 API
        Provider<RatingApiService>(
          create: (_) => RatingApiService(
            createMovieLogClient(),
          ),
        ),

        // 회원가입 ViewModel
        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(
            context.read<MemberCheckService>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
          ),
          useMaterial3: true,
        ),
        home: const RegisterScreen(),
      ),
    );
  }
}
