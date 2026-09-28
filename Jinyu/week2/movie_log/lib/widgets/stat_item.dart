import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  const StatItem({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        //color: colors.surface,
        color: colors.primary.withOpacity(0.04), // 배경색을 연한 보라색으로 변경
        border: Border.all(color: colors.primary.withOpacity(0.3)), // 테두리 색상을 연한 보라색으로 변경
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Text(value, style: textTheme.titleLarge),
          // const SizedBox(height: 4),
          // Text(label),
          // 레이블
          Text(
            label,
            style: textTheme.bodySmall, 
          ),
          
          const SizedBox(height: 4), 
          
          // 값
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: colors.primary, // 보라색
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}