
import 'package:flutter/material.dart';

class RatingInput {
  const RatingInput({
    required this.score,
    required this.comment,
  });

  final int score;
  final String? comment;
}

class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    required this.title,
    required this.onSubmit,
    this.initialScore = 5,
    this.initialComment,
  });

  final String title;
  final int initialScore;
  final String? initialComment;
  final Future<void> Function(RatingInput input) onSubmit;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late int _score;
  late final TextEditingController _commentController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _score = widget.initialScore;
    _commentController = TextEditingController(
      text: widget.initialComment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final comment = _commentController.text.trim();

      await widget.onSubmit(
        RatingInput(
          score: _score,
          comment: comment.isEmpty ? null : comment,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(widget.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('별점'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 2,
                children: List.generate(5, (index) {
                  final value = index + 1;

                  return IconButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() => _score = value),
                    icon: Icon(
                      value <= _score
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              Text('$_score / 5점'),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                enabled: !_saving,
                maxLength: 500,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '감상평',
                  hintText: '영화에 대한 감상을 남겨 주세요.',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('저장'),
          ),
        ],
      ),
    );
  }
}
