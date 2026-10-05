import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featuredMovie = mockMovies[0]; // 추천 신작 (별빛 아래 우리)

    return Scaffold(
      appBar: AppBar(
        title: const Text('MovieLog', style: TextStyle(color: AppColors.violet, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.violet), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('오늘은 어떤\n영화를 볼까요?', style: AppTextStyles.titleLarge),
            const SizedBox(height: 24),
            
            // 추천 신작 카드
            GestureDetector(
              onTap: () => context.push('/movies/${featuredMovie.id}'),
              child: Container(
                height: 480,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(featuredMovie.bannerAsset ?? featuredMovie.posterAsset),
                    fit: BoxFit.cover, 
                    alignment: Alignment.center, 
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.violet, borderRadius: BorderRadius.circular(16)),
                        child: const Text('추천 신작', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(height: 12),
                      Text(featuredMovie.title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${featuredMovie.genre} · ${featuredMovie.duration}분', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/movies/${featuredMovie.id}'),
                          icon: const Icon(Icons.info_outline, color: Colors.white),
                          label: const Text('상세보기', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.violet,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('인기 영화', style: AppTextStyles.titleMediumB),
                TextButton(
                  onPressed: () => context.go('/movies'),
                  child: const Text('전체보기 >', style: TextStyle(color: AppColors.violet)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}