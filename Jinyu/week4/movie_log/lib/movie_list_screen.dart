import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';

import '../services/fake_movie_service.dart';
import '../repositories/genre_preference.dart';
import '../widgets/movie_list_loading.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';


class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FakeMovieService _movieService = const FakeMovieService();
  final GenrePreference _genrePreference = GenrePreference();

  late Future<List<Movie>> _moviesFuture = Future.value([]);

  String _selectedGenre = '전체';
  final List<String> genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // 초기 Future 생성
  Future<void> _loadInitialData() async {
    final savedGenre = await _genrePreference.read();
    if (!mounted) return;

    setState(() {
      _selectedGenre = genres.contains(savedGenre) ? savedGenre : '전체';
      // 5주차 실제 API 교체 위치
      _moviesFuture = _movieService.fetchMovies(mode: MovieLoadMode.success);
      //_moviesFuture = _movieService.fetchMovies(mode: MovieLoadMode.failure); // 실패 모드 테스트 
    });
  }

  // 재시도 시 새로운 Future 생성하여 화면 갱신
  void _retry() {
    setState(() {
      _moviesFuture = _movieService.fetchMovies(mode: MovieLoadMode.success);
    });
  }

  // 장르 선택 시 상태 갱신 및 로컬 저장소에 저장
  Future<void> _onGenreSelected(String genre) async {
    setState(() {
      _selectedGenre = genre;
      _moviesFuture = _movieService.fetchMovies(mode: MovieLoadMode.success);
    });
    await _genrePreference.save(genre);
  }

  @override
  Widget build(BuildContext context) {
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
                  selected: _selectedGenre == genre,
                  showCheckmark: false,
                  backgroundColor: AppColors.violet.withValues(alpha: 0.1),
                  selectedColor: AppColors.violet,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  labelStyle: TextStyle(color: _selectedGenre == genre ? Colors.white : AppColors.gray),
                  onSelected: (selected) {
                    if (selected) _onGenreSelected(genre);
                  },
                ),
              )).toList(),
            ),
          ),
          // 영화 그리드 목록 (GridView)
         Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                // Loading 상태
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const MovieListLoading();
                }

                // Error 상태
                if (snapshot.hasError) {
                  return MovieListError(onRetry: _retry);
                }

                final allMovies = snapshot.data ?? const <Movie>[];

                // 선택된 장르에 맞게 영화 필터링
                final filteredMovies = _selectedGenre == '전체' 
                    ? allMovies 
                    : allMovies.where((m) => m.genre.contains(_selectedGenre)).toList();

                // Empty 상태
                if (filteredMovies.isEmpty) {
                  return const MovieListEmpty();
                }

                // Success 상태 
                return GridView.builder(
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
                );
              },  
            ),
         )
        ],
      ),
    );
  }
}