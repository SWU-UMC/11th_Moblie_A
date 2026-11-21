import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';
import '../services/fake_movie_service.dart';
import 'home_screen.dart';
import 'my_page_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FakeMovieService _service = const FakeMovieService();
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  late Future<List<Movie>> _moviesFuture;

  String _selectedGenre = '전체';
  

  // 기본 선택 탭: 영화
  int _selectedTab = 1;

  final List<String> _genres = [
    '전체',
    '드라마',
    'SF',
    '판타지',
    '액션',
  ];

  @override
  void initState() {
    super.initState();

    _moviesFuture = _service.fetchMovies();
    _restoreGenre();
  }

  // 저장된 장르 복원
  Future<void> _restoreGenre() async {
    final savedGenre = await _prefs.getString('selected_genre');

    if (!mounted) return;

    if (savedGenre != null && _genres.contains(savedGenre)) {
      setState(() {
        _selectedGenre = savedGenre;
      });
    }
  }

  // 장르 선택 및 저장
  Future<void> _selectGenre(String genre) async {
    setState(() {
      _selectedGenre = genre;
    });

    await _prefs.setString('selected_genre', genre);
  }

  // 영화 목록 다시 불러오기
  void _reload(MovieLoadMode mode) {
    setState(() {
      _moviesFuture = _service.fetchMovies(mode: mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        title: Text(
          _selectedTab == 0
              ? '홈'
              : _selectedTab == 1
                  ? '영화'
                  : '마이',
          style: const TextStyle(
            color: Color(0xFF6B52A3),
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: _selectedTab == 1
            ? [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                PopupMenuButton<MovieLoadMode>(
                  tooltip: '로딩 상태 테스트',
                  onSelected: _reload,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: MovieLoadMode.success,
                      child: Text('Success 테스트'),
                    ),
                    PopupMenuItem(
                      value: MovieLoadMode.empty,
                      child: Text('Empty 테스트'),
                    ),
                    PopupMenuItem(
                      value: MovieLoadMode.failure,
                      child: Text('Error 테스트'),
                    ),
                  ],
                ),
              ]
            : null,
      ),

      // 홈 / 영화 / 마이 화면 전환
      body: IndexedStack(
        index: _selectedTab,
        children: [
          const HomeScreen(),
          _buildMovieContent(),
          const MyPageScreen(),
        ],
      ),

      // 하단 내비게이션
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFFAF9F6),
        indicatorColor: const Color(0xFFE8DFF4),
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: '영화',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }

  // 영화 탭 화면
  Widget _buildMovieContent() {
    return Column(
      children: [
        const SizedBox(height: 12),

        // 장르 필터 칩
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _genres.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final genre = _genres[index];
              final selected = _selectedGenre == genre;

              return ChoiceChip(
                label: Text(genre),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => _selectGenre(genre),
                backgroundColor: const Color(0xFFE9E5EB),
                selectedColor: const Color(0xFF6B52A3),
                side: BorderSide.none,
                shape: const StadiumBorder(),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF514B58),
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 비동기 영화 목록
        Expanded(
          child: FutureBuilder<List<Movie>>(
            future: _moviesFuture,
            builder: (context, snapshot) {
              // 1. Loading
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6B52A3),
                  ),
                );
              }

              // 2. Error
              if (snapshot.hasError) {
                return _buildMessage(
                  icon: Icons.error_outline,
                  message: '영화를 불러오지 못했어요.',
                  buttonText: '다시 시도',
                  onPressed: () => _reload(MovieLoadMode.success),
                );
              }

              final movies = snapshot.data ?? [];

              // 장르 필터링
              final filteredMovies = _selectedGenre == '전체'
                  ? movies
                  : movies
                      .where((movie) => movie.genre == _selectedGenre)
                      .toList();

              // 3. Empty
              if (filteredMovies.isEmpty) {
                return _buildMessage(
                  icon: Icons.movie_filter_outlined,
                  message: '해당 장르의 영화가 없어요.',
                );
              }

              // 4. Success
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.55,
                ),
                itemCount: filteredMovies.length,
                itemBuilder: (context, index) {
                  final movie = filteredMovies[index];

                  return _MovieCard(movie: movie);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Empty / Error 안내 화면
  Widget _buildMessage({
    required IconData icon,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: const Color(0xFF6B52A3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 15),
          ),
          if (buttonText != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ],
        ],
      ),
    );
  }
}

// 영화 카드
class _MovieCard extends StatelessWidget {
  const _MovieCard({
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 영화 포스터
        Expanded(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E5EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: movie.posterAsset.isNotEmpty
                    ? Image.asset(
                        movie.posterAsset,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('❌ 이미지 경로: ${movie.posterAsset}');
                          debugPrint('❌ 오류 원인: $error');

                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.red,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.movie_outlined,
                          size: 48,
                        ),
                      ),
              ),

              // 별점 배지
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B5660),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 13,
                      ),
                      SizedBox(width: 3),
                      Text(
                        '4.8',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 영화 제목
        Text(
          movie.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 3),

        // 개봉 연도 및 장르
        Text(
          '${movie.year} · ${movie.genre}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF858087),
          ),
        ),
      ],
    );
  }
}