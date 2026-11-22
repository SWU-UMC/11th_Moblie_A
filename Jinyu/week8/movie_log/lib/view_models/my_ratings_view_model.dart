import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/storage/my_ratings_storage.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._service,
    this._movieService,
    this._authViewModel,
    this.memberId, [
    MyRatingsStorage? ratingsStorage,
  ]) : _ratingsStorage = ratingsStorage;

  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final AuthViewModel _authViewModel;
  final int memberId;
  final MyRatingsStorage? _ratingsStorage;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;
  String? refreshWarning;

  Future<void> load() async {
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();

    final localRatings = await _ratingsStorage?.readRatings() ?? const [];
    if (_disposed || version != _requestVersion) return;

    final moviesById = <int, TmdbMovieDto?>{};
    for (final rating in localRatings) {
      if (_disposed || version != _requestVersion) return;
      if (!_movieCache.containsKey(rating.movieId)) {
        try {
          _movieCache[rating.movieId] =
              await _movieService.findMovieById(rating.movieId);
        } on DioException {
          // 일시적 네트워크 오류는 캐시하지 않음
        }
      }
      moviesById[rating.movieId] = _movieCache[rating.movieId];
    }

    if (_disposed || version != _requestVersion) return;
    final entries = <RatingWithMovie>[];
    var missingMovies = 0;
    for (final rating in localRatings) {
      final movie = moviesById[rating.movieId];
      if (movie == null) missingMovies++;
      entries.add(RatingWithMovie(rating: rating, movie: movie));
    }

    ratings = entries;
    status = entries.isEmpty
        ? MyRatingsLoadStatus.empty
        : MyRatingsLoadStatus.success;
    if (missingMovies > 0) {
      message = '일부 영화 정보는 placeholder로 표시됩니다.';
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  Future<void> _refreshAfterWrite() async {
    await load();
    if (status == MyRatingsLoadStatus.error) {
      refreshWarning = '저장은 완료됐지만 목록을 불러오지 못했어요. 조회만 다시 시도해 주세요.';
      notifyListeners();
    } else {
      refreshWarning = null;
    }
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final version = _authViewModel.sessionVersion;
    try {
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      if (_disposed || version != _authViewModel.sessionVersion) return;
      await _ratingsStorage?.upsertRating(updated);
      if (_disposed || version != _authViewModel.sessionVersion) return;
    } on DioException catch (error) {
      if (_disposed || version != _authViewModel.sessionVersion) return;
      final code = apiErrorCode(error);
      if (code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4') {
        await _authViewModel.expireSession();
        return;
      }
      message = switch (code) {
        'RATING403_1' => '본인이 작성한 평점만 수정할 수 있어요.',
        'RATING404_1' => '존재하지 않는 평점이에요.',
        _ => writeErrorMessage(error),
      };
      notifyListeners();
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
    await _refreshAfterWrite();
  }

  Future<void> deleteRating(int ratingId) async {
    final version = _authViewModel.sessionVersion;
    try {
      await _service.deleteRating(ratingId);
      if (_disposed || version != _authViewModel.sessionVersion) return;
      await _ratingsStorage?.removeRating(ratingId);
      if (_disposed || version != _authViewModel.sessionVersion) return;
    } on DioException catch (error) {
      if (_disposed || version != _authViewModel.sessionVersion) return;
      final code = apiErrorCode(error);
      if (code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4') {
        await _authViewModel.expireSession();
        return;
      }
      message = switch (code) {
        'RATING403_1' => '본인이 작성한 평점만 삭제할 수 있어요.',
        'RATING404_1' => '이미 삭제되었거나 존재하지 않는 평점이에요.',
        _ => writeErrorMessage(error),
      };
      notifyListeners();
      if (shouldRefreshAfterRatingError(error)) await load();
      rethrow;
    }
    await _refreshAfterWrite();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}