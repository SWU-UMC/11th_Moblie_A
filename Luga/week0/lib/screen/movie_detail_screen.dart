import 'package:flutter/material.dart';
import '../model/movie.dart';
import '../widget/common_app_bar.dart';
import '../theme/app_colors.dart';

class MovieDetailScreen extends StatelessWidget {
    const MovieDetailScreen({super.key, required this.movieId});

    final int movieId;

    @override
    Widget build(BuildContext context) {
        final movie = findMovieById(movieId);
        final textTheme = Theme.of(context).textTheme;

        if(movie == null) {
            return Scaffold(
                appBar: const CommonAppBar(title: '영화 상세', showBackButton: true),
                body: const Center(child: Text('영화를 찾을 수 없습니다.')),
            );
        }

        return Scaffold(
            appBar: CommonAppBar(title: movie.title, showBackButton: true),
            body: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        AspectRatio(
                            aspectRatio: 2 / 3,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                    movie.posterAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                            child: Icon(Icons.movie_outlined, size: 64, color: AppColors.primary),
                                        );
                                    },
                                ),
                            ),
                        ),
                        const SizedBox(height: 24),
                        Text(movie.title, style: textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('${movie.year} · ${movie.genre}', style: textTheme.bodyMedium),
                    ],
                ),
            ),
        );
    }
}