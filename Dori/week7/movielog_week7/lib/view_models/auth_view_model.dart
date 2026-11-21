
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/storage/token_storage.dart';
import '../data/models/member_info.dart';
import '../data/models/rating_dto.dart';
import '../data/services/auth_api_service.dart';

enum AuthStatus {
  initializing,
  signedOut,
  authenticating,
  signedIn,
  retryRequired,
}

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this.api, this.storage);

  final AuthApiService api;
  final TokenStorage storage;

  AuthStatus status = AuthStatus.initializing;
  MemberInfo? member;
  String? message;
  bool sessionExpired = false;

  int _version = 0;
  bool _disposed = false;

  final List<RatingDto> sessionRatings = [];

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool _current(int v) => !_disposed && v == _version;

  bool _isInvalid(DioException e) =>
      const {
        'AUTH401_2',
        'AUTH401_3',
        'AUTH401_4',
      }.contains(responseErrorCode(e));

  // 자동 로그인 및 저장된 토큰 검증
  Future<void> restoreSession() async {
    final v = ++_version;

    status = AuthStatus.initializing;
    message = null;
    member = null;
    _notify();

    try {
      final token = await storage.read();

      if (!_current(v)) return;

      if (token == null || token.isEmpty) {
        status = AuthStatus.signedOut;
      } else {
        member = await api.me();

        if (!_current(v)) return;

        status = AuthStatus.signedIn;
      }
    } on DioException catch (e) {
      if (!_current(v)) return;

      if (_isInvalid(e)) {
        await expireSession();
        return;
      }

      status = AuthStatus.retryRequired;
      message = '세션 확인에 실패했어요. 다시 시도해 주세요.';
    } catch (_) {
      if (!_current(v)) return;

      status = AuthStatus.retryRequired;
      message = '저장소를 확인하지 못했어요.';
    }

    _notify();
  }

  // 로그인
  Future<void> login(String email, String password) async {
    if (status == AuthStatus.authenticating) return;

    final v = ++_version;

    status = AuthStatus.authenticating;
    message = null;
    sessionExpired = false;
    member = null;
    _notify();

    try {
      final token = await api.login(email, password);

      if (!_current(v)) return;

      await storage.save(token);

      if (!_current(v)) return;

      member = await api.me();

      if (!_current(v)) return;

      sessionRatings.clear();
      status = AuthStatus.signedIn;
    } on DioException catch (e) {
      if (!_current(v)) return;

      status = AuthStatus.signedOut;

      message = responseErrorCode(e) == 'AUTH401_1'
          ? '이메일 또는 비밀번호를 확인해 주세요.'
          : responseErrorMessage(e);

      try {
        await storage.clear();
      } catch (_) {}
    } catch (_) {
      if (!_current(v)) return;

      status = AuthStatus.signedOut;
      message = '로그인에 실패했습니다.';

      try {
        await storage.clear();
      } catch (_) {}
    }

    _notify();
  }

  // 🧪 개발 전용: 무효 토큰 테스트
  Future<void> testInvalidToken() async {
    if (!kDebugMode || status != AuthStatus.signedIn) return;

    // 현재 저장된 정상 토큰을 무효한 값으로 교체
    await storage.save('invalid.test.token');

    // 무효 토큰으로 회원 정보 API 요청
    // 서버에서 AUTH401_2/3/4를 반환하면
    // expireSession()이 실행되어 로그인 화면으로 이동
    await restoreSession();
  }

  // 로그아웃
  Future<void> logout() => _clear(expired: false);

  // 토큰 만료 처리
  Future<void> expireSession() => _clear(expired: true);

  Future<void> _clear({required bool expired}) async {
    ++_version;

    status = AuthStatus.signedOut;
    member = null;
    sessionRatings.clear();
    sessionExpired = expired;
    message = null;

    _notify();

    try {
      await storage.clear();
    } catch (_) {
      message = '토큰을 삭제하지 못했습니다.';
    }

    _notify();
  }

  void consumeExpired() {
    sessionExpired = false;
  }

  // 닉네임 수정
  Future<void> updateNickname(String nickname) async {
    try {
      member = await api.updateNickname(nickname);
      _notify();
    } on DioException catch (e) {
      if (_isInvalid(e)) {
        await expireSession();
      }
      rethrow;
    }
  }

  // 이번 로그인 세션에서 등록한 평점 저장
  void addRating(RatingDto rating) {
    sessionRatings.removeWhere(
      (r) => r.ratingId == rating.ratingId,
    );

    sessionRatings.add(rating);
    _notify();
  }

  // 평점 삭제
  void removeRating(int id) {
    sessionRatings.removeWhere(
      (r) => r.ratingId == id,
    );

    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_version;
    super.dispose();
  }
}
