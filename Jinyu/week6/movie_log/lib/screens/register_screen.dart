import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 패키지 임포트 필수
import 'package:go_router/go_router.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/terms_agreement.dart';
import '../widgets/register_submit_button.dart';
import '../widgets/movielog_button.dart'; // MovieLogButton 임포트 확인
import '../data/services/member_check_service.dart'; // 서비스 임포트 확인
import '../view_models/signup_view_model.dart'; // 뷰모델 임포트 확인

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel
    return ChangeNotifierProvider(
      create: (context) => SignUpViewModel(context.read<MemberCheckService>()),
      child: const _SignUpScreenView(),
    );
  }
}

class _SignUpScreenView extends StatefulWidget {
  const _SignUpScreenView();

  @override
  State<_SignUpScreenView> createState() => _SignUpScreenViewState();
}

class _SignUpScreenViewState extends State<_SignUpScreenView> {
  final _formKey = GlobalKey<FormState>();

  // 입력 컨트롤러
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();

    // ViewModel의 상태를 활용해 전체 제출 가능 여부 판단
    bool canSubmit = _emailController.text.contains('@') &&
        _passwordController.text.length >= 8 &&
        _agreedToTerms &&
        viewModel.nicknameCheckStatus == CheckStatus.available; // 닉네임 중복확인 완료 조건 추가

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
                
                // Consumer 코드
                Consumer<SignUpViewModel>(
                  builder: (context, vm, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nicknameController,
                                decoration: InputDecoration(
                                  labelText: '닉네임',
                                  errorText: vm.nicknameErrorText,
                                ),
                                validator: (value) {
                                  final nickname = value?.trim() ?? '';
                                  if (nickname.isEmpty) return '닉네임을 입력해 주세요.';
                                  if (nickname.length < 2) return '닉네임은 두 글자 이상 입력해 주세요.';
                                  return null;
                                },
                                onChanged: vm.onNicknameChanged,
                              ),
                            ),
                            const SizedBox(width: 8),
                            MovieLogButton(
                              label: '중복 확인',
                              isLoading: vm.nicknameCheckStatus == CheckStatus.checking,
                              onPressed: vm.canCheckNickname
                                  ? () => vm.checkNickname(_nicknameController.text)
                                  : null,
                            ),
                          ],
                        ),
                        if (vm.nicknameCheckStatus == CheckStatus.available)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text('사용할 수 있는 닉네임입니다.', style: AppTextStyles.bodySmall),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 이메일 입력 및 중복 확인 섹션 (닉네임과 대칭형태로 추가)
                Consumer<SignUpViewModel>(
                  builder: (context, vm, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: '이메일',
                                  errorText: vm.emailErrorText,
                                ),
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty) return '이메일을 입력해 주세요.';
                                  if (!email.contains('@')) return '올바른 이메일 형식이 아닙니다.';
                                  return null;
                                },
                                onChanged: vm.onEmailChanged,
                              ),
                            ),
                            const SizedBox(width: 8),
                            MovieLogButton(
                              label: '중복 확인',
                              isLoading: vm.emailCheckStatus == CheckStatus.checking,
                              onPressed: vm.canCheckEmail
                                  ? () => vm.checkEmail(_emailController.text)
                                  : null,
                            ),
                          ],
                        ),
                        if (vm.emailCheckStatus == CheckStatus.available)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text('사용할 수 있는 이메일입니다.', style: AppTextStyles.bodySmall),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 비밀번호 입력 필드 (필요시 기존 폼 구조 유지)
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호 (8자 이상)',
                  ),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return '비밀번호는 8자 이상 입력해 주세요.';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                
                const SizedBox(height: 40),
                TermsAgreementSection(
                  isAgreed: _agreedToTerms,
                  onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                ),
                const SizedBox(height: 16),
                SignupSubmitButton(
                  canSubmit: canSubmit,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      FocusScope.of(context).unfocus();
                      context.go('/home');
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