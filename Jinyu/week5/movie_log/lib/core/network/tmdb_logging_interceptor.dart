import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TmdbLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final maskedHeaders = Map<String, dynamic>.from(options.headers);
    if (maskedHeaders.containsKey('Authorization')) {
      maskedHeaders['Authorization'] = 'Bearer ***';
    }
    if (kDebugMode) {
      debugPrint('[TMDB 요청] ${options.method} ${options.uri}');
      debugPrint('[TMDB 요청 Header] $maskedHeaders');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('[TMDB 요청 Query] ${options.queryParameters}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[TMDB 응답] ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[TMDB 오류] ${err.requestOptions.uri}');
      debugPrint('[TMDB 오류 내용] ${err.message}');
    }
    handler.next(err);
  }
}
