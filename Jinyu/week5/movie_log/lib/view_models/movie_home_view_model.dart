import 'package:flutter/material.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieHomeLoadStatus {
  idle,
  loading,
  success,
  empty,
  error,
}

class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this._service);

  final TmdbMovieService _service;

  List<TmdbMovieDto> popular = [];
  MovieHomeLoadStatus status = MovieHomeLoadStatus.idle;
  String? message;

  // 1. disposed 상태를 추적할 변수 추가
  bool _disposed = false;

  Future<void> loadPopular() async {
    status = MovieHomeLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final page = await _service.fetchPopular(
        page: 1,
      );

      // 2. 데이터가 도착했을 때 이미 화면이 사라졌다면 이후 코드를 실행하지 않고 중단
      if (_disposed) return;

      popular = page.results.take(5).toList();

      status = popular.isEmpty
          ? MovieHomeLoadStatus.empty
          : MovieHomeLoadStatus.success;
    } catch (_) {
      // 3. 에러 발생 시에도 화면이 사라졌다면 중단
      if (_disposed) return;

      status = MovieHomeLoadStatus.error;
      message = '인기 영화를 불러오지 못했습니다.';
    }

    // 4. 화면이 살아있을 때만 notifyListeners 호출
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // 👇 5. ViewModel이 파기될 때 _disposed를 true로 변경
    _disposed = true;
    super.dispose();
  }
}