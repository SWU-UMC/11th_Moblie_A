import 'package:flutter/material.dart';
import '../model/tmdb_movie_dto.dart';
import 'movie_card.dart';

class MovieGrid extends StatelessWidget {
    const MovieGrid({
        super.key, 
        required this.movies,
        this.genreNames = const {},
    });

    final List<Movie> movies;
    final Map<int, String> genreNames;

    @override
    Widget build(BuildContext context) {
        return GridView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: movies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                childAspectRatio: 0.55,
            ),
            itemBuilder: (context, index) {
                final movie = movies[index];
                return MovieCard(
                    key: ValueKey(movie.id),
                    movie: movie,
                    genreNames: genreNames,
                );
            },
        );
    }
}