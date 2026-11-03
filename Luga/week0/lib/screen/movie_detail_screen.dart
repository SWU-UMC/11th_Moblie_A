import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../view_model/movie_detail_view_model.dart';
import '../widget/common_app_bar.dart';
import '../widget/error_view.dart';
import '../widget/loading_view.dart';
import '../widget/rating_dialog.dart';
import '../widget/responsive_container.dart';
import '../theme/app_colors.dart';

class MovieDetailScreen extends StatefulWidget {
    const MovieDetailScreen({super.key, required this.movieId});

    final int movieId;

    @override
    State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
    bool _isFavorite = false;

    void _toggleFavorite() {
        setState(() {
            _isFavorite = !_isFavorite;
        });

        // 기존 스낵바를 닫아 레이아웃 및 렌더링 꼬임 방지
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_isFavorite ? '즐겨찾기에 추가했습니다' : '즐겨찾기에서 삭제했습니다'),
                behavior: SnackBarBehavior.floating,
            ),
        );
    }

    Future<void> _openRatingDialog() async {
    final result = await showDialog<RatingResult>(
        context: context,
        builder: (context) => RatingDialog(movieId: widget.movieId),
    );

    if (result != null && mounted) {
        // 이후 단계: 평점 저장 시 result.movieId, result.rating을 그대로 사용
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('평점 ${result.rating}점을 남겼습니다 (movieId: ${result.movieId})'),
                behavior: SnackBarBehavior.floating,
            ),
        );
    }
}

    PreferredSizeWidget _simpleAppBar() {
        return CommonAppBar(
            title: '영화 상세',
            showBackButton: true,
            fallbackLocation: '/movies',
        );
    }

    @override
    Widget build(BuildContext context) {
        final vm = context.watch<MovieDetailViewModel>();

        switch (vm.status) {
            case MovieDetailLoadStatus.idle:
            case MovieDetailLoadStatus.loading:
                return Scaffold(
                    appBar: _simpleAppBar(),
                    body: const LoadingView(),
                );
            case MovieDetailLoadStatus.notFound:
                return Scaffold(
                    appBar: _simpleAppBar(),
                    body: const Center(child: Text('영화를 찾을 수 없습니다')),
                );
            case MovieDetailLoadStatus.error:
                return Scaffold(
                    appBar: _simpleAppBar(),
                    body: ErrorView(
                        onRetry: () => context.read<MovieDetailViewModel>().load(),
                    ),
                );
            case MovieDetailLoadStatus.success:
                return _buildContent(context, vm.movie!);
        }
    }

    Widget _buildContent(BuildContext context, TmdbMovieDto movie) {
        final textTheme = Theme.of(context).textTheme;
        final posterUrl = movie.posterUrl;
        final runtime = movie.runtime;
        final genreNames = movie.genres.map((g) => g.name).toList();
        final overview = movie.overview.trim();
        final date = movie.releaseDate;
        final year = (date == null || date.length < 4) ? '' : date.substring(0, 4);

        const posterPlaceholder = Center(
            child: Icon(Icons.movie_outlined, size: 64, color: AppColors.primary),
        );

        return Scaffold(
            appBar: CommonAppBar(
                title: 'Cinema Archive',
                showBackButton: true,
                fallbackLocation: '/movies',
                actions: [
                    IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {},
                    ),
                ],
            ),
            body: SafeArea(
                child: ResponsiveContainer(
                    child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: Container(
                                        color: AppColors.primaryLight,
                                        child: posterUrl == null
                                            ? posterPlaceholder
                                            : Image.network(
                                                posterUrl,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, progress) =>
                                                    progress == null ? child : posterPlaceholder,
                                                errorBuilder: (context, error, stackTrace) => posterPlaceholder,
                                            ),
                                    ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 40),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                movie.title.isEmpty ? '제목 없음' : movie.title,
                                                style: textTheme.headlineMedium,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                                [
                                                    if (year.isNotEmpty) year,
                                                    if (genreNames.isNotEmpty) genreNames.join('/'),
                                                    if (runtime != null && runtime > 0) '$runtime분',
                                                ].join(' · '),
                                                style: textTheme.bodyMedium,
                                            ),
                                            const SizedBox(height: 12),

                                            // 평점 (읽기 전용): TMDB는 10점 만점이라 5점 만점 별로 환산
                                            Wrap(
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                children: [
                                                    RatingBarIndicator(
                                                        rating: movie.voteAverage / 2,
                                                        itemCount: 5,
                                                        itemSize: 20,
                                                        itemBuilder: (context, index) {
                                                            return const Icon(Icons.star, color: AppColors.primary);
                                                        },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                        movie.voteAverage.toStringAsFixed(1),
                                                        style: textTheme.bodyMedium,
                                                    ),
                                                ],
                                            ),
                                            const SizedBox(height: 16),

                                            // 장르 배지
                                            Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: genreNames.map((tag) {
                                                    return Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                        decoration: BoxDecoration(
                                                            color: AppColors.genreChipBackground,
                                                            borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Text(
                                                            tag,
                                                            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                                                        ),
                                                    );
                                                }).toList(),
                                            ),
                                        ],
                                    ),
                                ),
                                // 구분선
                                const Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    color: AppColors.primary,
                                ),

                                Padding(
                                    padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text('시놉시스', style: textTheme.headlineSmall),
                                            const SizedBox(height: 12),
                                            Text(
                                                overview.isEmpty ? '아직 등록된 줄거리가 없습니다.' : overview,
                                                style: textTheme.bodyMedium,
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
            // ResponsiveContainer 제거하여 하단 영역 레이아웃 제약 오류 해결
            bottomNavigationBar: Container(
                color: AppColors.surfaceLowest,
                child: SafeArea(
                    top: false,
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border(top: BorderSide(color: AppColors.outline)),
                        ),
                        child: Row(
                            children: [
                                Expanded(
                                    child: OutlinedButton(
                                        onPressed: _toggleFavorite,
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: const BorderSide(color: AppColors.primary),
                                            minimumSize: const Size(0, 48),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(24),
                                            ),
                                        ),
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                    Icon(_isFavorite ? Icons.bookmark : Icons.bookmark_border),
                                                    const SizedBox(width: 6),
                                                    const Text('즐겨찾기'),
                                                ],
                                            ),
                                        ),
                                    ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: ElevatedButton(
                                        onPressed: _openRatingDialog,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(0, 48),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(24),
                                            ),
                                        ),
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                    Icon(Icons.edit),
                                                    SizedBox(width: 6),
                                                    Text('평점 남기기'),
                                                ],
                                            ),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}