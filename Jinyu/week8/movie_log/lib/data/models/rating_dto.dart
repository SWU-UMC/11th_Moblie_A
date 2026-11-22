class RatingDto {
  const RatingDto({
    required this.ratingId,
    required this.movieId,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  final int ratingId;
  final int movieId;
  final int score;
  final String? comment;
  final DateTime createdAt;

  RatingDto copyWith({
    int? ratingId,
    int? movieId,
    int? score,
    String? comment,
    bool clearComment = false,
    DateTime? createdAt,
  }) {
    return RatingDto(
      ratingId: ratingId ?? this.ratingId,
      movieId: movieId ?? this.movieId,
      score: score ?? this.score,
      comment: clearComment ? null : (comment ?? this.comment),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'ratingId': ratingId,
    'movieId': movieId,
    'score': score,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };

  factory RatingDto.fromJson(Map<String, dynamic> json) => RatingDto(
    ratingId: (json['ratingId'] as num).toInt(),
    movieId: (json['movieId'] as num).toInt(),
    score: (json['score'] as num).toInt(),
    comment: json['comment'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}