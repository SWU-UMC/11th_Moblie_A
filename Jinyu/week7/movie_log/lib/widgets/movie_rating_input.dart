import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../themes/app_colors.dart';

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.enabled = true,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1, // 최소 1점부터
      allowHalfRating: false, // 반 점 단위 허용 안 함 (정수만 선택)
      ignoreGestures: !enabled, // 비활성화 상태 처리
      itemCount: 5,
      itemSize: 40,
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: AppColors.violet,
      ),
      onRatingUpdate: onChanged,
    );
  }
}