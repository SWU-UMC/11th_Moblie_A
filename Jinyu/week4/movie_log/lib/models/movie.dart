class Movie {
  final int id;
  final String title;
  final String originalTitle;
  final String genre;
  final int year;
  final int duration;
  final double rating;
  final String synopsis;
  final String posterAsset; // 세로 포스터 (목록용)
  final String? bannerAsset; // 가로 배너 (상세화면 및 홈 카드용)

  const Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.genre,
    required this.year,
    required this.duration,
    required this.rating,
    required this.synopsis,
    required this.posterAsset,
    this.bannerAsset,
  });
}

const List<Movie> mockMovies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    originalTitle: 'US UNDER THE STARLIGHT',
    genre: '로맨스/드라마',
    year: 2023,
    duration: 120,
    rating: 4.5,
    synopsis: '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 과거의 상처를 치유하고, 별자리처럼 변함없는 서로의 모습을 통해 닫혀있던 마음의 문을 서서히 열어가는 따뜻한 로맨스 이야기입니다.',
    posterAsset: 'assets/images/poster_starlight.jpg', // 세로 포스터
    bannerAsset: 'assets/images/hero_starlight.jpg',    // 가로로 긴 배너 이미지
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    originalTitle: 'ECHOS OF THE VOID',
    genre: 'SF',
    year: 2024,
    duration: 130,
    rating: 4.2,
    synopsis: '인류의 마지막 희망을 품고 미지의 우주 공간으로 떠난 탐험대원들이 겪는 경이롭고도 험난한 여정을 그립니다. 예상치 못한 위협 속에서 대원들은 생존을 위한 사투를 벌이며, 우주 깊은 곳에 얽힌 거대한 비밀과 마주하게 되는 SF 대작입니다.',
    posterAsset: 'assets/images/poster_void.jpg',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    originalTitle: 'WHISPERING WOODS',
    genre: '애니메이션',
    year: 2022,
    duration: 110,
    rating: 4.9,
    synopsis: '우연히 신비로운 정령들이 살고 있는 기억의 숲에 발을 들인 주인공이 잃어버린 자신의 과거와 마주하는 모험을 담았습니다. 신비로운 마법과 따뜻한 우정이 어우러진 숲속 여정을 통해 진정한 자아를 찾아가는 감동적인 애니메이션입니다.',
    posterAsset: 'assets/images/poster_woods.jpg',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    originalTitle: 'NIGHT SHADOWS',
    genre: '스릴러',
    year: 2024,
    duration: 145,
    rating: 3.8,
    synopsis: '화려한 네온사인 뒤에 숨겨진 도시의 어둠 속에서 연쇄적으로 벌어지는 미스터리한 사건들을 파헤치는 형사의 이야기입니다. 단서가 사라진 미궁의 사건을 쫓으며 끝없는 추격전이 이어지고, 상상조차 하지 못한 충격적인 진실과 마주하게 되는 숨 막히는 스릴러입니다.',
    posterAsset: 'assets/images/poster_shadows.jpg',
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}