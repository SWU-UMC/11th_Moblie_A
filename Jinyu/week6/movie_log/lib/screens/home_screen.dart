import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

import '../view_models/movie_home_view_model.dart';

import '../widgets/tmdb_poster_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieHomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.status == MovieHomeLoadStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (viewModel.status == MovieHomeLoadStatus.error) {
          return Scaffold(
            body: Center(
              child: Text(
                viewModel.message ?? '오류가 발생했습니다.',
              ),
            ),
          );
        }

        if (viewModel.popular.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                '인기 영화가 없습니다.',
              ),
            ),
          );
        }

        final featuredMovie = viewModel.popular.first;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'MovieLog',
              style: TextStyle(
                color: AppColors.violet,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: AppColors.violet,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘은 어떤\n영화를 볼까요?',
                  style: AppTextStyles.titleLarge,
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () => context.push(
                    '/movies/${featuredMovie.id}',
                    extra: featuredMovie,
                    ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        TmdbPosterImage(
                          posterPath: featuredMovie.posterPath,
                          width: double.infinity,
                          height: 480,
                          fit: BoxFit.cover,
                        ),

                        Container(
                          width: double.infinity,
                          height: 480,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),

                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 24,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.violet,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '추천 신작',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                featuredMovie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                featuredMovie.releaseDate ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.push(
                                      '/movies/${featuredMovie.id}',
                                      extra: featuredMovie,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    '상세보기',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.violet,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '인기 영화',
                      style: AppTextStyles.titleMediumB,
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/movies');
                      },
                      child: const Text(
                        '전체보기 >',
                        style: TextStyle(
                          color: AppColors.violet,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.popular.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final movie =
                          viewModel.popular[index];

                      return GestureDetector(
                        onTap: () {
                          context.push(
                            '/movies/${movie.id}',
                            extra: movie,
                          );
                        },
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  child: TmdbPosterImage(
                                    posterPath:
                                        movie.posterPath,
                                    width: 150,
                                    height: 220,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                movie.title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}