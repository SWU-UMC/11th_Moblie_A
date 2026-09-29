
// ignore_for_file: avoid_print
class Movie {
  const Movie({
    required this.id,
    required this.title,
  });

  final int id;
  final String title;
}

void main() {
  // 영화 3개를 List<Movie>에 저장
  final movies = <Movie>[
    const Movie(id: 1, title: '어벤져스'),
    const Movie(id: 2, title: '인사이드 아웃'),
    const Movie(id: 3, title: '인터스텔라'),
  ];

  // 영화 제목 출력
  for (final movie in movies) {
    print(movie.title);
  }

  // nullable 닉네임을 안전한 기본값으로 변환
  String? nickname;
  final safeNickname = nickname ?? '게스트';

  print('닉네임: $safeNickname');
}