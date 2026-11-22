import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class SignupInputSection extends StatelessWidget {
  const SignupInputSection({
    super.key,
    required this.nicknameController,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.onChanged,
  });

  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final VoidCallback onChanged;

  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputAction? textInputAction,
    VoidCallback? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleMediumB),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onChanged: (_) => onChanged(),
          onFieldSubmitted: (_) => onSubmitted?.call(),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
            filled: true,
            fillColor: (controller.text.isNotEmpty && validator(controller.text) != null)
                ? Colors.red.shade50
                : AppColors.gray.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            helperText: ' ',
            helperStyle: const TextStyle(height: 0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const SizedBox(height: 24);
    return Column(
      children: [
        _buildInput(
          label: '닉네임',
          hint: '닉네임을 입력해주세요',
          controller: nicknameController,
          textInputAction: TextInputAction.next,
          onSubmitted: () => emailFocusNode.requestFocus(),
          validator: (v) {
            final text = v?.trim() ?? '';
            if (text.isEmpty) return '닉네임을 입력해주세요.';
            if (text.length < 2) return '닉네임은 2자 이상이어야 합니다.';
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildInput(
          label: '이메일',
          hint: '이메일 주소를 입력해주세요',
          controller: emailController,
          focusNode: emailFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: () => passwordFocusNode.requestFocus(),
          validator: (v) {
            final text = v?.trim() ?? '';
            if (text.isEmpty) return '이메일을 입력해주세요.';
            if (!text.contains('@')) return '올바른 이메일 형식이 아닙니다.';
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildInput(
          label: '비밀번호',
          hint: '비밀번호를 입력해주세요',
          controller: passwordController,
          focusNode: passwordFocusNode,
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: (v) {
            final text = v ?? '';
            if (text.isEmpty) return '비밀번호를 입력해주세요.';
            if (text.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
            return null;
          },
        ),
      ],
    );
  }
}
