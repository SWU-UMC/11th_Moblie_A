import 'dart:async';

enum MovieListLoadStatus { idle, loading, success, empty, error }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);
  static const _prefKey = 'last_selected_genre_id';

  final TmdbMovieService _service;
  final _prefs = SharedPreferencesAsync();

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId;
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message;

  int _requestVersion = 0;
  bool _disposed = false;

  bool _isStale(int version) => _disposed || version != _requestVersion;

  Future<void> loadInitial() async {
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    notifyListeners();

    try {
      final fetched = await _servie.fetchGenres();
      final saved = await _prefs.getInt(_prefKey);
      if(_isStale(version)) return;
      genres = fetched;

      selectedGenreId = fetched.any((g) => g.id == saved) ? saved : null;
    } catch(_) {
       if (_isStale(version)) return;
      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
      notifyListeners();
      return;
    }
    await _loadMovies(version);
  }

  Future<void> selectGenre(int? genreId) async {
    selectedGenreId = genreId;
    unawaited(_saveGenre(genreId)); // 저장을 기다리느라 로딩 표시가 늦어지지 않게
    await _loadMovies();
  }

  /// ErrorView / EmptyView 재시도용: 현재 선택된 장르를 유지
  Future<void> retry() =>
      genres.isEmpty ? loadInitial() : _loadMovies();

  Future<void> _saveGenre(int? id) async {
    try {
      id == null
          ? await _prefs.remove(_prefKey)
          : await _prefs.setInt(_prefKey, id);
    } catch (_) {/* 저장 실패는 화면 동작에 영향 없음 */}
  }

  Future<void> _loadMovies() async {
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    notifyListeners();

    try {
      final result = await _fetchUpToThirtyMovies(version);
      if (_isStale(version)) return;
      movies = result;
      status = result.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } catch (_) {
      if (_isStale(version)) return;
      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
    }
    notifyListeners();
  }

  Future<List<TmdbMovieDto>> _fetchUpToThirtyMovies(int version) async {
    final byId = <int, TmdbMovieDto>{};
    var pageNumber = 1;
    var hasNextPage = true;

    while (byId.length < 30 && hasNextPage) {
      final page = await _service.discoverMovies(
        page: pageNumber,
        genreId: selectedGenreId,
      );
      if (_isStale(version)) return const []; // 이미 무효화된 요청은 중단

      for (final movie in page.results) {
        byId[movie.id] = movie;
        if (byId.length == 30) break;
      }
      hasNextPage = pageNumber < page.totalPages && page.results.isNotEmpty;
      pageNumber++;
    }
    return byId.values.toList();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}