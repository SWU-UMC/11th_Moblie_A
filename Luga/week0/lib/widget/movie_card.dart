import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/movie.dart';
import '../theme/app_colors.dart';

class MovieCard extends StatelessWidget {
    const MovieCard({super.key, required this.movie});

    final Movie movie;

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;

        return GestureDetector(
            behavior: HitTestBehaivor.opaque,
            onTap: () => context.push('/movies/${movie.id}'),
            child: Container(
                decoration: BoxDecoration(
                    color: AppColors.surfaceLowest,
                    borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        AspectRatio(
                            aspectRatio: 2 / 3,
                            child: Container(
                                color: AppColors.primaryLight,
                                child: Image.asset(
                                    movie.posterAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                            child: Icon(Icons.movie_outlined, size: 40, color: AppColors.primary),
                                        );
                                    },
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        movie.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellopsis,
                                        style: textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${movie.year} · ${movie.genre}',
                                        style: textTheme.bodyMedium,
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}