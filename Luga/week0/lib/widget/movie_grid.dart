import 'package:flutter/material.dart';
import '../model/movie.dart';
import 'movie_card.dart';

class MovieGrid extends StatelessWidget {
    const MovieGrid({super.key, required this.movies});

    final List<Movie> movies;

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
            itemBuilder: (context, index) => MovieCard(movie: movies[index]),
        );
    }
}