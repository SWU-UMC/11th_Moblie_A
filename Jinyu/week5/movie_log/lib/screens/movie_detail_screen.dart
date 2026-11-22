
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/movie.dart';
import '../themes/app_colors.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatefulWidget {
  final int? movieId;
  final Movie? movie;

  const MovieDetailScreen({
    super.key,
    this.movieId,
    this.movie,
  });

  @override
  State<MovieDetailScreen> createState() =>
      _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;
  double userRating = 0.0;

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '즐겨찾기에 추가되었습니다.'
              : '즐겨찾기에서 제거되었습니다.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showRatingDialog() async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => RatingDialog(
        initialRating: userRating,
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      userRating = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 전달받은 영화가 있으면 우선 사용하고,
    // 없으면 기존 영화 목록에서 ID로 검색한다.
    final movie =
        widget.movie ?? findMovieById(widget.movieId);

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('영화 상세'),
        ),
        body: const Center(
          child: Text('영화를 찾을 수 없습니다.'),
        ),
      );
    }

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
                    isFavorite
                        ? Icons.bookmark
                        : Icons.bookmark_border,
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
                  onPressed: _showRatingDialog,
                  icon: const Icon(
                    Icons.rate_review_outlined,
                    color: Colors.white,
                  ),
                  label: Text(
                    userRating > 0
                        ? '내 평점: $userRating'
                        : '평점 남기기',
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
            // TMDB 포스터 이미지
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

            // 영화 상세 정보
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
                    '${movie.year} · ${movie.genre} · '
                    '${movie.duration}분',
                    style: const TextStyle(
                      color: AppColors.gray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.rating,
                        itemBuilder: (context, index) =>
                            const Icon(
                          Icons.star,
                          color: AppColors.violet,
                        ),
                        itemCount: 5,
                        itemSize: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${movie.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
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
                    movie.synopsis,
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
