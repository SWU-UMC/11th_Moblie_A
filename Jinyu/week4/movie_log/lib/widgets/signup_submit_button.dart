import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SignupSubmitButton extends StatelessWidget {
  const SignupSubmitButton({
    super.key,
    required this.canSubmit,
    required this.onPressed,
  });

  final bool canSubmit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.violet.withOpacity(0.3),
          disabledForegroundColor: AppColors.white,
          
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('가입하기', style: AppTextStyles.titleMediumW),
      ),
    );
  }
}