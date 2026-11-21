import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../data/services/rating_api_service.dart';
import '../data/models/rating_requests.dart';
import '../data/services/auth_api_service.dart';
import '../widgets/rating_dialog.dart';
import 'edit_profile_screen.dart';
import 'package:flutter/foundation.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});
  @override Widget build(BuildContext context) => Consumer<AuthViewModel>(builder: (context, auth, _) => ListView(padding: const EdgeInsets.all(20), children: [
    const Icon(Icons.person_outline, size: 64),
    const SizedBox(height: 12), Text(auth.member?.nickname ?? '회원', textAlign: TextAlign.center, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
    Text(auth.member?.email ?? '', textAlign: TextAlign.center),
    const SizedBox(height: 18), FilledButton.tonal(onPressed: auth.member == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())), child: const Text('프로필 수정')),
    OutlinedButton(onPressed: auth.logout, child: const Text('로그아웃')),
    
    const Divider(height: 38), const Text('이번 로그인에서 등록한 평점', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    if (kDebugMode)
    FilledButton(
      onPressed: () async {
        await auth.testInvalidToken();
      },
      child: const Text('🧪 무효 토큰 테스트'),
    ),
    if (auth.sessionRatings.isEmpty) const Text('아직 이 세션에서 등록한 평점이 없어요. 영화 상세에서 평점을 등록해 주세요.'),
    for (final rating in auth.sessionRatings.reversed) Card(child: ListTile(
      title: Text('영화 #${rating.movieId}  ★ ${rating.score}'),
      subtitle: Text(rating.comment ?? '후기 없음'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.edit), onPressed: () async {
          final service = context.read<RatingApiService>();
          await showDialog<bool>(context: context, builder: (_) => RatingDialog(
            title: '평점 수정', initialScore: rating.score.toInt(), initialComment: rating.comment,
            onSubmit: (input) async {
              try { final updated = await service.updateRating(rating.ratingId, UpdateRatingRequest(score: input.score, comment: input.comment)); auth.addRating(updated); }
              on DioException catch (e) { await _handleAuth(auth, e); throw Exception(writeMyRatingsErrorMessage(e)); }
            },
          ));
        }),
        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
          final yes = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('평점 삭제'), content: const Text('이 평점을 삭제할까요?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('취소')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('삭제'))]));
          if (yes != true || !context.mounted) return;
          try { await context.read<RatingApiService>().deleteRating(rating.ratingId); auth.removeRating(rating.ratingId); }
          on DioException catch (e) { await _handleAuth(auth, e); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(writeMyRatingsErrorMessage(e)))); }
        }),
      ]),
    )),
    const SizedBox(height: 16), const Text('※ v7에는 내 평점 목록 API가 없어, 재로그인 후 과거 평점 전체 복원은 지원하지 않습니다.', style: TextStyle(fontSize: 12)),
  ]));
}
Future<void> _handleAuth(AuthViewModel auth, DioException e) async {
  if (const {'AUTH401_2','AUTH401_3','AUTH401_4'}.contains(responseErrorCode(e))) await auth.expireSession();
}
