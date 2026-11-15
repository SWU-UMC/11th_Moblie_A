// Movie Class 작성
class Movie {
  const Movie({required this.id, required this.title});
  final int id;
  final String title;
}

void main() {
  // 영화 3개를 List<Movie>에 넣기
  final movies = <Movie>[
    const Movie(id: 1, title: '타이타닉'),
    const Movie(id: 2, title: '인터스텔라'),
    const Movie(id: 3, title: '오디세이'),
  ];

  // for 또는 map을 사용해 영화 제목 출력
  print('--- 영화 목록 ---');
  for (final movie in movies) {
    print(movie.title);
  }

  // nullable 닉네임을 안전한 기본값으로 변환
  print('\n--- 닉네임 처리 ---');
  String? nickname; // 현재 값을 지정하지 않아 null 상태
  String safeNickname = nickname ?? '게스트'; 
  print('환영합니다, $safeNickname님!');
}