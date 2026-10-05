import '../models/movie.dart';

enum MovieLoadMode { success, empty, failure }

class MovieLoadException implements Exception {
  const MovieLoadException(this.message);
  final String message;
}

class FakeMovieService {
  const FakeMovieService();

  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success, // 성공 모드

  }) async {
    // 요구사항: 최소 800ms 이상 Loading 화면이 보이도록 설정
    await Future<void>.delayed(const Duration(milliseconds: 800));

    return switch (mode) {
      MovieLoadMode.success => mockMovies, // 3주차에 정의된 Mock 영화 목록 데이터 재사용
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure =>
        throw const MovieLoadException('영화를 불러오지 못했습니다. 네트워크 연결을 확인해주세요.'),
    };
  }
}