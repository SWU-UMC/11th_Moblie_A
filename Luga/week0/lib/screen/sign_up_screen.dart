import 'package:flutter/material.dart';
import '../widget/labeled_text_field.dart';
import '../widget/terms_checkbox.dart';
import '../widget/submit_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
    // Step 1: Form 유효성 검사를 위한 global key 생성
    final _formKey = GlobalKey<FormState>();

    // Step 2: 닉네임 controller & 이메일 controller & 비밀번호 controller 생성
    final _nicknameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    // 비밀번호 focus node
    final _passwordFocusNode = FocusNode();
    final _emailFocusNode = FocusNode();
    final _nicknameFocusNode = FocusNode();

    // 약관 동의
    bool _agreedToTerms = false;

    bool get _isFormValid {
        final nicknameValid = _nicknameController.text.trim().length >= 2;
        final emailValid = _isEmailValid(_emailController.text);
        final passwordValid = _passwordController.text.length >= 8;
        return nicknameValid && emailValid && passwordValid && _agreedToTerms;
    }

    bool _isEmailValid(String email) {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        return emailRegex.hasMatch(email);
    }

    void _handleSubmit() {
        final isValid = _formKey.currentState!.validate();
        if(isValid && _agreedToTerms) {
            // 실제 가입 로직은 아직 구현 X
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('가입 요청이 전송되었습니다.')),
            );
        }
    }

    @override
    void dispose() {
        _nicknameController.dispose();
        _emailController.dispose();
        _passwordController.dispose();
        _passwordFocusNode.dispose();
        _emailFocusNode.dispose();
        _nicknameFocusNode.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('회원가입')),
            body: SafeArea(
                child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        left: 24, right: 24, top: 24,
                        // 키보드 올라올 때 화면 가려지지 않도록 함
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child:Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                // 닉네임 입력 필드
                                LabeledTextField(
                                    controller: _nicknameController,
                                    focusNode: _nicknameFocusNode,
                                    nextFocusNode: _emailFocusNode,
                                    labelText: '닉네임',
                                    hintText: '2자 이상 입력하세요',
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return '닉네임을 입력해주세요';
                                        }
                                        if (value.trim().length < 2) {
                                            return '닉네임은 2자 이상이어야 합니다';
                                        }
                                        return null;
                                    },
                                    onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 16),

                                // 이메일 입력 필드
                                LabeledTextField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    nextFocusNode: _passwordFocusNode,
                                    labelText: '이메일',
                                    hintText: 'example@email.com',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                            return '이메일을 입력해주세요';
                                        }
                                        if (!_isEmailValid(value.trim())) {
                                            return '올바른 이메일 형식이 아니에요';
                                        }
                                        return null;
                                    },
                                    onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 16),

                                // 비밀번호 입력 필드
                                LabeledTextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    labelText: '비밀번호',
                                    hintText: '8자 이상 입력하세요',
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
                                    onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 24),

                                TermsCheckbox(
                                    value: _agreedToTerms,
                                    onChanged: (value) {
                                        setState(() {
                                            _agreedToTerms = value ?? false;
                                        });
                                    },
                                ),
                                const SizedBox(height: 24),

                                SubmitButton(
                                    enabled: _isFormValid,
                                    onPressed: _handleSubmit,
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}