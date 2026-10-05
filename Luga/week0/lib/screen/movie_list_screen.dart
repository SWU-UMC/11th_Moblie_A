import 'package:flutter/material.dart';
import '../model/movie.dart';
import '../widget/movie_card.dart';
import '../widget/responsive_container.dart';
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
            set.addAll(movie.genreTags);
        }
        return set.toList();
    }

    List<Movie> get _filteredMovies {
        if(_selectedGenre == null) return movies;
        return movies.where((m) => m.genreTags.contains(_selectedGenre)).toList();
    }

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
            body: SafeArea(
                child: ResponsiveContainer(
                    child: Column(
                        children: [
                            // 홈 화면과 동일한 스타일의 커스텀 헤더
                            Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text('영화', style: textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                                        GestureDetector(
                                            onTap: () {},
                                            child: const Icon(Icons.search),
                                        ),
                                    ],
                                ),
                            ),

                            // 장르 칩
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: SizedBox(
                                    height: 40,
                                    child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        // padding: const EdgeInsets.symmetric(horizontal: 24),
                                        itemCount: _genres.length + 1,
                                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                            final isAll = index == 0;
                                            final genre = isAll ? null : _genres[index - 1];
                                            final label = isAll ? '전체' : genre!;
                                            final isSelected = _selectedGenre == genre;

                                            return ChoiceChip(
                                                label: Text(label, overflow: TextOverflow.visible, softWrap: false),
                                                selected: isSelected,
                                                showCheckmark: false, // 선택 시 체크마크 제거
                                                onSelected: (_) {
                                                    setState(() {
                                                        _selectedGenre = genre;
                                                    });
                                                },
                                                selectedColor: AppColors.primary,
                                                labelStyle: TextStyle(
                                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                ),
                                                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                                backgroundColor: AppColors.primaryLight,
                                                shape: const StadiumBorder(),
                                                side: BorderSide.none,
                                            );
                                        },
                                    ),
                                ),
                            ),

                            Expanded(
                                child: _filteredMovies.isEmpty
                                    ? Center(
                                        child: Text('선택한 장르의 영화가 없습니다.', style: textTheme.bodyMedium),
                                    )
                                    : GridView.builder(
                                        padding: const EdgeInsets.all(24),
                                        itemCount: _filteredMovies.length,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 20,
                                            crossAxisSpacing: 16,
                                            childAspectRatio: 0.55,
                                        ),
                                        itemBuilder: (context, index) {
                                            return MovieCard(movie: _filteredMovies[index]);
                                        },
                                    ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}