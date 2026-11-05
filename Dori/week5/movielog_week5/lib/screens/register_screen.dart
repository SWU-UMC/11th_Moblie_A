
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
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
                          onChanged: vm.onNicknameChanged,
                          decoration: InputDecoration(
                            hintText: '닉네임 입력',
                            border: const OutlineInputBorder(),
                            errorText: vm.nicknameErrorText,
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return '닉네임을 입력해 주세요.';
                            if (text.length < 2) {
                              return '닉네임은 2글자 이상이어야 합니다.';
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
                          keyboardType: TextInputType.emailAddress,
                          onChanged: vm.onEmailChanged,
                          decoration: InputDecoration(
                            hintText: '이메일 입력',
                            border: const OutlineInputBorder(),
                            errorText: vm.emailErrorText,
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return '이메일을 입력해 주세요.';
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
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: '비밀번호 입력',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return '비밀번호는 8자 이상 입력해 주세요.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),
                  MovieLogButton(
                    label: '가입하기',
                    width: double.infinity,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      if (vm.nicknameStatus != CheckStatus.available ||
                          vm.emailStatus != CheckStatus.available) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('닉네임과 이메일 중복 확인을 완료해 주세요.'),
                          ),
                        );
                        return;
                      }

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MovieListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
