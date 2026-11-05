import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../data/services/member_check_service.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);

  final MemberCheckService _service;

  CheckStatus nicknameStatus = CheckStatus.idle;
  CheckStatus emailStatus = CheckStatus.idle;

  String? nicknameErrorText;
  String? emailErrorText;

  String _nickname = '';
  String _email = '';

  String? _duplicatedNickname;
  String? _duplicatedEmail;

  int _nicknameVersion = 0;
  int _emailVersion = 0;

  bool get canCheckNickname =>
      _nickname.isNotEmpty &&
      nicknameStatus != CheckStatus.checking &&
      nicknameStatus != CheckStatus.duplicated;

  bool get canCheckEmail =>
      _email.isNotEmpty &&
      emailStatus != CheckStatus.checking &&
      emailStatus != CheckStatus.duplicated;

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

      if (!available) _duplicatedNickname = requested;
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

      if (!available) _duplicatedEmail = requested;
    } on DioException {
      if (version != _emailVersion) return;

      emailStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    notifyListeners();
  }
}