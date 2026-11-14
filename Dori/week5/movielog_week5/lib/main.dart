
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/network/tmdb_client.dart';
import 'core/network/movie_log_client.dart';

import 'data/services/tmdb_movie_service.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/rating_api_service.dart';

import 'view_models/sign_up_view_model.dart';
import 'view_models/learning_member_session.dart';

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
    final movieLogClient = createMovieLogClient();

    return MultiProvider(
      providers: [
        // TMDB 영화 API
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(
            createTmdbClient(),
          ),
        ),

        // 7주차 회원가입 및 중복 확인 API
        Provider<SignUpService>(
          create: (_) => SignUpService(movieLogClient),
        ),

        // 평점 API
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
        ),

        // 회원가입 ViewModel
        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(
            context.read<SignUpService>(),
          ),
        ),

        // 현재 학습용 회원 ID 저장
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
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
