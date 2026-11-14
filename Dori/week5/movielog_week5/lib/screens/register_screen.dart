
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/create_member_request.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/movielog_button.dart';
import 'movie_list_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(SignUpViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    if (!vm.canSubmit) return;

    await vm.submit(
      CreateMemberRequest(
        nickname: _nicknameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );

    if (!mounted) return;

    if (vm.submitStatus == SubmitStatus.success &&
        vm.createdMemberId != null) {
      context
          .read<LearningMemberSession>()
          .setMemberId(vm.createdMemberId!);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MovieListScreen(),
        ),
      );
      return;
    }

    if (vm.snackbarMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.snackbarMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpViewModel>(
      builder: (context, vm, child) {
        final isSubmitting =
            vm.submitStatus == SubmitStatus.submitting;

        return PopScope(
          canPop: !isSubmitting,
          child: Scaffold(
            appBar: AppBar(title: const Text('회원가입')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'MovieLog 시작하기',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text('닉네임'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nicknameController,
                            enabled: !isSubmitting,
                            onChanged: vm.onNicknameChanged,
                            decoration: InputDecoration(
                              hintText: '닉네임 입력',
                              border: const OutlineInputBorder(),
                              errorText: vm.nicknameErrorText,
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return '닉네임을 입력해 주세요.';
                              }
                              if (text.length < 2 || text.length > 12) {
                                return '닉네임은 2~12자로 입력해 주세요.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        MovieLogButton(
                          label: '중복 확인',
                          isLoading:
                              vm.nicknameStatus == CheckStatus.checking,
                          onPressed: vm.canCheckNickname
                              ? () => vm.checkNickname(
                                    _nicknameController.text,
                                  )
                              : null,
                        ),
                      ],
                    ),
                    if (vm.nicknameStatus == CheckStatus.available)
                      const Text(
                        '사용할 수 있는 닉네임입니다.',
                        style: TextStyle(color: Colors.green),
                      ),

                    const SizedBox(height: 24),
                    const Text('이메일'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            enabled: !isSubmitting,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: vm.onEmailChanged,
                            decoration: InputDecoration(
                              hintText: '이메일 입력',
                              border: const OutlineInputBorder(),
                              errorText: vm.emailErrorText,
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return '이메일을 입력해 주세요.';
                              }
                              if (!RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(text)) {
                                return '올바른 이메일을 입력해 주세요.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        MovieLogButton(
                          label: '중복 확인',
                          isLoading:
                              vm.emailStatus == CheckStatus.checking,
                          onPressed: vm.canCheckEmail
                              ? () => vm.checkEmail(
                                    _emailController.text,
                                  )
                              : null,
                        ),
                      ],
                    ),
                    if (vm.emailStatus == CheckStatus.available)
                      const Text(
                        '사용할 수 있는 이메일입니다.',
                        style: TextStyle(color: Colors.green),
                      ),

                    const SizedBox(height: 24),
                    const Text('비밀번호'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !isSubmitting,
                      obscureText: true,
                      onChanged: (_) => vm.onPasswordChanged(),
                      decoration: InputDecoration(
                        hintText: '비밀번호 입력',
                        border: const OutlineInputBorder(),
                        errorText: vm.passwordErrorText,
                      ),
                      validator: (value) {
                        final password = value ?? '';

                        if (password.length < 8 ||
                            !RegExp(r'[a-z]').hasMatch(password) ||
                            !RegExp(r'[A-Z]').hasMatch(password) ||
                            !RegExp(r'[0-9]').hasMatch(password) ||
                            !RegExp(r'[!@#$%^&*]').hasMatch(password)) {
                          return '대문자·소문자·숫자·특수문자를 포함해 8자 이상 입력해 주세요.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
                    MovieLogButton(
                      label: '가입하기',
                      width: double.infinity,
                      isLoading: isSubmitting,
                      onPressed: vm.canSubmit
                          ? () => _submit(vm)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
