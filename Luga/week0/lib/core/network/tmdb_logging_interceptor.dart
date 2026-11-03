import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/config/tmdb_config.dart';

class TmdbLoggingInterceptor extends Interceptor {
    static const _maxBodyLength = 300;

    @override
    void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
        final maskedHeaders = <String, dynamic>{};
        options.headers.forEach((key, value) {
            if (key.toLowerCase() == 'authorization') {
                maskedHeaders[key] = TmdbConfig.accessToken.isEmpty
                    ? '(토큰 비어 있음: .env 로드 확인 필요)'
                    : 'Bearer ***';
            } else {
                maskedHeaders[key] = value;
            }
        });

        debugPrint('[TMDB 요청] ${options.method} ${options.uri}');
        debugPrint('[TMDB 요청 Header] $maskedHeaders');
        handler.next(options);
    }

    @override
    void onResponse(Response response, ResponseInterceptorHandler handler) {
        debugPrint('[TMDB 응답] ${response.statusCode} ${response.requestOptions.uri}');
        final body = '${response.data}';
        debugPrint(
            '[TMDB 응답 Body] '
            '${body.length > _maxBodyLength ? '${body.substring(0, _maxBodyLength)}...' : body}',
        );
        handler.next(response);
    }

    @override
    void onError(DioException err, ErrorInterceptorHandler handler) {
        debugPrint('[TMDB 오류] ${err.response?.statusCode ?? '응답 없음'} ${err.requestOptions.uri}');
        debugPrint('[TMDB 오류 유형] ${err.type.name}');
        debugPrint('[TMDB 오류 내용] ${err.message}');
        handler.next(err);
    }
}