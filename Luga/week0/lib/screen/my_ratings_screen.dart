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
                Text(
                    '학습용 샘플 회원 (memberId ${viewModel.memberId})의 평점입니다.)',
                    style: textTheme.bodyMedium,
                ),
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
                border: Border.all(color: AppColors.outline),
                borderRadius: BorderRadius.circular(12),
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
                                    movie?.title ?? '영화 정보를 불러오지 못했어요',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleMedium,
                                ),
                                if(movie == null) ...[
                                    const SizedBox(height: 2),
                                    Text('movieId: ${rating.movieId}', style: textTheme.bodyMedium),
                                ],
                                const SizedBox(height: 6),
                                Row(
                                    children: [
                                        const Icon(Icons.star, size: 18, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text('${rating.score}점', style: textTheme.titleMedium),
                                    ],
                                ),
                                if(comment != null && comment.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(comment, style: textTheme.bodyMedium),
                                ],
                            ],
                        ),
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