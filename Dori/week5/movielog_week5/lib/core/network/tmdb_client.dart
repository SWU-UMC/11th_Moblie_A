import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Dio createTmdbClient() {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Authorization': 'Bearer ${dotenv.env['TMDB_ACCESS_TOKEN'] ?? ''}', 'accept': 'application/json'},
  ));
  if (kDebugMode) dio.interceptors.add(_SafeLogger());
  return dio;
}

class _SafeLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[TMDB 요청] ${options.method} ${options.uri} query=${options.queryParameters} Authorization=Bearer ***');
    handler.next(options);
  }
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[TMDB 응답] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[TMDB 오류] ${err.requestOptions.uri} ${err.message}');
    handler.next(err);
  }
}
