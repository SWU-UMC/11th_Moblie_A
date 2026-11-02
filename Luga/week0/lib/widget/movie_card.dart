import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    this.genreNames = const {},
    });

  final TmdbMovieDto movie;
  final Map<int, String> genreNames;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final posterUrl = movie.posterUrl;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/movies/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: AppColors.primaryLight,
                      child: posterUrl == null
                      ? const _PosterPlaceholderOP
                      : image.network(
                        posterUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) => progress == null ? child : const _PosterPlaceholder(),
                        errorBuilder: (context, error, stackTrace) => const _PosterPlaceholder(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title.isEmpty ? '제목 없음' : movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            _subtitle(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    final date = movie.releaseDate;
    final year = (date == null || date.length < 4) ? '' : date.substring(0, 4);
    final genre = movie.genreIds
        .map((id) => genreNames[id])
        .whereType<String>()
        .firstOrNull;
    return [year, genre].where((s) => s != null && s.isNotEmpty).join(' · ');
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.movie, size: 40, color: AppColors.primary),
    );
  }
}