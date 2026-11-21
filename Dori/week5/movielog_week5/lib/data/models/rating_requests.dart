
class CreateRatingRequest {
  const CreateRatingRequest({
    required this.movieId,
    required this.score,
    this.comment,
  });

  final int movieId;
  final int score;
  final String? comment;

  Map<String, dynamic> toJson() {
    return {
      'movieId': movieId,
      'score': score,
      'comment': comment,
    };
  }
}

class UpdateRatingRequest {
  const UpdateRatingRequest({
    required this.score,
    this.comment,
  });

  final int score;
  final String? comment;

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'comment': comment,
    };
  }
}
