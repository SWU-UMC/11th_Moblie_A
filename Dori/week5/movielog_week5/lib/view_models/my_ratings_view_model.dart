
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

const int sampleMemberId = 1;

enum MyRatingsLoadStatus {
  idle,
  loading,
  success,
  empty,
  error,
}

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._ratingService,
    this._movieService,
    this.memberId,
  );

  final RatingApiService _ratingService;
  final TmdbMovieService _movieService;
  final int memberId;

  final Map<int, TmdbMovieDto?> _movieCache = {};

  List<RatingWithMovie> ratings = [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  int _requestVersion = 0;
  bool _disposed = false;

  Future<void> load() async {
    final version = ++_requestVersion;

    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final rawRatings =
          await _ratingService.fetchMyRatings(memberId);

      if (_disposed || version != _requestVersion) return;

      final results = <RatingWithMovie>[];
      var missingMovies = 0;

      for (final rating in rawRatings) {
        if (_disposed || version != _requestVersion) return;

        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            _movieCache[rating.movieId] =
                await _movieService.findMovieById(
              rating.movieId,
            );
          } on DioException {
            // 영화 조회가 실패해도 평점은 표시한다.
          }
        }

        final movie = _movieCache[rating.movieId];

        if (movie == null) {
          missingMovies++;
        }

        results.add(
          RatingWithMovie(
            rating: rating,
            movie: movie,
          ),
        );
      }

      if (_disposed || version != _requestVersion) return;

      ratings = results;

      status = results.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;

      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못했습니다.';
      }
    } on DioException catch (error) {
      if (_disposed || version != _requestVersion) return;

      status = MyRatingsLoadStatus.error;
      message = writeMyRatingsErrorMessage(error);
    } catch (_) {
      if (_disposed || version != _requestVersion) return;

      status = MyRatingsLoadStatus.error;
      message = '평점을 불러오는 중 오류가 발생했습니다.';
    }

    if (!_disposed && version == _requestVersion) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
