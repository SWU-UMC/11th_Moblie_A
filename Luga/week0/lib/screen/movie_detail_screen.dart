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
                    content: Text('평점 $result점을 넘겼습니다'),
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
            appBar: CommonAppBar(title: 'Cinema Archive', showBackButton: true),
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
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(movie.title, style: textTheme.titleLarge),
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
                                                            return const Icon(Icons.star, color: Colors.white);
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
                                                            color: AppColors.primaryLight,
                                                            borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Text(
                                                            tag,
                                                            style: textTheme.bodyMedium?.copyWith(color:AppColors.primary),
                                                        ),
                                                    );
                                                }).toList(),
                                            ),
                                            const SizedBox(height: 24),

                                            Text('시놉시스', style: textTheme.titleMedium),
                                            const SizedBox(height: 12),
                                            Text(
                                                movie.synopsis ?? '아직 등록된 줄거리가 없습니다.',
                                                style: textTheme.bodyMedium,
                                            ),
                                            const SizedBox(height: 16),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
            // 하단 NavigationBar 자리를 즐겨찾기/평점 버튼이 대신 차지
            bottomNavigationBar: SafeArea(
                top: false,
                child: ResponsiveContainer(
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