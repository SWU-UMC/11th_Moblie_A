import '../../models/movie.dart';

enum MovieLoadMode { success, empty, failure }

class MovieLoadException implements Exception {
  const MovieLoadException(this.message);
  final String message;
}

class FakeMovieService {
  const FakeMovieService();

  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return switch (mode) {
      MovieLoadMode.success => mockMovies,
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure =>
        throw const MovieLoadException('영화를 불러오지 못했습니다. 네트워크 연결을 확인해주세요.'),
    };
  }
}
