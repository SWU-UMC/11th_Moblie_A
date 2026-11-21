
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_requests.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

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
  final Set<int> _selectedIds = {};

  List<RatingWithMovie> ratings = [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  bool isEditMode = false;
  bool isDeleting = false;

  bool _disposed = false;
  int _requestVersion = 0;

  Set<int> get selectedIds => Set.unmodifiable(_selectedIds);
  int get selectedCount => _selectedIds.length;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void toggleEditMode() {
    if (isDeleting) return;
    isEditMode = !isEditMode;
    _selectedIds.clear();
    _notify();
  }

  void toggleSelection(int ratingId) {
    if (!isEditMode || isDeleting) return;

    if (!_selectedIds.add(ratingId)) {
      _selectedIds.remove(ratingId);
    }
    _notify();
  }

  Future<void> load() async {
    final version = ++_requestVersion;

    status = MyRatingsLoadStatus.loading;
    message = null;
    _notify();

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
            // 영화 조회 실패 시 평점 정보만 표시한다.
          }
        }

        final movie = _movieCache[rating.movieId];

        if (movie == null) missingMovies++;

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

      final existingIds =
          results.map((entry) => entry.rating.ratingId).toSet();

      _selectedIds.removeWhere(
        (id) => !existingIds.contains(id),
      );

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

    _notify();
  }

  Future<String?> refreshAfterWrite() async {
    await load();

    if (status == MyRatingsLoadStatus.error) {
      return '변경은 완료됐지만 목록 새로고침에 실패했습니다. 다시 시도를 눌러 주세요.';
    }

    return null;
  }

  Future<String?> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    await _ratingService.updateRating(
      memberId,
      ratingId,
      UpdateRatingRequest(
        score: score,
        comment: comment,
      ),
    );

    return refreshAfterWrite();
  }

  Future<String?> deleteRating(int ratingId) async {
    await _ratingService.deleteRating(memberId, ratingId);
    _selectedIds.remove(ratingId);
    return refreshAfterWrite();
  }

  Future<BatchDeleteResult> deleteSelected() async {
    if (isDeleting || _selectedIds.isEmpty) {
      return const BatchDeleteResult(
        deletedCount: 0,
        failedCount: 0,
      );
    }

    isDeleting = true;
    _notify();

    final targets = _selectedIds.toList();
    var deletedCount = 0;
    final failedIds = <int>{};

    try {
      for (final ratingId in targets) {
        try {
          await _ratingService.deleteRating(memberId, ratingId);
          deletedCount++;
          _selectedIds.remove(ratingId);
        } catch (_) {
          failedIds.add(ratingId);
        }
      }

      // 삭제에 실패한 평점만 선택 상태로 남긴다.
      _selectedIds
        ..clear()
        ..addAll(failedIds);

      if (deletedCount > 0) {
        await load();
      }

      if (failedIds.isEmpty && status != MyRatingsLoadStatus.error) {
        isEditMode = false;
      }

      return BatchDeleteResult(
        deletedCount: deletedCount,
        failedCount: failedIds.length,
        refreshFailed: status == MyRatingsLoadStatus.error,
      );
    } finally {
      isDeleting = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}

class BatchDeleteResult {
  const BatchDeleteResult({
    required this.deletedCount,
    required this.failedCount,
    this.refreshFailed = false,
  });

  final int deletedCount;
  final int failedCount;
  final bool refreshFailed;
}
