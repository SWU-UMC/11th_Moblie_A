import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/movie.dart';
import '../widget/movie_card.dart';
import '../widget/responsive_container.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        final featured = movies.first; // 별빛 아래 우리
        final others = movies.skip(1).toList(); // 나머지 영화 카드

        const posterHeight = 600.0; // 포스터 자체 고정 높이

        return Scaffold(
            body: SafeArea(
                child: ResponsiveContainer(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text('MovieLog', style: textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                                        GestureDetector(
                                            onTap: () {},
                                            child: const Icon(Icons.search),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 24),

                                Text('오늘은 어떤\n영화를 볼까요?', style: textTheme.headlineSmall),
                                const SizedBox(height: 20),

                                // 추천 신작 히어로 카드 (카드 높이는 늘어나도 포스터 높이는 고정)
                                GestureDetector(
                                    onTap: () => context.push('/movies/${featured.id}'),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: SizedBox(
                                            height: 600,
                                            child: Stack(
                                                children: [
                                                    // 카드 전체 배경색 (포스터 바깥 여백)
                                                    Positioned.fill(
                                                        child: Container(color: AppColors.primaryLight),
                                                    ),

                                                    // 포스터: 높이 고정, 상단 정렬
                                                    Positioned(
                                                        top: 0,
                                                        left: 0,
                                                        right: 0,
                                                        height: posterHeight,
                                                        child: Image.asset(
                                                            featured.posterAsset,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                                return const Center(
                                                                    child: Icon(Icons.movie_outlined, size: 48, color: AppColors.primary),
                                                                );
                                                            },
                                                        ),
                                                    ),

                                                    // 포스터를 어둡게 하는 오버레이 (포스터 영역에만 적용)
                                                    Positioned(
                                                        top: 0,
                                                        left: 0,
                                                        right: 0,
                                                        height: posterHeight,
                                                        child: Container(
                                                            color: Colors.black.withValues(alpha: 0.65),
                                                        ),
                                                    ),

                                                    // 하단 텍스트 영역
                                                    Positioned(
                                                        left: 0,
                                                        right: 0,
                                                        bottom: 0,
                                                        child: Container(
                                                            padding: const EdgeInsets.all(16),
                                                            decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    begin: Alignment.topCenter,
                                                                    end: Alignment.bottomCenter,
                                                                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                                                                ),
                                                            ),
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                    Container(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                                        decoration: BoxDecoration(
                                                                            color: AppColors.primary,
                                                                            borderRadius: BorderRadius.circular(20),
                                                                        ),
                                                                        child: const Text(
                                                                            '추천 신작',
                                                                            style: TextStyle(color: Colors.white, fontSize: 12),
                                                                        ),
                                                                    ),
                                                                    const SizedBox(height: 8),
                                                                    Text(
                                                                        featured.title,
                                                                        style: textTheme.headlineSmall?.copyWith(color: Colors.white),
                                                                    ),
                                                                    const SizedBox(height: 4),
                                                                    Text(
                                                                        '${featured.genreTags.join(' · ')}'
                                                                        '${featured.durationMinutes != null ? ' · ${featured.durationMinutes}분' : ''}',
                                                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                                                    ),
                                                                    const SizedBox(height: 40),
                                                                    SizedBox(
                                                                        width: double.infinity,
                                                                        child: ElevatedButton.icon(
                                                                            onPressed: () => context.push('/movies/${featured.id}'),
                                                                            icon: const Icon(Icons.info, size: 18),
                                                                            label: const Text('상세보기'),
                                                                            style: ElevatedButton.styleFrom(
                                                                                backgroundColor: AppColors.primary,
                                                                                foregroundColor: Colors.white,
                                                                                padding: const EdgeInsets.symmetric(vertical: 24),
                                                                                shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(24),
                                                                                ),
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
                                ),

                                const SizedBox(height: 32),

                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text('인기 영화', style: textTheme.titleMedium),
                                        TextButton(
                                            onPressed: () => context.go('/movies'),
                                            child: const Text('전체보기  >'),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 12),

                                SizedBox(
                                    height: 260,
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
                ),
            ),
        );
    }
}