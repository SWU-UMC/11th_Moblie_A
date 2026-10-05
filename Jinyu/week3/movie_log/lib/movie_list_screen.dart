import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String selectedGenre = '전체';
  final List<String> genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];

  @override
  Widget build(BuildContext context) {
    final filteredMovies = selectedGenre == '전체' 
        ? mockMovies 
        : mockMovies.where((m) => m.genre.contains(selectedGenre)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('영화', style: TextStyle(color: AppColors.violet, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [IconButton(icon: const Icon(Icons.search, color: AppColors.violet), onPressed: () {})],
      ),
      body: Column(
        children: [
          // 장르 필터 칩 (ListView)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: genres.map((genre) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(genre),
                  selected: selectedGenre == genre,
                  showCheckmark: false,
                  backgroundColor: AppColors.violet.withValues(alpha: 0.1),
                  selectedColor: AppColors.violet,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  labelStyle: TextStyle(color: selectedGenre == genre ? Colors.white : AppColors.gray),
                  onSelected: (selected) {
                    if (selected) setState(() => selectedGenre = genre);
                  },
                ),
              )).toList(),
            ),
          ),
          // 영화 그리드 목록 (GridView)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 24, childAspectRatio: 0.65,
              ),
              itemCount: filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = filteredMovies[index];
                return GestureDetector(
                  onTap: () => context.push('/movies/${movie.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(movie.posterAsset, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8, right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text('${movie.rating}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('${movie.year} · ${movie.genre}', style: const TextStyle(color: AppColors.gray, fontSize: 13)),
                    ],
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