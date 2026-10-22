import 'package:dio/dio.dart';
import '../models/tmdb_movie_dto.dart';
class TmdbMovieService {
  TmdbMovieService(this._dio);
  final Dio _dio;
  Future<TmdbMoviePageDto> fetchPopular() async {
    final r = await _dio.get('/movie/popular', queryParameters: {'language':'ko-KR','page':1});
    return TmdbMoviePageDto.fromJson(r.data as Map<String,dynamic>);
  }
  Future<TmdbMoviePageDto> discoverMovies({required int page, int? genreId}) async {
    final r = await _dio.get('/discover/movie', queryParameters: {
      'language':'ko-KR','page':page,'sort_by':'popularity.desc',
      'include_adult':false,'include_video':false,
      'with_genres':?genreId,
    });
    return TmdbMoviePageDto.fromJson(r.data as Map<String,dynamic>);
  }
  Future<List<TmdbGenreDto>> fetchGenres() async {
    final r = await _dio.get('/genre/movie/list', queryParameters:{'language':'ko'});
    return ((r.data as Map<String,dynamic>)['genres'] as List<dynamic>? ?? [])
      .map((e) => TmdbGenreDto.fromJson(e as Map<String,dynamic>)).toList();
  }
}
