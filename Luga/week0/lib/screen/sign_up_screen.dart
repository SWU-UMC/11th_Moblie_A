import 'package:flutter/material.dart';

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

    // 약관 동의
    bool _agreedToTerms = false;

    @override
    void dispose() {
        _nicknameController.dispose();
        _emailController.dispose();
        _passwordController.dispose();
        _passwordFocusNode.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('회원가입')),
            body: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child:Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                // 닉네임 입력 필드
                                TextFormField(
                                    controller: _nicknameController,
                                    decoration: const InputDecoration(
                                        labelText: '닉네임',
                                        hintText: '2자 이상 입력하세요',
                                    ),
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return '닉네임을 입력해주세요';
                                        }
                                        if (value.trim().length < 2) {
                                            return '닉네임은 2자 이상이어야 합니다';
                                        }
                                        return null;
                                    },
                                    onChanged: (value) {
                                        setState(() {});
                                    },
                                ),

                                const SizedBox(height: 24),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}