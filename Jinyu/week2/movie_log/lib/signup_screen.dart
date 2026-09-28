import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/signup_input.dart';
import 'widgets/terms_agreement.dart';
import 'widgets/signup_submit_button.dart';

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

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // 워크북에 명시된 버튼 활성화 조건 공식
  bool get _canSubmit =>
      _nicknameController.text.trim().length >= 2 &&
      _emailController.text.contains('@') &&
      _passwordController.text.length >= 8 &&
      _agreedToTerms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '회원가입', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 32),

                // 1. 입력창 덩어리 위젯
                SignupInputSection(
                  nicknameController: _nicknameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  emailFocusNode: _emailFocusNode,
                  passwordFocusNode: _passwordFocusNode,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 120),

                // 2. 약관 동의 위젯
                TermsAgreementSection(
                  isAgreed: _agreedToTerms,
                  onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                ),
                const SizedBox(height: 16),

                // 3. 가입 버튼 위젯
                SignupSubmitButton(
                  canSubmit: _canSubmit,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('이미 계정이 있나요? ', style: AppTextStyles.bodyMedium),
                    Text(
                      '로그인',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.violet,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}