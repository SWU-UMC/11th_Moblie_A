import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/terms_agreement.dart';
import '../widgets/register_submit_button.dart';
import '../widgets/movielog_button.dart';
import '../data/services/sign_up_service.dart';
import '../view_models/signup_view_model.dart';
import '../view_models/learning_member_session.dart'; // 7주차 학습용 세션 임포트
import '../data/models/create_member_request.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignUpViewModel(context.read<SignUpService>()),
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

  // 7주차 서버 통신 회원가입 제출 메서드
  Future<void> _onSubmitPressed(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    final viewModel = context.read<SignUpViewModel>();
    
    // 💡 비동기 작업 전 Context 스코프 오류 방지를 위해 세션을 미리 안전하게 가져옵니다.
    final session = Provider.of<LearningMemberSession>(context, listen: false);
    
    // 서버로 회원가입 요청 전송
    await viewModel.submit(CreateMemberRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nickname: _nicknameController.text.trim(),
    ));

    if (!context.mounted) return;

    // 가입 성공 시 세션에 memberId 저장 후 영화 목록 화면으로 이동
    if (viewModel.submitStatus == SubmitStatus.success &&
        viewModel.createdMemberId != null) {
      session.setMemberId(viewModel.createdMemberId!);
      context.go('/movies');
      return;
    }

    // 서버 에러 메시지가 스낵바용으로 존재할 경우 출력
    if (viewModel.snackbarMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.snackbarMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();

    bool canSubmit = _emailController.text.contains('@') &&
        _passwordController.text.length >= 8 &&
        _agreedToTerms &&
        viewModel.nicknameCheckStatus == CheckStatus.available &&
        viewModel.submitStatus != SubmitStatus.submitting;

    return PopScope(
      canPop: viewModel.submitStatus != SubmitStatus.submitting,
      child: Scaffold(
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
                  
                  // 닉네임 입력 및 중복 확인 섹션
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

                  // 이메일 입력 및 중복 확인 섹션
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

                  // 비밀번호 입력 필드
                  Consumer<SignUpViewModel>(
                    builder: (context, vm, child) {
                      return TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: '비밀번호 (8자 이상)',
                          errorText: vm.passwordErrorText,
                        ),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return '비밀번호는 8자 이상 입력해 주세요.';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          vm.onPasswordChanged();
                          setState(() {});
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  TermsAgreementSection(
                    isAgreed: _agreedToTerms,
                    onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                  ),
                  const SizedBox(height: 16),
                  
                  // 회원가입 제출 버튼
                  Consumer<SignUpViewModel>(
                    builder: (context, vm, child) {
                      return SignupSubmitButton(
                        canSubmit: canSubmit && vm.submitStatus != SubmitStatus.submitting,
                        onPressed: () => _onSubmitPressed(context),
                      );
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
      ),
    );
  }
}