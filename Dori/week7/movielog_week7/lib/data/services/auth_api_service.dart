import 'package:dio/dio.dart';
import '../models/member_info.dart';

Map<String, dynamic> responseResult(dynamic data) {
  if (data is! Map || data['result'] is! Map) throw const FormatException('서버 응답 result가 없습니다.');
  return Map<String, dynamic>.from(data['result'] as Map);
}
String? responseErrorCode(DioException error) {
  final data = error.response?.data;
  return data is Map ? data['code'] as String? : null;
}
String responseErrorMessage(DioException error) {
  final data = error.response?.data;
  return data is Map && data['message'] is String ? data['message'] as String : '요청에 실패했습니다. 다시 시도해 주세요.';
}
class AuthApiService {
  AuthApiService(this.publicDio, this.authDio);
  final Dio publicDio;
  final Dio authDio;
  Future<String> login(String email, String password) async {
    final response = await publicDio.post('/v7/auth/login', data: {'email': email.trim(), 'password': password});
    return responseResult(response.data)['accessToken'] as String;
  }
  Future<MemberInfo> me() async => MemberInfo.fromJson(responseResult((await authDio.get('/v7/members/me')).data));
  Future<MemberInfo> updateNickname(String nickname) async => MemberInfo.fromJson(responseResult((await authDio.patch('/v7/members/me', data: {'nickname': nickname})).data));
}
