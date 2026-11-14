
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/create_member_request.dart';
import '../data/services/sign_up_service.dart';

enum CheckStatus {
  idle,
  checking,
  available,
  duplicated,
  error,
}

enum SubmitStatus {
  idle,
  submitting,
  success,
  error,
}

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);

  final SignUpService _service;

  CheckStatus nicknameStatus = CheckStatus.idle;
  CheckStatus emailStatus = CheckStatus.idle;

  SubmitStatus submitStatus = SubmitStatus.idle;

  String? nicknameErrorText;
  String? emailErrorText;
  String? passwordErrorText;
  String? snackbarMessage;

  int? createdMemberId;

  String _nickname = '';
  String _email = '';

  String? _duplicatedNickname;
  String? _duplicatedEmail;

  int _nicknameVersion = 0;
  int _emailVersion = 0;

  bool get canCheckNickname =>
      _nickname.isNotEmpty &&
      nicknameStatus != CheckStatus.checking &&
      nicknameStatus != CheckStatus.duplicated &&
      submitStatus != SubmitStatus.submitting;

  bool get canCheckEmail =>
      _email.isNotEmpty &&
      emailStatus != CheckStatus.checking &&
      emailStatus != CheckStatus.duplicated &&
      submitStatus != SubmitStatus.submitting;

  bool get canSubmit =>
      nicknameStatus == CheckStatus.available &&
      emailStatus == CheckStatus.available &&
      submitStatus != SubmitStatus.submitting;

  void onNicknameChanged(String value) {
    _nickname = value.trim();
    _nicknameVersion++;

    if (_nickname == _duplicatedNickname) {
      nicknameStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else {
      nicknameStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }

    snackbarMessage = null;
    notifyListeners();
  }

  void onEmailChanged(String value) {
    _email = value.trim();
    _emailVersion++;

    if (_email == _duplicatedEmail) {
      emailStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailStatus = CheckStatus.idle;
      emailErrorText = null;
    }

    snackbarMessage = null;
    notifyListeners();
  }

  void onPasswordChanged() {
    passwordErrorText = null;
    snackbarMessage = null;
    notifyListeners();
  }

  Future<void> checkNickname(String value) async {
    final requested = value.trim();
    if (!canCheckNickname || requested != _nickname) return;

    final version = ++_nicknameVersion;
    nicknameStatus = CheckStatus.checking;
    nicknameErrorText = null;
    notifyListeners();

    try {
      final available = await _service.checkNickname(requested);
      if (version != _nicknameVersion) return;

      nicknameStatus =
          available ? CheckStatus.available : CheckStatus.duplicated;

      nicknameErrorText =
          available ? null : '이미 사용 중인 닉네임입니다.';

      if (!available) {
        _duplicatedNickname = requested;
      }
    } on DioException {
      if (version != _nicknameVersion) return;

      nicknameStatus = CheckStatus.error;
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    notifyListeners();
  }

  Future<void> checkEmail(String value) async {
    final requested = value.trim();
    if (!canCheckEmail || requested != _email) return;

    final version = ++_emailVersion;
    emailStatus = CheckStatus.checking;
    emailErrorText = null;
    notifyListeners();

    try {
      final available = await _service.checkEmail(requested);
      if (version != _emailVersion) return;

      emailStatus =
          available ? CheckStatus.available : CheckStatus.duplicated;

      emailErrorText =
          available ? null : '이미 사용 중인 이메일입니다.';

      if (!available) {
        _duplicatedEmail = requested;
      }
    } on DioException {
      if (version != _emailVersion) return;

      emailStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    notifyListeners();
  }

  Future<void> submit(CreateMemberRequest request) async {
    if (submitStatus == SubmitStatus.submitting || !canSubmit) {
      return;
    }

    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
    notifyListeners();

    try {
      final response = await _service.signUp(request);
      final id = response.result?.memberId;

      if (!response.isSuccess || id == null) {
        throw StateError('회원가입 결과에 memberId가 없습니다.');
      }

      createdMemberId = id;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      submitStatus = SubmitStatus.error;

      final message = writeSignUpErrorMessage(error);

      if (error.response?.statusCode == 400 &&
          message.contains('비밀번호')) {
        passwordErrorText = message;
      } else {
        snackbarMessage = message;
      }
    } on StateError {
      submitStatus = SubmitStatus.error;
      snackbarMessage =
          '가입 결과를 확인하지 못했습니다. 새 요청 전에 서버 상태를 확인해 주세요.';
    } catch (_) {
      submitStatus = SubmitStatus.error;
      snackbarMessage =
          '회원가입 처리 중 오류가 발생했습니다.';
    }

    notifyListeners();
  }
}
