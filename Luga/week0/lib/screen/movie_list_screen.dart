import 'package:flutter/material.dart';
import '../model/movie.dart';
import '../widget/movie_card.dart';
import '../widget/common_app_bar.dart';
import '../theme/app_colors.dart';

class MovieListScreen extends StatefulWidget {
    const MovieListScreen({super.key});

    @override
    State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
    String? _selectedGenre; // null = 전체

    List<String> get _genres {
        final set = <String>{};
        for(final movie in movies) {
            set.add(movie.genre);
        }
        return set.toList();
    }

    List<Movie> get _filteredMovies {
        if(_selectedGenre == null) return movies;
        return movies.where((m) => m.genre == _selectedGenre).toList();
    }

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
            appBar: const CommonAppBar(title: '영화'),
            body: Column(
                children: [
                    // 장르 칩
                    SizedBox(
                        height: 48,
                        child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            itemCount: _genres.length + 1,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                                final isAll = index == 0;
                                final genre = isAll ? null : _genres[index - 1];
                                final label = isAll ? '전체' : genre!;
                                final selected = _selectedGenre == genre;

                                return ChoiceChip(
                                    label: Text(label),
                                    selected: selected,
                                    onSelected: (_) {
                                        setState(() {
                                            _selectedGenre = genre;
                                        });
                                    },
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                        color: selected ? Colors.white : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                    ),
                                    backgroundColor: AppColors.surfaceContainer,
                                    shape: const StadiumBorder(),
                                    side: BorderSide.none,
                                );
                            },
                        ),
                    ),

                    // 영화 목록 (GridView)
                    Expanded(
                        child: _filteredMovies.isEmpty
                            ? Center(
                                child: Text('해당 장르의 영화가 없어요', style: textTheme.bodyMedium),
                            )
                            : GridView.builder(
                                padding: const EdgeInsets.all(24),
                                itemCount: _filteredMovies.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 0.6,
                                ),
                                itemBuilder: (context, index) {
                                    return MovieCard(movie: _filteredMovies[index]);
                                },
                            ),
                    ),
                ],
            ),
        );
    }
}