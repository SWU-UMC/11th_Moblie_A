import '../data/mock_movies.dart';
import '../models/movie.dart';

enum MovieLoadMode {
  success,
  empty,
  failure,
}

class MovieLoadException implements Exception {
  const MovieLoadException(this.message);

  final String message;
}

class FakeMovieService {
  const FakeMovieService();

  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    // 실제 서버에서 데이터를 받아오는 상황을 가정
    await Future<void>.delayed(
      const Duration(seconds: 1),
    );

    return switch (mode) {
      MovieLoadMode.success => movies,
      MovieLoadMode.empty => <Movie>[],
      MovieLoadMode.failure =>
        throw const MovieLoadException('영화를 불러오지 못했습니다.'),
    };
  }
}