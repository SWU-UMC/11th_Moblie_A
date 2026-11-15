import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/my_ratings_view_model.dart';
import '../themes/app_text_styles.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 등록한 평점'),
        centerTitle: true,
      ),
      // bottomNavigationBar는 전달하지 않습니다 (루트 네비게이터로 열리기 때문에 하단 탭바가 가려짐)
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.status) {
            case MyRatingsLoadStatus.idle:
            case MyRatingsLoadStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );

            case MyRatingsLoadStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    viewModel.message ?? '평점을 불러오지 못했습니다.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              );

            case MyRatingsLoadStatus.empty:
              return const Center(
                child: Text(
                  '등록된 평점이 없습니다.',
                  style: AppTextStyles.bodyMedium,
                ),
              );

            case MyRatingsLoadStatus.success:
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.ratings.length,
                itemBuilder: (context, index) {
                  final entry = viewModel.ratings[index];
                  final rating = entry.rating;
                  final movie = entry.movie;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 영화 제목 (영화 정보가 없으면 movieId로 대신 표시)
                          Text(
                            movie?.title ?? '영화 ID: ${rating.movieId}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('평점: ${rating.score}점'),
                          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('후기: ${rating.comment}'),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}