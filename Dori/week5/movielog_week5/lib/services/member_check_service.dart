
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';

class MemberCheckService {
  MemberCheckService(this._dio);

  final Dio _dio;

  Future<bool> checkNickname(String nickname) async {
    final encoded = Uri.encodeComponent(nickname.trim());

    final response = await _dio.get(
      '/v5/members/nickname/$encoded',
    );

    debugPrint('닉네임 중복 확인 응답: ${response.data}');

    final data = response.data as Map<String, dynamic>;
    return data['available'] == true;
  }

  Future<bool> checkEmail(String email) async {
    final encoded = Uri.encodeComponent(email.trim());

    final response = await _dio.get(
      '/v5/members/email/$encoded',
    );

    debugPrint('이메일 중복 확인 응답: ${response.data}');

    final data = response.data as Map<String, dynamic>;
    return data['available'] == true;
  }
}
