import '../models/movie.dart';

const List<Movie> mockMovies = [
  Movie(
    id: '1',
    title: '인사이드 아웃 2',
    genre: '애니메이션',
    year: 2024,
    posterAsset: '',
  ),
  Movie(
    id: '2',
    title: '듄: 파트 2',
    genre: 'SF',
    year: 2024,
    posterAsset: '',
  ),
  Movie(
    id: '3',
    title: '파묘',
    genre: '미스터리',
    year: 2024,
    posterAsset: '',
  ),
  Movie(
    id: '4',
    title: '웡카',
    genre: '판타지',
    year: 2024,
    posterAsset: '',
  ),
  Movie(
    id: '5',
    title: '범죄도시4',
    genre: '액션',
    year: 2024,
    posterAsset: '',
  ),
  Movie(
    id: '6',
    title: '서울의 봄',
    genre: '드라마',
    year: 2023,
    posterAsset: '',
  ),
];

Movie? findMovieById(String id) {
  for (final movie in mockMovies) {
    if (movie.id == id) {
      return movie;
    }
  }
  return null;
}