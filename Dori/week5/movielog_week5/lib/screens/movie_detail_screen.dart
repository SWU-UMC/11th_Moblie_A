
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_requests.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../view_models/learning_member_session.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  final TmdbMovieDto movie;

  Future<void> _addRating(BuildContext context) async {
    final memberId =
        context.read<LearningMemberSession>().memberId;

    if (memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('평점을 등록하려면 먼저 회원가입해 주세요.'),
        ),
      );
      return;
    }

    final service = context.read<RatingApiService>();

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        title: '평점 등록',
        onSubmit: (input) async {
          try {
            await service.createRating(
              memberId,
              CreateRatingRequest(
                movieId: movie.id,
                score: input.score,
                comment: input.comment,
              ),
            );
          } on DioException catch (error) {
            throw Exception(
              writeMyRatingsErrorMessage(error),
            );
          }
        },
      ),
    );

    if (!context.mounted) return;

    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('평점이 등록되었습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 280,
            child: TmdbPosterImage(path: movie.posterPath),
          ),
          const SizedBox(height: 20),
          Text(
            movie.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'TMDB 평점: ${movie.voteAverage.toStringAsFixed(1)}',
          ),
          const SizedBox(height: 20),
          Text(
            movie.overview.isEmpty
                ? '줄거리 정보가 없습니다.'
                : movie.overview,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _addRating(context),
            icon: const Icon(Icons.star),
            label: const Text('내 평점 등록하기'),
          ),
        ],
      ),
    );
  }
}
