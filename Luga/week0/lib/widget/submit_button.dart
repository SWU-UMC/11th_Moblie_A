import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SubmitButton extends StatelessWidget {
    const SubmitButton({
        super.key,
        required this.enabled,
        required this.onPressed,
    });

    final bool enabled;
    final VoidCallback onPressed;

    @override
    Widget build(BuildContext context) {
        return ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
                backgroundColor: enabled ? AppColors.primary : AppColors.outline,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('가입하기'),
        );
    }
}