import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../data/mock_movies.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;
  double myRating = 0;

  void _showRatingDialog() {
    double tempRating = myRating;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('별점 남기기'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingBar.builder(
                    initialRating: tempRating,
                    minRating: 1,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 38,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setDialogState(() {
                        tempRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${tempRating.toStringAsFixed(1)}점',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      myRating = tempRating;
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(widget.movieId);

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('영화를 찾을 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F5),
        title: const Text('영화 상세'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? '즐겨찾기에 추가했습니다.'
                        : '즐겨찾기에서 삭제했습니다.',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(
              isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: isFavorite
                  ? const Color(0xFF6750A4)
                  : const Color(0xFF777777),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영화 포스터
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E0F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.movie_outlined,
                size: 80,
                color: Color(0xFF6750A4),
              ),
            ),

            const SizedBox(height: 24),

            // 영화 제목
            Text(
              movie.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // 장르 / 연도
            Text(
              '${movie.genre} · ${movie.year}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
              ),
            ),

            const SizedBox(height: 28),

            // 평균 평점
            const Text(
              '평균 평점',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                RatingBarIndicator(
                  rating: 4.5,
                  itemCount: 5,
                  itemSize: 28,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '4.5',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // 내가 남긴 평점
            const Text(
              '내 평점',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              myRating == 0
                  ? '아직 평점을 남기지 않았어요.'
                  : '${myRating.toStringAsFixed(1)}점',
              style: const TextStyle(
                color: Color(0xFF777777),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _showRatingDialog,
                icon: const Icon(Icons.star_outline),
                label: Text(
                  myRating == 0 ? '별점 남기기' : '별점 수정하기',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}