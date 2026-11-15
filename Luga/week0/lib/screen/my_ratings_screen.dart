import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../view_model/my_ratings_view_model.dart';
import '../widget/common_app_bar.dart';
import '../widget/empty_view.dart';
import '../widget/error_view.dart';
import '../widget/loading_view.dart';
import '../widget/responsive_container.dart';
import '../widget/rating_dialog.dart';

class MyRatingsScreen extends StatelessWidget {
    const MyRatingsScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: const CommonAppBar(
                title: '내가 등록한 평점',
                showBackButton: true,
                centerTitle: true,
                fallbackLocation: '/my',
            ),
            body: SafeArea(
                child: ResponsiveContainer(
                    child: Consumer<MyRatingsViewModel>(
                        builder: (context, viewModel, child) {
                            return switch (viewModel.status) {
                                MyRatingsLoadStatus.idle || MyRatingsLoadStatus.loading => const LoadingView(),
                                MyRatingsLoadStatus.error => ErrorView(
                                    message: viewModel.message,
                                    onRetry: () => context.read<MyRatingsViewModel>().load(),
                                    ),
                                MyRatingsLoadStatus.empty => EmptyView(
                                    message: '아직 등록한 평점이 없어요.',
                                    actionLabel: '새로고침',
                                    onAction: () => context.read<MyRatingsViewModel>().load(),
                                ),
                                MyRatingsLoadStatus.success => _RatingList(viewModel: viewModel),
                            };
                        },
                    ),
                ),
            ),
        );
    }
}

class _RatingList extends StatelessWidget {
    const _RatingList({required this.viewModel});

    final MyRatingsViewModel viewModel;

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        final notice = viewModel.message;

        return ListView(
            padding: const EdgeInsets.all(24),
            children: [
                if (notice != null) ...[
                    const SizedBox(height: 8),
                    Text(notice,
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.error)),
                ],
                const SizedBox(height: 16),
                for (final entry in viewModel.ratings) ...[
                    _RatingTile(entry: entry),
                    const SizedBox(height: 16),
                ],
            ],
        );
    }
}

class _RatingTile extends StatelessWidget {
    const _RatingTile({required this.entry});

    final RatingWithMovie entry;

    static const _imageBase = 'https://image.tmdb.org/t/p/w185';

    Future<void> _edit(BuildContext context) async {
        final viewModel = context.read<MyRatingsViewModel>();
        final rating = entry.rating;

        final saved = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) => RatingDialog(
                initialScore: rating.score,
                initialComment: rating.comment,
                onSubmit: (score, comment) => viewModel.updateRating(
                    ratingId: rating.ratingId,
                    score: score,
                    comment: comment,
                ),
            ),
        );

        if (saved == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('평점을 수정했습니다.')),
            );
        }
    }

    Future<void> _delete(BuildContext context) async {
        final viewModel = context.read<MyRatingsViewModel>();

        final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                title: const Text('평점을 삭제할까요?'),
                content: const Text('삭제한 평점은 되돌릴 수 없습니다.'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('취소'),
                    ),
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('삭제', style: TextStyle(color: AppColors.error)),
                    ),
                ],
            ),
        );
        if(confirmed != true) return;
        
        try{
            await viewModel.deleteRating(entry.rating.ratingId);
        } catch(_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(viewModel.message ?? '삭제하지 못했습니다.')),
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        final movie = entry.movie;
        final rating = entry.rating;
        final comment = rating.comment;
        final posterPath = movie?.posterPath;

        return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.surfaceLowest,
                border: Border.all(color: AppColors.primaryContainer, width: 1.5),
                borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                            width: 64,
                            height: 96,
                            child: posterPath == null
                                ? const _PosterPlaceholder()
                                : Image.network(
                                    '$_imageBase$posterPath',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const _PosterPlaceholder(),
                                ),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    movie?.title ?? '영화 #${rating.movieId}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                    ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                    '별점 ${rating.score} / 5',
                                    style: textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                                ),
                                if(comment != null && comment.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                        comment,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                    ),
                                ],
                            ],
                        ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                        children: [
                            _ActionButton(
                                label: '수정',
                                background: AppColors.primaryContainer,
                                foreground: AppColors.primary,
                                onPressed: () => _edit(context),
                            ),
                            const SizedBox(height: 8),
                            _ActionButton(
                                label: '삭제',
                                background: AppColors.errorBackground.withValues(alpha: 0.5),
                                foreground: AppColors.error,
                                onPressed: () => _delete(context),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }
}

class _PosterPlaceholder extends StatelessWidget {
    const _PosterPlaceholder();

    @override
    Widget build(BuildContext context) {
        return Container(
            color: AppColors.primaryLight,
            child: const Center(
                child: Icon(Icons.movie_outlined, size: 28, color: AppColors.primary),
            ),
        );
    }
}

class _ActionButton extends StatelessWidget {
    const _ActionButton({
        required this.label,
        required this.background,
        required this.foreground,
        required this.onPressed,
    });

    final String label;
    final Color background;
    final Color foreground;
    final VoidCallback onPressed;

    @override
    Widget build(BuildContext context) {
        return SizedBox(
            width: 56,
            height: 36,
            child: TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                    backgroundColor: background,
                    foregroundColor: foreground,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                child: Text(label),
            ),
        );
    }
}