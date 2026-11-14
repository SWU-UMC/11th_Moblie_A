import 'package:flutter/material.dart';
import 'movie_rating_input.dart';
import '../theme/app_colors.dart';
import 'movie_log_button.dart';

int validateServerScore(double value) => value.round().clamp(1, 5);

class RatingDialog extends StatefulWidget {
    const RatingDialog({
        super.key,
        this.initialScore = 0,
        this.initialComment,
        required this.onSubmit});

        final int initialScore;
        final String? initialComment;
        final Future<void> Function(int score, String?comment) onSubmit;

    @override
    State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
    late int _score = widget.initialScore;
    late final _commentController = TextEditingController(text: widget.initialComment ?? '');
    bool _isSubmitting = false;
    String? _errorText;

    @override
    void dispose() {
        _commentController.dispose();
        super.dispose();
    }

    Future<void> _onConfirm() async {
        final trimmed = _commentController.text.trim();
        if(trimmed.length > 500) {
            setState(() => _errorText = '코멘트는 500자 이하로 입력해 주세요.');
            return;
        }

        setState(() {
            _isSubmitting = true;
            _errorText = null;
        });

        try{
            await widget.onSubmit(_score, trimmed.isEmpty ? null : trimmed);
            if (!mounted) return;
            Navigator.pop(context, true);
        } catch(_) {
            if(!mounted) return;
            setState(() {
                _isSubmitting = false;
                _errorText = '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.';
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        final hasScore = _score > 0;

        return PopScope(
            canPop: !_isSubmitting,
            child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                titlePadding: const EdgeInsets.fromLTRB(30, 28, 30, 0),
                contentPadding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                actionsPadding: const EdgeInsets.fromLTRB(30, 12, 30, 24),
                title: const Text(
                    '영화는 어떠셨나요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                content: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            MovieRatingInput(
                                rating: _score.toDouble(),
                                enabled: !_isSubmitting,
                                onChanged: (value) => setState(() => _score = validateServerScore(value)),
                            ),
                            if(hasScore) ...[
                                const SizedBox(height: 12),
                                TextButton(
                                    onPressed: _isSubmitting ? null : () => setState(() => _score = 0),
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                        '다시 선택하기',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                                    ),
                                ),
                            ],
                            const SizedBox(height: 12),
                            TextField(
                                controller: _commentController,
                                maxLines: 3,
                                maxLength: 500,
                                enabled: !_isSubmitting,
                                decoration: const InputDecoration(hintText: '코멘트를 남겨보세요 (선택)'),
                            ),
                            if(_errorText != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                    _errorText!,
                                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                                ),
                            ],
                        ],
                    ),
                ),

                actions: [
                    MovieLogButton(
                        label: '취소',
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                    ),
                    MovieLogButton(
                        label: '확인',
                        isLoading: _iSubmitting,
                        onPressed: hasScore && !_isSubmitting ? _onConfirm : null,
                    ),
                ],
            ),
        );
    }
}