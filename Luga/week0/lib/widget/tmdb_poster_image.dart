import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TmdbPosterImage extends StatelessWidget {
    const TmdbPosterImage({
        super.key,
        required this.posterPath,
        this.size = 'w500',
        this.fit = BoxFit.cover,
        this.iconSize = 40,
    });

    final String? posterPath;
    final String size; // w342, w500, w780 등
    final BoxFit fit;
    final double iconSize;

    static const _baseUrl = 'https://image.tmdb.org/t/p';

    String? get _imageUrl {
        final path = posterPath;
        if (path == null || path.isEmpty) return null;
        return '$_baseUrl/$size$path';
    }

    @override
    Widget build(BuildContext context) {
        final url = _imageUrl;
        if (url == null) return _placeholder();

        return Image.network(
            url,
            width: double.infinity,
            height: double.infinity,
            fit: fit,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _placeholder(),
            errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
    }

    Widget _placeholder() {
        return ColoredBox(
            color: AppColors.primaryLight,
            child: Center(
                child: Icon(
                    Icons.movie_outlined,
                    size: iconSize,
                    color: AppColors.primary,
                ),
            ),
        );
    }
}