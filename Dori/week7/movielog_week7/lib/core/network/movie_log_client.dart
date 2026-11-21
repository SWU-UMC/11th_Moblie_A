import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

BaseOptions _options() => BaseOptions(baseUrl: 'https://workbook.devnoco.com', connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10));
Dio createMovieLogClient() => Dio(_options());
Dio createAuthMovieLogClient(TokenStorage storage) => Dio(_options())..interceptors.add(AuthInterceptor(storage));
