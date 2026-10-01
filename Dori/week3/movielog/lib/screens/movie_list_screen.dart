import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String selectedGenre = '전체';

  final List<String> genres = [
    '전체',
    '애니메이션',
    'SF',
    '미스터리',
    '판타지',
    '액션',
    '드라마',
  ];

  void _showGenreBottomSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '장르 선택',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      itemCount: genres.length,
                      itemBuilder: (context, index) {
                        final genre = genres[index];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(genre),
                          trailing: selectedGenre == genre
                              ? const Icon(
                                  Icons.check,
                                  color: Color(0xFF6750A4),
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              selectedGenre = genre;
                            });

                            Navigator.pop(bottomSheetContext);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = selectedGenre == '전체'
        ? mockMovies
        : mockMovies
            .where((movie) => movie.genre == selectedGenre)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFAF9F5),
        title: const Text(
          '영화',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showGenreBottomSheet,
            icon: const Icon(Icons.tune),
            tooltip: '장르 필터',
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 장르 Chip
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = genre == selectedGenre;

                return ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedGenre = genre;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 선택된 장르
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              selectedGenre == '전체'
                  ? '전체 영화'
                  : '$selectedGenre 영화',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 영화 목록
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: filteredMovies.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final movie = filteredMovies[index];

                return GestureDetector(
                  onTap: () {
                    context.push('/movies/${movie.id}');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE8E5E1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E0F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.movie_outlined,
                            size: 32,
                            color: Color(0xFF6750A4),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                movie.genre,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF777777),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${movie.year}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF999999),
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
    );
  }
}