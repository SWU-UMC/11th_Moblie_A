import 'package:flutter/foundation.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
enum LoadStatus { loading, success, empty, error }
class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this.service);
  final TmdbMovieService service;
  LoadStatus status = LoadStatus.loading;
  List<TmdbMovieDto> movies = [];
  Future<void> load() async {
    status = LoadStatus.loading; notifyListeners();
    try { movies = (await service.fetchPopular()).results.take(5).toList();
      status = movies.isEmpty ? LoadStatus.empty : LoadStatus.success;
    } catch (_) { status = LoadStatus.error; }
    notifyListeners();
  }
}
class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this.service);
  final TmdbMovieService service;
  LoadStatus status = LoadStatus.loading;
  List<TmdbMovieDto> movies = [];
  List<TmdbGenreDto> genres = [];
  int? selectedGenreId;
  int _version = 0;
  bool _disposed = false;
  Future<void> loadInitial() async {
    try { genres = await service.fetchGenres();
    } catch (_) { status = LoadStatus.error; if (!_disposed) notifyListeners(); return; }
    await selectGenre(selectedGenreId);
  }
  Future<void> selectGenre(int? id) async {
    if (status == LoadStatus.loading && _version > 0) return;
    selectedGenreId = id;
    final v = ++_version;
    status = LoadStatus.loading; notifyListeners();
    try {
      final byId = <int,TmdbMovieDto>{};
      var page = 1;
      while (byId.length < 30) {
        final result = await service.discoverMovies(page: page,genreId:id);
        for (final movie in result.results) { byId[movie.id] = movie; if (byId.length == 30) break; }
        if (result.results.isEmpty || page >= result.totalPages) break;
        page++;
      }
      if (_disposed || v != _version) return;
      movies = byId.values.toList();
      status = movies.isEmpty ? LoadStatus.empty : LoadStatus.success;
    } catch (_) { if (_disposed || v != _version) return; status = LoadStatus.error; }
    if (!_disposed) notifyListeners();
  }
  @override
  void dispose() { _disposed = true; _version++; super.dispose(); }
}
