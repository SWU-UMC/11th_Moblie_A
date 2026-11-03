import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingView extends StatelessWidget {
    const LoadingView({super.key});

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;

        return Center(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text('영화 목록을 불러오는 중이에요...', style: textTheme.bodyMedium),
                ],
            ),
        );
    }
}