import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import 'movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, required this.initialRating});

  final double initialRating;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double tempRating;

  @override
  void initState() {
    super.initState();
    tempRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('영화는 어떠셨나요?', style: TextStyle(fontWeight: FontWeight.bold)),
      content: RatingInput(
        initialRating: tempRating,
        onChanged: (rating) => setState(() => tempRating = rating),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: AppColors.gray)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.violet,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, tempRating),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
