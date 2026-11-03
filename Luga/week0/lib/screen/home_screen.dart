import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../view_model/movie_home_view_model.dart';
import '../widget/empty_view.dart';
import '../widget/error_view.dart';
import '../widget/loading_view.dart';
import '../widget/movie_card.dart';
import '../widget/responsive_container.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
            body: SafeArea(
                child: ResponsiveContainer(
                    child: Column(
                        children: [
                            // 헤더는 상태와 무관하게 항상 표시
                            Padding(
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text(
                                            'MovieLog',
                                            style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
                                        ),
                                        GestureDetector(
                                            onTap: () {},
                                            child: const Icon(Icons.search),
                                        ),
                                    ],
                                ),
                            ),
                            Expanded(
                                child: Consumer<MovieHomeViewModel>(
                                    builder: (context, vm, _) {
                                        return switch (vm.status) {
                                            MovieHomeLoadStatus.idle ||
                                            MovieHomeLoadStatus.loading => const LoadingView(),
                                            MovieHomeLoadStatus.error => ErrorView(
                                                onRetry: () => context.read<MovieHomeViewModel>().loadPopular(),
                                            ),
                                            MovieHomeLoadStatus.empty => EmptyView(
                                                message: '인기 영화가 아직 없어요.',
                                                actionLabel: '새로고침',
                                                onAction: () => context.read<MovieHomeViewModel>().loadPopular(),
                                            ),
                                            MovieHomeLoadStatus.success => _HomeContent(
                                                movies: vm.popularMovies,
                                            ),
                                        };
                                    },
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}

class _HomeContent extends StatelessWidget {
    const _HomeContent({required this.movies});

    final List<TmdbMovieDto> movies; // 최대 5개 (1개만 와도 안전)

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        final featured = movies.first; // success 상태에서는 비어 있지 않음
        final others = movies.skip(1).toList();

        return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text('오늘은 어떤\n영화를 볼까요?', style: textTheme.headlineSmall),
                    const SizedBox(height: 20),
                    _FeaturedCard(movie: featured),
                    const SizedBox(height: 32),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text('인기 영화', style: textTheme.titleMedium),
                            TextButton(
                                onPressed: () => context.go('/movies'),
                                child: const Text('전체보기  >'),
                            ),
                        ],
                    ),
                    const SizedBox(height: 12),
                    if (others.isNotEmpty)
                        SizedBox(
                            height: 260,
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: others.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                    final movie = others[index];
                                    return SizedBox(
                                        width: 130,
                                        child: MovieCard(key: ValueKey(movie.id), movie: movie),
                                    );
                                },
                            ),
                        ),
                ],
            ),
        );
    }
}

class _FeaturedCard extends StatelessWidget {
    const _FeaturedCard({required this.movie});

    final TmdbMovieDto movie;

    static const _posterHeight = 600.0;

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        final posterUrl = movie.posterUrl;

        const placeholder = Center(
            child: Icon(Icons.movie_outlined, size: 48, color: AppColors.primary),
        );

        return GestureDetector(
            onTap: () => context.push('/movies/${movie.id}'),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                    height: _posterHeight,
                    child: Stack(
                        children: [
                            Positioned.fill(child: Container(color: AppColors.primaryLight)),

                            // 포스터: poster_path가 null이면 요청 없이 placeholder
                            Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: _posterHeight,
                                child: posterUrl == null
                                    ? placeholder
                                    : Image.network(
                                        posterUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, progress) =>
                                            progress == null ? child : placeholder,
                                        errorBuilder: (context, error, stackTrace) => placeholder,
                                    ),
                            ),

                            // 포스터를 어둡게 하는 오버레이
                            Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: _posterHeight,
                                child: Container(color: Colors.black.withValues(alpha: 0.65)),
                            ),

                            // 하단 텍스트 영역
                            Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(alpha: 0.8),
                                            ],
                                        ),
                                    ),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                    '추천 신작',
                                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                                movie.title.isEmpty ? '제목 없음' : movie.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.headlineSmall?.copyWith(color: Colors.white),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                _subtitle(),
                                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                                            ),
                                            const SizedBox(height: 40),
                                            SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                    onPressed: () => context.push('/movies/${movie.id}'),
                                                    icon: const Icon(Icons.info, size: 18),
                                                    label: const Text('상세보기'),
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppColors.primary,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 24),
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
                        ],
                    ),
                ),
            ),
        );
    }

    // 기존 '장르 · 러닝타임'은 Popular 응답에 없으므로 '연도 · 평점'으로 대체
    String _subtitle() {
        final date = movie.releaseDate;
        final year = (date == null || date.length < 4) ? null : date.substring(0, 4);
        return [
            if (year != null) year,
            '★ ${movie.voteAverage.toStringAsFixed(1)}',
        ].join(' · ');
    }
}