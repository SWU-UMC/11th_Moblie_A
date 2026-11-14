
import 'package:dio/dio.dart';

import '../models/rating_dto.dart';
import '../models/rating_requests.dart';

class RatingApiService {
  RatingApiService(this._dio);

  final Dio _dio;

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get(
      '/v6/members/$memberId/ratings',
    );

    final data = response.data as List<dynamic>;

    return data
        .map((item) => RatingDto.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> createRating(
    int memberId,
    CreateRatingRequest request,
  ) async {
    await _dio.post(
      '/v6/members/$memberId/ratings',
      data: request.toJson(),
    );
  }

  Future<void> updateRating(
    int memberId,
    int ratingId,
    UpdateRatingRequest request,
  ) async {
    await _dio.patch(
      '/v6/members/$memberId/ratings/$ratingId',
      data: request.toJson(),
    );
  }

  Future<void> deleteRating(
    int memberId,
    int ratingId,
  ) async {
    await _dio.delete(
      '/v6/members/$memberId/ratings/$ratingId',
    );
  }
}

String writeMyRatingsErrorMessage(DioException error) {
  final data = error.response?.data;

  if (data is Map) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
  }

  switch (error.response?.statusCode) {
    case 400:
      return '요청 내용을 다시 확인해 주세요.';
    case 403:
      return '해당 평점을 변경할 권한이 없습니다.';
    case 404:
      return '회원 또는 평점을 찾을 수 없습니다.';
    case 409:
      return '이미 등록된 평점이거나 요청이 충돌했습니다.';
    default:
      return '서버 요청에 실패했습니다. 다시 시도해 주세요.';
  }
}
