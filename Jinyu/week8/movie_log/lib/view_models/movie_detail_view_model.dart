import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/storage/my_ratings_storage.dart';
import '../data/models/rating_dto.dart';
import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';
import 'signup_view_model.dart';

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._authViewModel,
    this.movie, [
    MyRatingsStorage? ratingsStorage,
  ]) : _ratingsStorage = ratingsStorage;

  final RatingApiService _ratingService;
  final AuthViewModel _authViewModel;
  final TmdbMovieDto movie;
  final MyRatingsStorage? _ratingsStorage;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  RatingDto? savedRating;
  bool _disposed = false;

  Future<void> loadSavedRating() async {
    final storage = _ratingsStorage;
    if (storage == null) return;
    final list = await storage.readRatings();
    if (_disposed) return;

    RatingDto? matched;
    for (final item in list) {
      if (item.movieId == movie.id) {
        matched = item;
        break;
      }
    }
    savedRating = matched;
    if (!_disposed) notifyListeners();
  }

  Future<void> createRating({required int score, String? comment}) async {
    if (_authViewModel.status != AuthStatus.signedIn) {
      submitStatus = SubmitStatus.error;
      submitMessage = '로그인 후 평점을 남길 수 있어요.';
      if (!_disposed) notifyListeners();
      return;
    }
    if (submitStatus == SubmitStatus.submitting) return;

    final version = _authViewModel.sessionVersion;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    if (!_disposed) notifyListeners();

    try {
      final created = await _ratingService.createRating(
        CreateRatingRequest(
          movieId: movie.id,
          score: score,
          comment: comment,
        ),
      );
      if (_disposed || version != _authViewModel.sessionVersion) return;
      await _ratingsStorage?.upsertRating(created);
      if (_disposed || version != _authViewModel.sessionVersion) return;
      savedRating = created;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed || version != _authViewModel.sessionVersion) return;
      final code = apiErrorCode(error);
      if (code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4') {
        await _authViewModel.expireSession();
        return;
      }
      submitStatus = SubmitStatus.error;
      submitMessage = switch (code) {
        'RATING403_1' => '이 평점을 작성할 권한이 없어요.',
        'RATING409_1' => '이미 이 영화에 평점을 남겼어요.',
        _ => writeErrorMessage(error),
      };
    }
    if (!_disposed && version == _authViewModel.sessionVersion) {
      notifyListeners();
    }
  }

  Future<void> updateSavedRating({
    required int score,
    String? comment,
  }) async {
    final current = savedRating;
    if (current == null) return;

    final version = _authViewModel.sessionVersion;
    submitMessage = null;
    try {
      final updated = await _ratingService.updateRating(
        ratingId: current.ratingId,
        score: score,
        comment: comment,
      );
      if (_disposed || version != _authViewModel.sessionVersion) return;
      await _ratingsStorage?.upsertRating(updated);
      if (_disposed || version != _authViewModel.sessionVersion) return;
      savedRating = updated;
      if (!_disposed) notifyListeners();
    } on DioException catch (error) {
      if (_disposed || version != _authViewModel.sessionVersion) return;
      final code = apiErrorCode(error);
      if (code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4') {
        await _authViewModel.expireSession();
        return;
      }
      submitMessage = switch (code) {
        'RATING403_1' => '본인이 작성한 평점만 수정할 수 있어요.',
        'RATING404_1' => '존재하지 않는 평점이에요.',
        _ => writeErrorMessage(error),
      };
      if (!_disposed) notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSavedRating() async {
    final current = savedRating;
    if (current == null) return;

    final version = _authViewModel.sessionVersion;
    submitMessage = null;
    try {
      await _ratingService.deleteRating(current.ratingId);
      if (_disposed || version != _authViewModel.sessionVersion) return;
      await _ratingsStorage?.removeRating(current.ratingId);
      if (_disposed || version != _authViewModel.sessionVersion) return;
      savedRating = null;
      if (!_disposed) notifyListeners();
    } on DioException catch (error) {
      if (_disposed || version != _authViewModel.sessionVersion) return;
      final code = apiErrorCode(error);
      if (code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4') {
        await _authViewModel.expireSession();
        return;
      }
      submitMessage = switch (code) {
        'RATING403_1' => '본인이 작성한 평점만 삭제할 수 있어요.',
        'RATING404_1' => '이미 삭제되었거나 존재하지 않는 평점이에요.',
        _ => writeErrorMessage(error),
      };
      if (!_disposed) notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}