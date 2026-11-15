import 'tmdb_genre_dto.dart';

class TmdbMovieDto {
  const TmdbMovieDto({
      required this.id,
      required this.title,
      required this.overview,
      required this.posterPath,
      required this.backdropPath,
      required this.releaseDate,
      required this.genreIds,
      required this.voteAverage,
      required this.popularity,
      this.genres = const [],
      this.runtime,
  });
  
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final List<int> genreIds;
  final double voteAverage;
  final double popularity;

  // 상세 응답에서만 채워짐
  final List<TmdbGenreDto> genres;
  final int? runtime;

  static const _imageBase = 'https://image.tmdb.org/t/p';

  String? get posterUrl =>
    posterPath == null ? null : '$_imageBase/w500$posterPath';

  String? get backdropUrl =>
     backdropPath == null ? null : '$_imageBase/w780$backdropPath';

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) {
    final genres = (json['genres'] as List<dynamic>? ?? const [])
        .map((item) => TmdbGenreDto.fromJson(item as Map<String, dynamic>))
        .toList();

    return TmdbMovieDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '제목 없음',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      // 상세 응답이면 genres의 id로 genreIds를 채워 둠
      genreIds: genres.isNotEmpty
          ? genres.map((g) => g.id).toList()
          : (json['genre_ids'] as List<dynamic>? ?? const [])
              .map((value) => (value as num).toInt())
              .toList(),
      voteAverage: (json['vote_average'] as num? ?? 0).toDouble(),
      popularity: (json['popularity'] as num? ?? 0).toDouble(),
      genres: genres,
      runtime: (json['runtime'] as num?)?.toInt(),
    );
  }
}