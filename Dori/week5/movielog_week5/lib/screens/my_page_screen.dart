
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/learning_member_session.dart';


import 'my_ratings_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 64,
            color: Color(0xFF6B52A3),
          ),

          const SizedBox(height: 16),

          const Text(
            '마이페이지',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text('내 영화 기록을 확인해 보세요.'),

          const SizedBox(height: 24),

          // 기존 회원가입 테스트 버튼
          ElevatedButton.icon(          
            onPressed: () {
              final memberId =
                  context.read<LearningMemberSession>().memberId;

              if (memberId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('회원가입 후 평점을 확인할 수 있습니다.'),
                  ),
                );
                return;
              }

              final ratingService = context.read<RatingApiService>();
              final movieService = context.read<TmdbMovieService>();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => MyRatingsViewModel(
                      ratingService,
                      movieService,
                      memberId,
                    )..load(),
                    child: const MyRatingsScreen(),
                  ),
                ),
              );
            },


            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('회원가입 테스트'),
          ),

          const SizedBox(height: 12),

          // 6주차: 내가 등록한 평점
          ElevatedButton.icon(
            onPressed: () {
              final ratingService =
                  context.read<RatingApiService>();

              final movieService =
                  context.read<TmdbMovieService>();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ChangeNotifierProvider(
                    create: (_) => MyRatingsViewModel(
                      ratingService,
                      movieService,
                      context.read<LearningMemberSession>().memberId!,
                    )..load(),
                    child: const MyRatingsScreen(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.star_outline),
            label: const Text('내가 등록한 평점'),
          ),
        ],
      ),
    );
  }
}
