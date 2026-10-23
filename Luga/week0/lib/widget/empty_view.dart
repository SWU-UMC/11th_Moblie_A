import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EmptyView extends StatelessWidget {
    const EmptyView({
        super.key,
        required this.message,
        this.actionLabel,
        this.onAction,
    });

    final String message;
    final String? actionLabel;
    final VoidCallback? onAction;

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    mainAxisSize: MainAxisSixe.min,
                    children: [
                        const Icon(Icons.movie_outlined, size: 48, color: AppColors.primary),
                        const SizedBox(height: 12),
                        Text(message, textAlign: TextAlign.center, style: textTheme.bodyMedium),
                        if (onAction != null) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: onAction, child: Text(actionLabel ?? '확인')),
                        ],
                    ],
                ),
            ),
        );
    }
}