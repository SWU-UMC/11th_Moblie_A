
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/my_ratings_view_model.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 등록한 평점'),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, vm, child) {
          switch (vm.status) {
            case MyRatingsLoadStatus.idle:
            case MyRatingsLoadStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );

            case MyRatingsLoadStatus.empty:
              return const Center(
                child: Text('등록된 평점이 없습니다.'),
              );

            case MyRatingsLoadStatus.error:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      vm.message ?? '오류가 발생했습니다.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: vm.load,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              );

            case MyRatingsLoadStatus.success:
              return Column(
                children: [
                  if (vm.message != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(vm.message!),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.ratings.length,
                      itemBuilder: (context, index) {
                        final entry = vm.ratings[index];
                        final rating = entry.rating;
                        final movie = entry.movie;

                        final posterPath = movie?.posterPath;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 120,
                                  child: posterPath == null
                                      ? const ColoredBox(
                                          color: Colors.black12,
                                          child: Icon(Icons.movie),
                                        )
                                      : Image.network(
                                          'https://image.tmdb.org/t/p/w185$posterPath',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.movie),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie?.title ??
                                            '영화 ID: ${rating.movieId}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('평점: ${rating.score}점'),
                                      const SizedBox(height: 8),
                                      if (rating.comment != null &&
                                          rating.comment!.isNotEmpty)
                                        Text(rating.comment!),
                                      const SizedBox(height: 8),
                                      Text(
                                        '등록일: ${rating.createdAt.toLocal().toString().split(' ').first}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
