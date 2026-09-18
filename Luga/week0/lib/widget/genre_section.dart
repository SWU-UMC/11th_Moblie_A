import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GenreSection extends StatelessWidget {
  const GenreSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text('선호하는 장르', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                    _GenreChip(label: '드라마', textTheme: textTheme),
                    _GenreChip(label: 'SF', textTheme: textTheme),
                    _GenreChip(label: '애니메이션', textTheme: textTheme),
                ],
            ),
        ],
    );
  }
}

class _GenreChip extends StatelessWidget {
    const _GenreChip({required this.label, required this.textTheme});

    final String label;
    final TextTheme textTheme;

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label, style: textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
        );
    }
}