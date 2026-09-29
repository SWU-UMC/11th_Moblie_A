import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/movie.dart';
import '../widget/movie_card.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final featured = movies.first; // 별빛 아래 우리
    final others = movies.skip(1).toList(); // 나머지 영화 카드

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'MovieLog',
          style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {}, // 검색 기능은 이번 미션 범위 밖
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘은 어떤\n영화를 볼까요?', style: textTheme.headlineSmall),
            const SizedBox(height: 20),

            // 추천 신작 히어로 카드
            GestureDetector(
              onTap: () => context.push('/movies/${featured.id}'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Container(
                        color: AppColors.primaryLight,
                        child: Image.asset(
                          featured.posterAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.movie_outlined, size: 64, color: AppColors.primary),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '추천 신작',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              featured.title,
                              style: textTheme.titleLarge?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${featured.genreTags.join(' · ')}'
                              '${featured.durationMinutes != null ? ' · ${featured.durationMinutes}분' : ''}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/movies/${featured.id}'),
                                icon: const Icon(Icons.info_outline, size: 18),
                                label: const Text('상세보기'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('인기 영화', style: textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.go('/movies'),
                  child: const Text('전체보기'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 나머지 영화 카드 (가로 스크롤 ListView)
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: others.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 130,
                    child: MovieCard(movie: others[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}