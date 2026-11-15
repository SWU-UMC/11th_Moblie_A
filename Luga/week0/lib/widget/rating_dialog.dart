import 'package:flutter/material.dart';
import 'movie_rating_input.dart';
import '../theme/app_colors.dart';

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
        } catch(error) {
            if(!mounted) return;
            setState(() {
                _isSubmitting = false;
                _errorText = error is StateError
                    ? error.message
                    : '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.';
            });
        }
    }

    OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 1.5),
    );

    @override
    Widget build(BuildContext context) {
        final hasScore = _score > 0;

        return PopScope(
            canPop: !_isSubmitting,
            child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), // 추가
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                titlePadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                title: const Text(
                    '평점을 남겨주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                content: SizedBox(
                    width: 420,
                    child: SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                Center(
                                    child: MovieRatingInput(
                                        rating: _score.toDouble(),
                                        enabled: !_isSubmitting,
                                        onChanged: (value) => 
                                            setState(() => _score = validateServerScore(value)),
                                    ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                    '코멘트 (선택, 최대 500자)',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                    ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                    controller: _commentController,
                                    maxLines: 4,
                                    maxLength: 500,
                                    enabled: !_isSubmitting,
                                    decoration: InputDecoration(
                                        hintText: '이 영화의 인상적인 장면은...',
                                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                        counterText: '',
                                        filled: true,
                                        fillColor: AppColors.primaryLight,
                                        contentPadding: const EdgeInsets.all(16),
                                        border: _border(AppColors.primaryContainer),
                                        enabledBorder: _border(AppColors.primaryContainer),
                                        disabledBorder: _border(AppColors.primaryContainer),
                                        focusedBorder: _border(AppColors.primaryContainer),
                                    ),
                                ),
                                if(_errorText != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                        _errorText!,
                                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                                    ),
                                ],
                                const SizedBox(height: 24),
                                Row(
                                    children: [
                                        Expanded(
                                            child: FilledButton(
                                                onPressed: _isSubmitting
                                                    ? null
                                                    : () => Navigator.pop(context, false),
                                                style: FilledButton.styleFrom(
                                                    backgroundColor: AppColors.primaryContainer,
                                                    foregroundColor: AppColors.primary,
                                                    disabledBackgroundColor: AppColors.primaryContainer,
                                                    minimumSize: const Size.fromHeight(48),
                                                    shape: const StadiumBorder(),
                                                    textStyle: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w700,
                                                    ),
                                                ),
                                                child: const Text('취소'),
                                            ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                            child: FilledButton(
                                                onPressed: hasScore && !_isSubmitting ? _onConfirm : null,
                                                style: FilledButton.styleFrom(
                                                    backgroundColor: AppColors.primary,
                                                    foregroundColor: Colors.white,
                                                    disabledBackgroundColor: _isSubmitting ? AppColors.primary : AppColors.primary,
                                                    disabledForegroundColor: Colors.white,
                                                    minimumSize: const Size.fromHeight(48),
                                                    shape: const StadiumBorder(),
                                                    textStyle: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w700,
                                                    ),
                                                ),
                                                child: _isSubmitting
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                        ),
                                                    )
                                                    : const Text('확인'),
                                            ),
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}