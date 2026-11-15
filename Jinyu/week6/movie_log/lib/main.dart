import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/network/tmdb_client.dart';
import 'core/network/movielog_client.dart'; // 1. 워크북 백엔드 클라이언트 임포트 추가
import 'data/services/tmdb_movie_service.dart';
import 'data/services/member_check_service.dart'; // 2. 서비스 임포트 추가
import 'data/services/rating_api_service.dart'; // 3. 서비스 임포트 추가
import 'router/app_router.dart';


Future<void> asyncMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MovieLogApp());
}

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final movieLogClient = createMovieLogClient(); // 4. 워크북 전용 Dio 생성

    return MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        // 5. 아래 두 서비스를 MultiProvider에 추가합니다!
        Provider<MemberCheckService>(
          create: (_) => MemberCheckService(movieLogClient),
        ),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        routerConfig: AppRouter.router,
      ),
    );
  }
}