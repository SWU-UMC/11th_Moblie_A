import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/my_ratings_view_model.dart';
import '../themes/app_text_styles.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/movielog_button.dart';
import '../data/models/rating_dto.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  // 평점 삭제 다이얼로그 및 삭제 처리 메서드
  Future<void> onDeletePressed(BuildContext context, RatingDto rating) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 삭제 중 바깥 탭으로 닫히는 것도 막습니다.
      builder: (_) => _DeleteRatingDialog(
        onConfirm: () =>
            context.read<MyRatingsViewModel>().deleteRating(rating.ratingId),
      ),
    );
    // confirmed는 실제로 삭제까지 마쳤을 때만 true입니다.
    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('평점을 삭제했습니다.')),
      );
    }
  }

  // 평점 수정 다이얼로그 및 수정 처리 메서드
  Future<void> onEditPressed(BuildContext context, RatingDto rating) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막습니다.
      builder: (_) => RatingDialog(
        initialScore: rating.score,
        initialComment: rating.comment, // null이면 TextField가 빈 칸으로 시작합니다.
        onSubmit: (score, comment) => context.read<MyRatingsViewModel>().updateRating(
              ratingId: rating.ratingId,
              score: score,
              comment: comment,
            ),
      ),
    );

    if (!context.mounted || saved != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('평점을 수정했습니다.')),
    );
  }

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
                          // 영화 제목 및 수정/삭제 버튼 영역
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  movie?.title ?? '영화 ID: ${rating.movieId}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    onPressed: () => onEditPressed(context, rating),
                                    tooltip: '수정',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                    onPressed: () => onDeletePressed(context, rating),
                                    tooltip: '삭제',
                                  ),
                                ],
                              ),
                            ],
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

class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});
  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        title: const Text('평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          MovieLogButton(
            label: '취소',
            onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          ),
          MovieLogButton(
            label: '삭제',
            isLoading: _isDeleting,
            onPressed: _isDeleting ? null : _onConfirm,
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }
}