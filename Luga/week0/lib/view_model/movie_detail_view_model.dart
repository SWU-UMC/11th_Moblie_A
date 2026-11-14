import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/models/rating_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'submit_status.dart';

enum MovieDetailLoadStatus { idle, loading, success, notFound, error }

class MovieDetailViewModel extends ChangeNotifier {
    MovieDetailViewModel(this._ratingService, this.memberId, this.movie);

    final RatingApiService _ratingService;
    final int? memberId;
    final TmdbMovieDto movie;

    SubmitStatus submitStatus = SubmitStatus.idle;
    String? submitMessage;
    bool _disposed = false;

    bool get canSubmit => memberId != null;

    /// 성공하면 정상 반환, 실패하면 예외를 던집니다 (RatingDialog가 catch).
    Future<void> createRating({required int score, String? comment}) {
        final id = memberId,
        if(id == null) {
            submitStatus = SubmitStatus.error;
            submitStatus = '먼저 회원가입을 완료해 주세요.';
            _notify();
            throw StateError(submitMessage!);
        }
        if(submitStatus == submitStatus.submitting) return;

        submitStatus = submitStatus.submitting;
        submitMessage = null;
        _notify();

        try{
            await _ratingService.createRating(
                memberId: id,
                request: CreateRatingRequest(
                    movieId: movie.id,
                    score: score,
                    comment: comment,
                ),
            );
            if(_disposed) return;
            submitStatus = SubmitStatus.success;
        } on DioException catch (error) {
            if(_disposed) return;
            submitStatus = SubmitStatus.error;
            submitMessage = writeErrorMessage(error);
            _notify();
            rethrow;
        }
        _notify();
    }

    void _notify() {
        if(!disposed) notifyListeners();
    }

    @override
    void dispose() {
        _disposed = true;
        super.dispose();
    }
}