import 'package:flutter/material.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieListLoadStatus {
  idle,
  loading,
 success,
  empty,
  error,
}

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);

  final TmdbMovieService _service;

  List<TmdbMovieDto> movies = [];
  List<TmdbGenreDto> genres = [];

  int? selectedGenreId;

  MovieListLoadStatus status = MovieListLoadStatus.idle;

  String? message;

  Future<void> loadInitial() async {
    status = MovieListLoadStatus.loading;
    message = null;

    notifyListeners();

    try {
      genres = await _service.fetchGenres();

      await loadMovies();
    } catch (_) {
      status = MovieListLoadStatus.error;
      message = '영화 목록을 불러오지 못했습니다.';

      notifyListeners();
    }
  }

  Future<void> loadMovies({
    int? genreId,
  }) async {
    status = MovieListLoadStatus.loading;
    message = null;

    notifyListeners();

    try {
      final byId = <int, TmdbMovieDto>{};

      var pageNumber = 1;
      var hasNextPage = true;

      while (byId.length < 30 && hasNextPage) {
        final page = await _service.discoverMovies(
          page: pageNumber,
          genreId: genreId,
        );

        for (final movie in page.results) {
          byId[movie.id] = movie;

          if (byId.length == 30) {
            break;
          }
        }

        hasNextPage =
            pageNumber < page.totalPages &&
            page.results.isNotEmpty;

        pageNumber++;
      }

      movies = byId.values.take(30).toList();

      // empty를 위한 비우기
      //movies = [];

      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } catch (_) {
      status = MovieListLoadStatus.error;
      message = '영화 목록을 불러오지 못했습니다.';
    }

    notifyListeners();
  }

  Future<void> changeGenre(
    int? genreId,
  ) async {
    selectedGenreId = genreId;

    await loadMovies(
      genreId: genreId,
    );
  }
}