import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/movie.dart';
import '../service/movie_service.dart';
import '../widget/empty_view.dart';
import '../widget/error_view.dart';
import '../widget/loading_view.dart';
import '../widget/responsive_container.dart';
import '../theme/app_colors.dart';
import '../widget/movie_grid.dart';

class MovieListScreen extends StatefulWidget {
    const MovieListScreen({super.key});

    @override
    State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
    static const _prefKey = 'last_selected_genre';

    final _prefs = SharedPreferencesAsync();

    String? _selectedGenre; // null = 전체

    @override
    void initState() {
        super.initState();
        _restoreGenre();
    }

    Future<void> _restoreGenre() async {
        final saved = await _prefs.getString(_prefKey);
        if (!mounted || saved == null) return;
        setState(() => _selectedGenre = saved);
    }

    Future<void> _selectGenre(String? genre) async {
        setState(() => _selectedGenre = genre);
        if(genre == null) {
            await _prefs.remove(_prefKey);
        } else {
            await _prefs.setString(_prefKey, genre);
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
                                child: Consumer<MovieListViewModel>(
                                    builder: (context, viewModel, child) {
                                        return switch (viewModel.status) {
                                            MovieListLoadStatus.idle ||
                                            MovieListLoadStatus.loading => const LoadingView(),
                                            MovieListLoadStatus.error => ErrorView(
                                                onRetry: () => context.read<MovieListViewModel>().loadInitial(),
                                            ),
                                            MovieListLoadStatus.empty => EmptyView(
                                                message: '아직 등록된 영화가 없어요.',
                                                actionLabel: '새로고침',
                                                onAction: () => context.read<MovieListViewModel>().loadInitial(),
                                            ),
                                            MovieListLoadStatus.success => MovieGrid(
                                                movies: viewModel.movies,
                                            ),
                                        };
                                    },
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