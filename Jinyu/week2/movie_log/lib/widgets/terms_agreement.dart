import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TermsAgreementSection extends StatelessWidget {
  const TermsAgreementSection({
    super.key,
    required this.isAgreed,
    required this.onChanged,
  });

  final bool isAgreed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isAgreed,
          onChanged: onChanged,
          activeColor: AppColors.violet,
        ),
        const Expanded(
          child: Text(
            '필수 약관에 동의합니다.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}