import '../model/movie.dart';

abstract class MovieService {
    Future<List<Movie>> fetchMovies();
}

enum FakeMode { success, empty, error}

class MovieLoadException implements Exception {
    const MovieLoadException();
}

// TODO(5주차 유저별 평점 조회 API) : FakeMovieService -> 실제 API Service로 교체
class FakeMovieService implements MovieService {
    const FakeMovieService({this.mode = FakeMode.success});

    final FakeMode mode;

    @override
    Future<List<Movie>> fetchMovies() async {
        await Future.delayed(const Duration(seconds: 1));

        switch (mode) {
            case FakeMode.success:
                return movies;
            case FakeMode.empty:
                return const [];
            case FakeMode.error:
                throw const MovieLoadException();
        }
    }
}