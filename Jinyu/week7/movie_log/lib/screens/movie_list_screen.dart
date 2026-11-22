import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';

import '../themes/app_colors.dart';

import '../view_models/movie_list_view_model.dart';

import '../widgets/movie_card.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '영화',
          style: TextStyle(
            color: AppColors.violet,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: AppColors.violet,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<MovieListViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('전체'),
                        selected:
                            viewModel.selectedGenreId == null,
                        showCheckmark: false,
                        backgroundColor:
                            AppColors.violet.withOpacity(0.1),
                        selectedColor: AppColors.violet,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                        labelStyle: TextStyle(
                          color:
                              viewModel.selectedGenreId == null
                                  ? Colors.white
                                  : AppColors.gray,
                        ),
                        onSelected: (_) {
                          viewModel.changeGenre(null);
                        },
                      ),
                    ),

                    ...viewModel.genres.map(
                      (genre) => Padding(
                        padding:
                            const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(genre.name),
                          selected:
                              viewModel.selectedGenreId ==
                              genre.id,
                          showCheckmark: false,
                          backgroundColor:
                              AppColors.violet
                                  .withOpacity(0.1),
                          selectedColor:
                              AppColors.violet,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          labelStyle: TextStyle(
                            color:
                                viewModel
                                            .selectedGenreId ==
                                        genre.id
                                    ? Colors.white
                                    : AppColors.gray,
                          ),
                          onSelected: (_) {
                            viewModel.changeGenre(
                              genre.id,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: switch (viewModel.status) {
                  MovieListLoadStatus.idle ||
                  MovieListLoadStatus.loading =>
                    const MovieListLoading(),

                  MovieListLoadStatus.error =>
                    MovieListError(
                      onRetry: () {
                        viewModel.loadInitial();
                      },
                    ),

                  MovieListLoadStatus.empty =>
                    const MovieListEmpty(),

                  MovieListLoadStatus.success =>
                    GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.65,
                      ),
                      itemCount:
                          viewModel.movies.length,
                      itemBuilder: (context, index) {
                        final dto =
                            viewModel.movies[index];

                        final movie =
                            dto.toDomain();

                        return MovieCard(
                          movie: movie,
                        );
                      },
                    ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}