
import 'package:dio/dio.dart';
import '../models/tmdb_movie_dto.dart';

class TmdbMovieService {
  TmdbMovieService(this._dio);

  final Dio _dio;

  // 인기 영화 조회
  Future<TmdbMoviePageDto> fetchPopular() async {
    final r = await _dio.get(
      '/movie/popular',
      queryParameters: {
        'language': 'ko-KR',
        'page': 1,
      },
    );

    return TmdbMoviePageDto.fromJson(
      r.data as Map<String, dynamic>,
    );
  }

  // 영화 탐색
  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    int? genreId,
  }) async {
    final r = await _dio.get(
      '/discover/movie',
      queryParameters: {
        'language': 'ko-KR',
        'page': page,
        'sort_by': 'popularity.desc',
        'include_adult': false,
        'include_video': false,
        'with_genres': ?genreId,
      },
    );

    return TmdbMoviePageDto.fromJson(
      r.data as Map<String, dynamic>,
    );
  }

  // 장르 조회
  Future<List<TmdbGenreDto>> fetchGenres() async {
    final r = await _dio.get(
      '/genre/movie/list',
      queryParameters: {
        'language': 'ko',
      },
    );

    return ((r.data as Map<String, dynamic>)['genres']
                as List<dynamic>? ??
            [])
        .map(
          (e) => TmdbGenreDto.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // 6주차 추가: 영화 ID로 상세 정보 조회
  Future<TmdbMovieDto> fetchMovieDetail(int movieId) async {
    final r = await _dio.get(
      '/movie/$movieId',
      queryParameters: {
        'language': 'ko-KR',
      },
    );

    return TmdbMovieDto.fromJson(
      r.data as Map<String, dynamic>,
    );
  }

  // 6주차 추가: 영화가 없으면 null 반환
  Future<TmdbMovieDto?> findMovieById(int movieId) async {
    try {
      return await fetchMovieDetail(movieId);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }
}
