import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ErrorView extends StatelessWidget {
    const ErrorView({super.key, required this.onRetry});

    final VoidCallback onRetry;

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;

        return Center(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                            '영화 목록을 불러오지 못했어요. \n네트워크를 확인하고 다시 시도해 주세요.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: onRetry,
                            child: const Text('다시 시도'),
                        ),
                    ],
                ),
            ),
        );
    }
}