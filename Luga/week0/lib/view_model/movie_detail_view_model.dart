import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieDetailLoadStatus { idle, loading, success, notFound, error }

class MovieDetailViewModel extends ChangeNotifier {
    MovieDetailViewModel(this._service, this.movieId);

    final TmdbMovieService _service;
    final int movieId;

    TmdbMovieDto? movie;
    MovieDetailLoadStatus status = MovieDetailLoadStatus.idle;

    bool _disposed = false;

    Future<void> load() async {
        if (status == MovieDetailLoadStatus.loading) return;

        if (movieId < 0) {
            status = MovieDetailLoadStatus.notFound;
            notifyListeners();
            return;
        }

        status = MovieDetailLoadStatus.loading;
        notifyListeners();

        try {
            final result = await _service.fetchMovieDetail(movieId);
            if (_disposed) return;
            movie = result;
            status = MovieDetailLoadStatus.success;
        } on DioException catch (e) {
            if (_disposed) return;
            status = e.response?.statusCode == 404
                ? MovieDetailLoadStatus.notFound
                : MovieDetailLoadStatus.error;
        } catch (_) {
            if (_disposed) return;
            status = MovieDetailLoadStatus.error;
        }
        notifyListeners();
    }

    @override
    void dispose() {
        _disposed = true;
        super.dispose();
    }
}