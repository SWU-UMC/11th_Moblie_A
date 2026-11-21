import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/network/tmdb_client.dart';
import 'core/network/movie_log_client.dart';
import 'core/storage/token_storage.dart';
import 'data/services/tmdb_movie_service.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/auth_api_service.dart';
import 'view_models/sign_up_view_model.dart';
import 'view_models/learning_member_session.dart';
import 'view_models/auth_view_model.dart';
import 'screens/login_screen.dart';
import 'screens/movie_list_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MovieLogApp());
}
class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});
  @override Widget build(BuildContext context) {
    const storage = TokenStorage();
    final publicClient = createMovieLogClient();
    final authClient = createAuthMovieLogClient(storage);
    return MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: storage),
        Provider<TmdbMovieService>(create: (_) => TmdbMovieService(createTmdbClient())),
        Provider<SignUpService>(create: (_) => SignUpService(publicClient)),
        Provider<RatingApiService>(create: (_) => RatingApiService(publicClient, authClient)),
        Provider<AuthApiService>(create: (_) => AuthApiService(publicClient, authClient)),
        ChangeNotifierProvider<SignUpViewModel>(create: (c) => SignUpViewModel(c.read<SignUpService>())),
        ChangeNotifierProvider<LearningMemberSession>(create: (_) => LearningMemberSession()),
        ChangeNotifierProvider<AuthViewModel>(create: (c) => AuthViewModel(c.read<AuthApiService>(), storage)..restoreSession()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog Week 7',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)), useMaterial3: true),
        home: const _AuthGate(),
      ),
    );
  }
}
class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override Widget build(BuildContext context) => Consumer<AuthViewModel>(builder: (context, auth, _) {
    switch (auth.status) {
      case AuthStatus.initializing: return const SplashScreen();
      case AuthStatus.retryRequired: return SplashScreen(message: auth.message, onRetry: auth.restoreSession);
      case AuthStatus.signedOut: case AuthStatus.authenticating: return const LoginScreen();
      case AuthStatus.signedIn: return const MovieListScreen();
    }
  });
}
