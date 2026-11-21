import 'package:dio/dio.dart';
import '../models/rating_dto.dart';
import '../models/rating_requests.dart';
import 'auth_api_service.dart';

class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);
  final Dio _publicDio;
  final Dio _authDio;
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _publicDio.get('/v7/members/$memberId/ratings');
    return (response.data as List).map((e) => RatingDto.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
  Future<RatingDto> createRating(CreateRatingRequest request) async {
    final response = await _authDio.post('/v7/ratings', data: request.toJson());
    return RatingDto.fromJson(responseResult(response.data));
  }
  Future<RatingDto> updateRating(int ratingId, UpdateRatingRequest request) async {
    final response = await _authDio.patch('/v7/ratings/$ratingId', data: request.toJson());
    return RatingDto.fromJson(responseResult(response.data));
  }
  Future<void> deleteRating(int ratingId) async {
    final response = await _authDio.delete('/v7/ratings/$ratingId');
    if (response.statusCode != 200) throw StateError('삭제 응답이 올바르지 않습니다.');
  }
}
String writeMyRatingsErrorMessage(DioException error) {
  final code = responseErrorCode(error);
  switch (code) {
    case 'RATING403_1': return '본인이 작성한 평점만 변경할 수 있습니다.';
    case 'RATING409_1': return '이미 등록한 영화의 평점입니다.';
    case 'RATING404_1': return '평점을 찾을 수 없습니다.';
    case 'AUTH401_2': case 'AUTH401_3': case 'AUTH401_4': return '로그인이 만료됐습니다.';
    default: return responseErrorMessage(error);
  }
}
