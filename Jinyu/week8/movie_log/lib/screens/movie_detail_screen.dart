import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../themes/app_colors.dart';
import '../view_models/movie_detail_view_model.dart';
import '../view_models/signup_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 제거되었습니다.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showCreateRatingDialog(BuildContext context) async {
    final viewModel = context.read<MovieDetailViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) {
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }
        },
      ),
    );

    if (!mounted) return;
    if (saved == true) {
      messenger.showSnackBar(
        const SnackBar(content: Text('평점을 등록했습니다.')),
      );
    } else if (viewModel.submitMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(viewModel.submitMessage!)),
      );
    }
  }

  Future<void> _showEditSavedRatingDialog(BuildContext context) async {
    final viewModel = context.read<MovieDetailViewModel>();
    final current = viewModel.savedRating;
    if (current == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        initialScore: current.score,
        initialComment: current.comment,
        onSubmit: (score, comment) => viewModel.updateSavedRating(
          score: score,
          comment: comment,
        ),
      ),
    );

    if (!mounted) return;
    if (saved == true) {
      messenger.showSnackBar(
        const SnackBar(content: Text('평점을 수정했습니다.')),
      );
    } else if (viewModel.submitMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(viewModel.submitMessage!)),
      );
    }
  }

  Future<void> _showDeleteSavedRatingDialog(BuildContext context) async {
    final viewModel = context.read<MovieDetailViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteSessionRatingDialog(
        onConfirm: () => viewModel.deleteSavedRating(),
      ),
    );

    if (!mounted) return;
    if (deleted == true) {
      messenger.showSnackBar(
        const SnackBar(content: Text('평점을 삭제했습니다.')),
      );
    } else if (viewModel.submitMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(viewModel.submitMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieDetailViewModel>();
    final movie = viewModel.movie;
    final savedRating = viewModel.savedRating;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            color: AppColors.violet,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: AppColors.violet,
                  ),
                  label: const Text(
                    '즐겨찾기',
                    style: TextStyle(
                      color: AppColors.violet,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.violet,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: savedRating != null
                      ? () => _showEditSavedRatingDialog(context)
                      : () => _showCreateRatingDialog(context),
                  icon: const Icon(
                    Icons.rate_review_outlined,
                    color: Colors.white,
                  ),
                  label: Text(
                    savedRating != null ? '평점 수정' : '평점 남기기',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 480,
              child: TmdbPosterImage(
                posterPath: movie.posterPath,
                width: double.infinity,
                height: 480,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${movie.releaseDate} · 평점 평균: ${movie.voteAverage}',
                    style: const TextStyle(
                      color: AppColors.gray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.voteAverage / 2,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: AppColors.violet,
                        ),
                        itemCount: 5,
                        itemSize: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${movie.voteAverage}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (savedRating != null) ...[
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '내 평점: ${savedRating.score}점',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: '수정',
                                      onPressed: () =>
                                          _showEditSavedRatingDialog(context),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      tooltip: '삭제',
                                      onPressed: () =>
                                          _showDeleteSavedRatingDialog(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (savedRating.comment != null &&
                                savedRating.comment!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(savedRating.comment!),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    '시놉시스',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    movie.overview,
                    style: const TextStyle(height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteSessionRatingDialog extends StatefulWidget {
  const _DeleteSessionRatingDialog({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DeleteSessionRatingDialog> createState() =>
      _DeleteSessionRatingDialogState();
}

class _DeleteSessionRatingDialogState
    extends State<_DeleteSessionRatingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        title: const Text('평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          MovieLogButton(
            label: '취소',
            onPressed:
                _isDeleting ? null : () => Navigator.pop(context, false),
          ),
          MovieLogButton(
            label: '삭제',
            isLoading: _isDeleting,
            onPressed: _isDeleting ? null : _onConfirm,
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      Navigator.pop(context, false);
    }
  }
}