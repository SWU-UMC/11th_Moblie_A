import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/tmdb_genre_dto.dart';
import '../view_model/movie_list_model.dart';
import '../widget/empty_view.dart';
import '../widget/error_view.dart';
import '../widget/loading_view.dart';
import '../widget/responsive_container.dart';
import '../theme/app_colors.dart';
import '../widget/movie_grid.dart';

class MovieListScreen extends StatelessWidget {
    const MovieListScreen({super.key});

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
            body: SafeArea(
                child: ResponsiveContainer(
                    child: Column(
                        children: [
                            Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text(
                                            '영화',
                                            style: textTheme.titleLarge
                                            ?.copyWith(color: AppColors.primary),
                                        ),
                                        GestureDetector(
                                            onTap: () {},
                                            child: const Icon(Icons.search),
                                        ),
                                    ],
                                ),
                            ),

                            const _GenreChips(),
                            const SizedBox(height: 16),

                            Expanded(
                                child: Consumer<MovieListViewModel>(
                                    builder: (context, viewModel, child) {
                                        return switch (viewModel.status) {
                                            MovieListLoadStatus.idle ||
                                            MovieListLoadStatus.loading => 
                                            const LoadingView(),
                                            MovieListLoadStatus.error => ErrorView(
                                                onRetry: () => context.read<MovieListViewModel>().retry(),
                                            ),
                                            MovieListLoadStatus.empty => EmptyView(
                                                message: '아직 등록된 영화가 없어요.',
                                                actionLabel: '새로고침',
                                                onAction: () => context.read<MovieListViewModel>().retry(),
                                            ),
                                            MovieListLoadStatus.success => MovieGrid(
                                                movies: viewModel.movies,
                                                genreNames: {for (final g in viewModel.genres) g.id: g.name},
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
}

class _GenreChips extends StatelessWidget {
    const _GenreChips();

    @override
    Widget build(BuildContext context) {
        final genres = context
            .select<MovieListViewModel, List<TmdbGenreDto>>((vm) => vm.genres);
        final selectedId =
            context.select<MovieListViewModel, int?>((vm) => vm.selectedGenreId);
        final isLoading =
            context.select<MovieListViewModel, bool>((vm) => vm.isLoading);

        if (genres.isEmpty) return const SizedBox(height: 40);

        return IgnorePointer(
            ignoring: isLoading, // 요청 중에는 탭 자체를 막음
            child: AnimatedOpacity(
                opacity: isLoading ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                        height: 40,
                        child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: genres.length + 1, // 0번 = 전체
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                                final genre = index == 0 ? null : genres[index - 1];
                                final isSelected = selectedId == genre?.id;

                                return ChoiceChip(
                                    label: Text(
                                        genre?.name ?? '전체',
                                        overflow: TextOverflow.visible,
                                        softWrap: false,
                                    ),
                                    selected: isSelected,
                                    showCheckmark: false,
                                    onSelected: (_) => context
                                        .read<MovieListViewModel>()
                                        .selectGenre(genre?.id),
                                    selectedColor: AppColors.primary,
                                    backgroundColor: AppColors.primaryLight,
                                    labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                    ),
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                    shape: const StadiumBorder(),
                                    side: BorderSide.none,
                                );
                            },
                        ),
                    ),
                ),
            ),
        );
    }
}