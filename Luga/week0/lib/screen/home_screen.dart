// week 3 Guide Practice 전용 임시 홈 화면

import 'package:flutter/material.dart';
import '../model/movie.dart';
import '../widget/movie_card.dart';
import '../widget/common_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Guided Practice: 영화 카드 하나만 표시
    final movie = movies.first;

    return Scaffold(
      appBar: const CommonAppBar(title: 'MovieLog'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 160,
          child: MovieCard(movie: movie),
        ),
      ),
    );
  }
}