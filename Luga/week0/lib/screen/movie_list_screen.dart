import 'package:flutter/material.dart';
import '../model/movie.dart';
import '../widget/movie_card.dart';
import '../widget/responsive_container.dart';
import '../theme/app_colors.dart';

class MovieListScreen extends StatefulWidget {
    const MovieListScreen({super.key, required this.service});

    final MovieService service;

    @override
    State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
    static const _prefKey = 'last_selected_genre';

    late Future<List<Movie>> _moviesFuture;
    String? _selectedGenre; // null = 전체

    @override
    void initState() {
        super.initState();
        _moviesFuture = widget.service.fetchMovies();
        _restoreGenre();
    }

    Future<void> _restoreGenre() async {
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString(_prefKey);
        if (!mounted || saved == null) return;
        setState(() => _selectedGenre = saved);
    }

    Future<void> _selectedGenre(String? genre) async {
        setState(() => _selectedGenre = genre);
        final prefs = await SharedPreferences.getInstance();
        if(genre == null) {
            await prefs.remove(_prefKey);
        } else {
            await prefs.setString(_prefKey, genre);
        }
    }

    void _retry() {
        setState(() {
            _moviesFuture = widget.service.fetchMovies();
        });
    }

    List<String> _genresOf(List<Movie> all) {
        final set = <String>{};
        for (final movie in all) {
            set.addAll(movie.genreTags);
        }
        return set.toList();
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

                            Expanded(
                                child: FutureBuilder<List<Movie>>(
                                    future: _moviesFuture,
                                    builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const LoadingView();
                                        }
                                        if (snapshot.hasError) {
                                            return ErrorView(onRetry: _retry);
                                        }

                                        final all = snapshot.data ?? [];
                                        if(all.isEmpty) {
                                            return EmptyView(
                                                message: '아직 등록된 영화가 없어요.',
                                                actionLabel: '새로고침',
                                                onAction: _retry,
                                            );
                                        }

                                        final genres = _genresOf(all);
                                        final selected = genres.contains(_selectedGenre) ? _selectedGenre : null;
                                        final filtered = selected == null ? all : all.where((m) => m.genreTags.contains(selected)).toList();

                                        return Column(
                                            children: [
                                                _buildGenreChips(genres, selected),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                    child: filtered.isEmpty
                                                    ? EmptyView(
                                                        message: '선택한 장르의 영화가 없어요 .',
                                                        actionLabel: '전체 보기',
                                                        onAction: () => _selectGenre(null),
                                                    )
                                                    : GridView.builder(
                                                        padding: const EdgeInsets.all(24),
                                                        itemCount: filtered.length,
                                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 2,
                                                            mainAxisSpacing: 20,
                                                            crossAxisSpacing: 16,
                                                            childAspectRatio: 0.55,
                                                        ),
                                                        itemBuilder: (context, index) => MovieCard(movie: filtered[index]),
                                                    ),
                                                ),
                                            ],
                                        );
                                    }
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildGenreChips(List<String> genres, String? selected) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
                height: 40,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: genres.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final genre = isAll ? null : genres[index - 1];
                        final isSelected = selected == genre;

                        return ChoiceChip(
                            label: Text(isAll ? '전체' : genre!, overflow: TextOverflow.visible, softWrap: false),
                            selected: isSelected,
                            showCheckmark: false,
                            onSelected: (_) => _selectGenre(genre),
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
        );
    }
}