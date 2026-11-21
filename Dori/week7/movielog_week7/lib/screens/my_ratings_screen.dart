
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_with_movie.dart';
import '../data/services/rating_api_service.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/rating_dialog.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, false),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, true),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _editRating(
    BuildContext context,
    RatingWithMovie entry,
  ) async {
    final vm = context.read<MyRatingsViewModel>();
    final rating = entry.rating;

    String? refreshWarning;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        title: '평점 수정',
        initialScore: rating.score.toInt(),
        initialComment: rating.comment,
        onSubmit: (input) async {
          try {
            refreshWarning = await vm.updateRating(
              ratingId: rating.ratingId,
              score: input.score,
              comment: input.comment,
            );
          } on DioException catch (error) {
            throw Exception(
              writeMyRatingsErrorMessage(error),
            );
          }
        },
      ),
    );

    if (!context.mounted) return;

    if (saved == true) {
      _showMessage(
        context,
        refreshWarning ?? '평점이 수정되었습니다.',
      );
    }
  }

  Future<void> _deleteOne(
    BuildContext context,
    RatingWithMovie entry,
  ) async {
    final confirmed = await _confirmDelete(
      context,
      title: '평점 삭제',
      content: '이 영화의 평점을 삭제할까요?',
    );

    if (!confirmed || !context.mounted) return;

    final vm = context.read<MyRatingsViewModel>();

    try {
      final warning = await vm.deleteRating(
        entry.rating.ratingId,
      );

      if (!context.mounted) return;

      _showMessage(
        context,
        warning ?? '평점이 삭제되었습니다.',
      );
    } on DioException catch (error) {
      _showMessage(
        context,
        writeMyRatingsErrorMessage(error),
      );
    } catch (_) {
      _showMessage(context, '평점 삭제에 실패했습니다.');
    }
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final vm = context.read<MyRatingsViewModel>();
    final count = vm.selectedCount;

    if (count == 0) return;

    final confirmed = await _confirmDelete(
      context,
      title: '선택한 평점 삭제',
      content: '선택한 $count개의 평점을 삭제할까요?',
    );

    if (!confirmed || !context.mounted) return;

    final result = await vm.deleteSelected();

    if (!context.mounted) return;

    if (result.failedCount > 0) {
      _showMessage(
        context,
        '${result.deletedCount}개 삭제 완료, '
        '${result.failedCount}개 삭제 실패. '
        '실패한 항목은 선택 상태로 남아 있습니다.',
      );
    } else if (result.refreshFailed) {
      _showMessage(
        context,
        '삭제는 완료됐지만 목록 새로고침에 실패했습니다. '
        '다시 시도해 주세요.',
      );
    } else {
      _showMessage(
        context,
        '${result.deletedCount}개 평점이 삭제되었습니다.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyRatingsViewModel>(
      builder: (context, vm, _) {
        return PopScope(
          canPop: !vm.isDeleting,
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text('내가 등록한 평점'),
                  centerTitle: true,
                  actions: [
                    if (vm.status == MyRatingsLoadStatus.success)
                      TextButton(
                        onPressed: vm.isDeleting
                            ? null
                            : vm.toggleEditMode,
                        child: Text(
                          vm.isEditMode ? '취소' : '편집',
                        ),
                      ),
                  ],
                ),
                body: _buildBody(context, vm),
                bottomNavigationBar:
                    vm.isEditMode &&
                            vm.status == MyRatingsLoadStatus.success
                        ? SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: FilledButton(
                                onPressed: vm.selectedCount == 0 ||
                                        vm.isDeleting
                                    ? null
                                    : () => _deleteSelected(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  padding: const EdgeInsets.all(16),
                                ),
                                child: Text(
                                  '선택한 ${vm.selectedCount}개 삭제',
                                ),
                              ),
                            ),
                          )
                        : null,
              ),
              if (vm.isDeleting) ...[
                const ModalBarrier(
                  dismissible: false,
                  color: Colors.black54,
                ),
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    MyRatingsViewModel vm,
  ) {
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
                onPressed: vm.isDeleting ? null : vm.load,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );

      case MyRatingsLoadStatus.success:
        return Column(
          children: [
            if (vm.isEditMode)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${vm.selectedCount}개 선택됨',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            if (vm.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Text(vm.message!),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vm.ratings.length,
                itemBuilder: (context, index) {
                  final entry = vm.ratings[index];
                  return _ratingCard(context, vm, entry);
                },
              ),
            ),
          ],
        );
    }
  }

  Widget _ratingCard(
    BuildContext context,
    MyRatingsViewModel vm,
    RatingWithMovie entry,
  ) {
    final rating = entry.rating;
    final movie = entry.movie;
    final selected =
        vm.selectedIds.contains(rating.ratingId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: vm.isEditMode
            ? () => vm.toggleSelection(rating.ratingId)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vm.isEditMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Checkbox(
                    value: selected,
                    onChanged: vm.isDeleting
                        ? null
                        : (_) => vm.toggleSelection(
                              rating.ratingId,
                            ),
                  ),
                ),
              SizedBox(
                width: 75,
                height: 112,
                child: movie?.posterPath == null
                    ? const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.movie),
                      )
                    : Image.network(
                        'https://image.tmdb.org/t/p/w185'
                        '${movie!.posterPath}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.movie),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie?.title ??
                          '영화 ID: ${rating.movieId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('⭐ ${rating.score} / 5'),
                    const SizedBox(height: 8),
                    if (rating.comment != null &&
                        rating.comment!.isNotEmpty)
                      Text(rating.comment!),
                    const SizedBox(height: 8),
                    Text(
                      '등록일: '
                      '${rating.createdAt.toLocal().toString().split(' ').first}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    if (!vm.isEditMode) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () =>
                                _editRating(context, entry),
                            child: const Text('수정'),
                          ),
                          TextButton(
                            onPressed: () =>
                                _deleteOne(context, entry),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
