import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widget/labeled_text_field.dart';
import '../widget/movie_log_button.dart';
import '../widget/terms_checkbox.dart';
import '../widget/submit_button.dart';
import '../widget/common_app_bar.dart';
import '../theme/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../data/services/member_check_service.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nicknameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;

  CheckStatus _nicknameStatus = CheckStatus.idle;
  CheckStatus _emailStatus = CheckStatus.idle;

  bool get _isNicknameFormatValid => _nicknameController.text.trim().length >= 2;
  bool get _isEmailFormatValid => _isEmailValid(_emailController.text.trim());

  bool get _isFormValid {
    final passwordValid = _passwordController.text.length >= 8;
    return _isNicknameFormatValid &&
        _isEmailFormatValid &&
        passwordValid &&
        _nicknameStatus == CheckStatus.available &&
        _emailStatus == CheckStatus.available &&
        _agreedToTerms;
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<bool> _isNicknameAvailable(String nickname) {
    return context.read<MemberCheckService>().checkNickname(nickname);
  }

  Future<bool> _isEmailAvailable(String email) {
    return context.read<MemberCheckService>().checkEmail(email);
  }

  Future<void> _checkNickname() async {
    final nickname = _nicknameController.text.trim();
    setState(() => _nicknameStatus = CheckStatus.checking);
    try {
      final available = await _isNicknameAvailable(nickname);
      // 확인 중 입력이 바뀌었거나 화면이 닫혔으면 결과 무시
      if (!mounted || nickname != _nicknameController.text.trim()) return;
      setState(() => _nicknameStatus =
          available ? CheckStatus.available : CheckStatus.duplicated);
    } catch (_) {
      if (!mounted || nickname != _nicknameController.text.trim()) return;
      setState(() => _nicknameStatus = CheckStatus.error);
    }
  }

  Future<void> _checkEmail() async {
    final email = _emailController.text.trim();
    setState(() => _emailStatus = CheckStatus.checking);
    try {
      final available = await _isEmailAvailable(email);
      if (!mounted || email != _emailController.text.trim()) return;
      setState(() =>
          _emailStatus = available ? CheckStatus.available : CheckStatus.duplicated);
    } catch (_) {
      if (!mounted || email != _emailController.text.trim()) return;
      setState(() => _emailStatus = CheckStatus.error);
    }
  }

  // 상태별 안내 문구/색상
  (String?, Color?) _message(CheckStatus status, String target) {
    return switch (status) {
      CheckStatus.idle => (null, null),
      CheckStatus.checking => ('$target 사용 가능 여부를 확인 중입니다.', const Color(0xFF1565C0)),
      CheckStatus.available => ('사용 가능한 $target입니다.', const Color(0xFF2E7D32)),
      CheckStatus.duplicated => ('이미 사용 중인 $target입니다.', AppColors.error),
      CheckStatus.error => ('확인하지 못했어요. 다시 시도해 주세요.', AppColors.error),
    };
  }

  void _handleSubmit() {
    final isValid = _formKey.currentState!.validate();
    if (isValid && _isFormValid) {
      // 실제 가입 요청은 이번 주차 범위가 아니므로 홈으로만 이동
      context.pushReplacement('/home');
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (nicknameMsg, nicknameColor) = _message(_nicknameStatus, '닉네임');
    final (emailMsg, emailColor) = _message(_emailStatus, '이메일');

    return Scaffold(
      appBar: const CommonAppBar(title: '회원가입', showBackButton: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxFormWidth = constraints.maxWidth >= 700 ? 560.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 24),
                              Text(
                                '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 32),

                              // 닉네임 + 중복 확인
                              LabeledTextField(
                                controller: _nicknameController,
                                focusNode: _nicknameFocusNode,
                                nextFocusNode: _emailFocusNode,
                                labelText: '닉네임',
                                hintText: '닉네임을 입력해주세요',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '닉네임을 입력해주세요';
                                  }
                                  if (value.trim().length < 2) {
                                    return '닉네임은 2자 이상이어야 합니다';
                                  }
                                  return null;
                                },
                                showValidIcon: _nicknameStatus == CheckStatus.available,
                                helperText: nicknameMsg,
                                helperColor: nicknameColor,
                                trailing: MovieLogButton(
                                  label: '중복 확인',
                                  isLoading: _nicknameStatus == CheckStatus.checking,
                                  onPressed: _isNicknameFormatValid ? _checkNickname : null,
                                ),
                                onChanged: (_) => setState(() {
                                  _nicknameStatus = CheckStatus.idle; // 입력이 바뀌면 재확인 필요
                                }),
                              ),
                              const SizedBox(height: 20),

                              // 이메일 + 중복 확인
                              LabeledTextField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                nextFocusNode: _passwordFocusNode,
                                labelText: '이메일',
                                hintText: '이메일 주소를 입력해주세요',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '이메일을 입력해주세요';
                                  }
                                  if (!_isEmailValid(value.trim())) {
                                    return '올바른 이메일 형식이 아닙니다';
                                  }
                                  return null;
                                },
                                showValidIcon: _emailStatus == CheckStatus.available,
                                helperText: emailMsg,
                                helperColor: emailColor,
                                trailing: MovieLogButton(
                                  label: '중복 확인',
                                  isLoading: _emailStatus == CheckStatus.checking,
                                  onPressed: _isEmailFormatValid ? _checkEmail : null,
                                ),
                                onChanged: (_) => setState(() {
                                  _emailStatus = CheckStatus.idle;
                                }),
                              ),
                              const SizedBox(height: 20),

                              // 비밀번호
                              LabeledTextField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                labelText: '비밀번호',
                                hintText: '비밀번호를 입력해주세요',
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '비밀번호를 입력해주세요';
                                  }
                                  if (value.length < 8) {
                                    return '비밀번호는 8자 이상이어야 합니다';
                                  }
                                  return null;
                                },
                                showValidIcon: false,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),

                      // 하단 고정 영역
                      Padding(
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 8,
                          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TermsCheckbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() => _agreedToTerms = value ?? false);
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: SubmitButton(
                                enabled: _isFormValid,
                                onPressed: _handleSubmit,
                              ),
                            ),
                            const SizedBox(height: 24),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: textTheme.bodyMedium,
                                children: [
                                  const TextSpan(text: '이미 계정이 있나요?\u00A0'),
                                  TextSpan(
                                    text: '로그인',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}