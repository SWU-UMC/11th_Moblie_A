class TmdbMovieDto {
  const TmdbMovieDto({required this.id, required this.title, required this.overview, required this.posterPath, required this.genreIds, required this.voteAverage});
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final List<int> genreIds;
  final double voteAverage;
  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) => TmdbMovieDto(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String? ?? '제목 없음',
    overview: json['overview'] as String? ?? '',
    posterPath: json['poster_path'] as String?,
    genreIds: (json['genre_ids'] as List<dynamic>? ?? []).map((e) => (e as num).toInt()).toList(),
    voteAverage: (json['vote_average'] as num? ?? 0).toDouble(),
  );
}
class TmdbMoviePageDto {
  const TmdbMoviePageDto(this.results, this.totalPages);
  final List<TmdbMovieDto> results;
  final int totalPages;
  factory TmdbMoviePageDto.fromJson(Map<String, dynamic> json) => TmdbMoviePageDto(
    (json['results'] as List<dynamic>? ?? []).map((e) => TmdbMovieDto.fromJson(e as Map<String, dynamic>)).toList(),
    (json['total_pages'] as num? ?? 0).toInt(),
  );
}
class TmdbGenreDto {
  const TmdbGenreDto(this.id, this.name);
  final int id;
  final String name;
  factory TmdbGenreDto.fromJson(Map<String, dynamic> json) => TmdbGenreDto((json['id'] as num).toInt(), json['name'] as String? ?? '');
}
