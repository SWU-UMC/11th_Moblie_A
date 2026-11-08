import '../../models/movie.dart';

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

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) {
    return TmdbMovieDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '제목 없음',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>? ?? const []).map((e) => (e as num).toInt()).toList(),
      voteAverage: (json['vote_average'] as num? ?? 0).toDouble(),
      popularity: (json['popularity'] as num? ?? 0).toDouble(),
    );
  }
}

extension TmdbMovieMapper on TmdbMovieDto {
  Movie toDomain() {
    return Movie(
      id: id,
      title: title,
      originalTitle: title,
      genre: genreIds.isNotEmpty ? genreIds.join(',') : '', // 간단 매핑 (실제는 Genre API 필요)
      year: int.tryParse(releaseDate?.split('-').first ?? '') ?? 0,
      duration: 0, // TMDB 기본 응답에는 runtime 없음 → 상세 API 필요
      rating: voteAverage,
      synopsis: overview,
      posterAsset: '', // TMDB 데이터에서는 로컬 에셋 사용 안 함
      bannerAsset: backdropPath, // TMDB의 backdropPath를 배너로 활용 가능
      posterPath: posterPath, // 여기서 TMDB 포스터 경로를 Movie.posterPath에 매핑
    );
  }
}
