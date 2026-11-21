import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.storage);
  final TokenStorage storage;
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.uri.path;
    final protected = options.uri.host == 'workbook.devnoco.com' &&
      (path == '/v7/members/me' || path == '/v7/ratings' || path.startsWith('/v7/ratings/'));
    options.headers.remove('Authorization');
    if (!protected) { handler.next(options); return; }
    try {
      final token = await storage.read();
      if (token != null && token.isNotEmpty) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }
}
