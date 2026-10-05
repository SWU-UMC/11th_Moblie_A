import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../model/movie.dart';
import '../widget/common_app_bar.dart';
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
        final result = await showDialog<double>(
            context: context,
            builder: (context) => const RatingDialog(),
        );

        if(result != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('평점 $result점을 남겼습니다'),
                    behavior: SnackBarBehavior.floating,
                ),
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        final movie = findMovieById(widget.movieId);
        final textTheme = Theme.of(context).textTheme;

        if(movie == null) {
            return Scaffold(
                appBar: CommonAppBar(title: '영화 상세', showBackButton: true),
                body: const Center(child: Text('영화를 찾을 수 없습니다')),
            );
        }

        return Scaffold(
            appBar: CommonAppBar(
                title: 'Cinema Archive',
                showBackButton: true,
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
                                        child: Image.asset(
                                            movie.posterAsset,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                                return const Center(
                                                    child: Icon(Icons.movie_outlined, size: 64, color: AppColors.primary),
                                                );
                                            },
                                        ),
                                    ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 40),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(movie.title, style: textTheme.headlineMedium),
                                            const SizedBox(height: 8),
                                            Text(
                                                '${movie.year} · ${movie.genreTags.join('/')}'
                                                '${movie.durationMinutes != null ? ' · ${movie.durationMinutes}분' : ''}',
                                                style: textTheme.bodyMedium,
                                            ),
                                            const SizedBox(height: 12),

                                            // 평점 (읽기 전용)
                                            Wrap(
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                children: [
                                                    RatingBarIndicator(
                                                        rating: movie.rating,
                                                        itemCount: 5,
                                                        itemSize: 20,
                                                        itemBuilder: (context, index) {
                                                            return const Icon(Icons.star, color: AppColors.primary);
                                                        },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(movie.rating.toStringAsFixed(1), style: textTheme.bodyMedium),
                                                ],
                                            ),
                                            const SizedBox(height: 16),

                                            // 장르 배지
                                            Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: movie.genreTags.map((tag) {
                                                    return Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                        decoration: BoxDecoration(
                                                            color: AppColors.genreChipBackground,
                                                            borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Text(
                                                            tag,
                                                            style: textTheme.bodyMedium?.copyWith(color:AppColors.textPrimary),
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
                                                movie.synopsis?.split('\n').map((line) => line.trim()).join('\n') ?? '아직 등록된 줄거리가 없습니다.',
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