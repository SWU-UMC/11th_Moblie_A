import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  bool _obscurePassword = true;

  bool get _isNicknameValid =>
      _nicknameController.text.trim().length >= 2;

  bool get _isEmailValid {
    final email = _emailController.text.trim();

    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  bool get _isPasswordValid =>
      _passwordController.text.length >= 8;

  bool get _canSubmit =>
      _isNicknameValid &&
      _isEmailValid &&
      _isPasswordValid &&
      _agreedToTerms;

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

  void _onChanged(String value) {
    setState(() {});
  }

  void _submit() {
  final isValid =
      _formKey.currentState?.validate() ?? false;

  if (!isValid) return;

  FocusScope.of(context).unfocus();

  context.go('/home');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 560 : double.infinity,
                ),

                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 32 : 24,
                    vertical: 16,
                  ),

                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                      children: [
                        // ─────────────
                        // 상단
                        // ─────────────

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text(
                              '회원가입',
                              style: TextStyle(
                                color: Color(0xFF6750A4),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.maybePop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 21,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: isWide ? 38 : 28,
                        ),

                        const Text(
                          '환영합니다!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C3C3C),
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          '간단한 정보만 입력하고 시작해보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF777777),
                          ),
                        ),

                        const SizedBox(height: 34),

                        // ─────────────
                        // 닉네임
                        // ─────────────

                        MovieLogTextFormField(
                          label: '닉네임',
                          hint: '닉네임을 입력해주세요',
                          controller: _nicknameController,
                          focusNode: _nicknameFocusNode,
                          isValid: _isNicknameValid,
                          textInputAction:
                              TextInputAction.next,
                          onChanged: _onChanged,

                          validator: (value) {
                            final nickname =
                                value?.trim() ?? '';

                            if (nickname.isEmpty) {
                              return '닉네임을 입력해주세요.';
                            }

                            if (nickname.length < 2) {
                              return '닉네임은 2자 이상이어야 합니다.';
                            }

                            return null;
                          },

                          onFieldSubmitted: (_) {
                            _emailFocusNode.requestFocus();
                          },
                        ),

                        const SizedBox(height: 17),

                        // ─────────────
                        // 이메일
                        // ─────────────

                        MovieLogTextFormField(
                          label: '이메일',
                          hint: '이메일 주소를 입력해주세요',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          isValid: _isEmailValid,
                          keyboardType:
                              TextInputType.emailAddress,
                          textInputAction:
                              TextInputAction.next,
                          onChanged: _onChanged,

                          validator: (value) {
                            final email =
                                value?.trim() ?? '';

                            if (email.isEmpty) {
                              return '이메일을 입력해주세요.';
                            }

                            final regex = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );

                            if (!regex.hasMatch(email)) {
                              return '올바른 이메일 형식이 아닙니다.';
                            }

                            return null;
                          },

                          onFieldSubmitted: (_) {
                            _passwordFocusNode
                                .requestFocus();
                          },
                        ),

                        const SizedBox(height: 17),

                        // ─────────────
                        // 비밀번호
                        // ─────────────

                        MovieLogTextFormField(
                          label: '비밀번호',
                          hint: '비밀번호를 입력해주세요',
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          isValid: _isPasswordValid,
                          obscureText: _obscurePassword,
                          textInputAction:
                              TextInputAction.done,
                          onChanged: _onChanged,

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },

                            icon: Icon(
                              _obscurePassword
                                  ? Icons
                                      .visibility_off_outlined
                                  : Icons
                                      .visibility_outlined,
                              size: 19,
                              color:
                                  const Color(0xFF777777),
                            ),
                          ),

                          validator: (value) {
                            final password = value ?? '';

                            if (password.isEmpty) {
                              return '비밀번호를 입력해주세요.';
                            }

                            if (password.length < 8) {
                              return '비밀번호는 8자 이상이어야 합니다.';
                            }

                            return null;
                          },

                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .unfocus();
                          },
                        ),

                        SizedBox(
                          height: isWide ? 30 : 120,
                        ),

                        // ─────────────
                        // 약관
                        // ─────────────

                        TermsAgreement(
                          value: _agreedToTerms,

                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms =
                                  value ?? false;
                            });
                          },
                        ),

                        const SizedBox(height: 18),

                        // ─────────────
                        // 가입 버튼
                        // ─────────────

                        SizedBox(
                          height: 50,

                          child: ElevatedButton(
                            onPressed:
                                _canSubmit ? _submit : null,

                            style: ElevatedButton.styleFrom(
                              elevation: 0,

                              backgroundColor:
                                  const Color(0xFF6750A4),

                              foregroundColor:
                                  Colors.white,

                              disabledBackgroundColor:
                                  const Color(0xFFD1C3E2),

                              disabledForegroundColor:
                                  Colors.white,

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                            ),

                            child: const Text(
                              '가입하기',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // ─────────────
                        // 로그인
                        // ─────────────

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Text(
                              '이미 계정이 있나요? ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF777777),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {},

                              child: const Text(
                                '로그인',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Color(0xFF6750A4),
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
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

// ─────────────────────────────
// 공통 입력창
// ─────────────────────────────

class MovieLogTextFormField extends StatelessWidget {
  const MovieLogTextFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.onChanged,
    required this.onFieldSubmitted,
    required this.textInputAction,
    required this.isValid,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final String hint;

  final TextEditingController controller;
  final FocusNode focusNode;

  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onFieldSubmitted;

  final TextInputAction textInputAction;
  final TextInputType? keyboardType;

  final bool obscureText;
  final bool isValid;

  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          focusNode: focusNode,

          keyboardType: keyboardType,
          textInputAction: textInputAction,

          obscureText: obscureText,

          autovalidateMode:
              AutovalidateMode.onUserInteraction,

          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,

          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF333333),
          ),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),

            // 비밀번호는 눈 아이콘,
            // 나머지는 정상 입력 시 체크 아이콘
            suffixIcon: suffixIcon ??
                (isValid
                    ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF6750A4),
                        size: 19,
                      )
                    : null),

            filled: true,
            fillColor:
                const Color(0xFFFAF9F5),

            isDense: true,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(5),
              borderSide: const BorderSide(
                color: Color(0xFFD7D4D0),
                width: 1,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(5),
              borderSide: const BorderSide(
                color: Color(0xFF6750A4),
                width: 1.3,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(5),
              borderSide: const BorderSide(
                color: Color(0xFFE25C55),
                width: 1.2,
              ),
            ),

            focusedErrorBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(5),
              borderSide: const BorderSide(
                color: Color(0xFFE25C55),
                width: 1.3,
              ),
            ),

            errorStyle: const TextStyle(
              color: Color(0xFFE25C55),
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────
// 약관
// ─────────────────────────────

class TermsAgreement extends StatelessWidget {
  const TermsAgreement({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,

          child: Checkbox(
            value: value,
            onChanged: onChanged,

            activeColor:
                const Color(0xFF6750A4),

            side: const BorderSide(
              color: Color(0xFFB8B8B8),
            ),
          ),
        ),

        const SizedBox(width: 8),

        const Text(
          '필수 약관에 동의합니다',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF444444),
          ),
        ),
      ],
    );
  }
}