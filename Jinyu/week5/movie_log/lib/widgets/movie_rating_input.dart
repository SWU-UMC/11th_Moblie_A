import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../themes/app_colors.dart';

class RatingInput extends StatelessWidget {
  const RatingInput({
    super.key,
    required this.initialRating,
    required this.onChanged,
  });

  final double initialRating;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: initialRating,
      minRating: 0.5,
      allowHalfRating: true,
      itemCount: 5,
      itemBuilder: (context, _) => const Icon(Icons.star, color: AppColors.violet),
      onRatingUpdate: onChanged,
    );
  }
}
