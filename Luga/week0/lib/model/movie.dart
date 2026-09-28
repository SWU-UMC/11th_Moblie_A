class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.genreTags,
    required this.year,
    required this.posterAsset,
    required this.rating,
    this.durationMinutes,
    this.synopsis,
  });

  final int id;
  final String title;
  final String genre; // genreTags 중 대표 장르 (목록 필터링에 사용)
  final List<String> genreTags; // 상세 화면에 보여질 모든 장르 태그
  final int year;
  final String posterAsset;
  final double rating; // 홈·목록·상세에서 공통으로 사용하는 평점

  // 상세 화면 전용 (제공된 정보가 있는 영화만 채움)
  final int? durationMinutes;
  final String? synopsis;

}

const movies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    genreTags: ['로맨스', '드라마', '감동적인'],
    year: 2024,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.5,
    durationMinutes: 124,
    synopsis: 
        '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게되는 따뜻한 이야기입니다.\n
        과거의 아픔으로 인해 사람에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 남주인공을 통해 서서히 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 현실적인 장벽들은 그들의 관계를 시험하게 되는데...\n
        별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요? 눈부신 영상미와 감성적인 OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.'
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    genreTags: ['SF'],
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    genreTags: ['애니메이션'],
    year: 2022,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    genreTags: ['스릴러'],
    year: 2024,
    posterAsset: 'assets/images/posters/134004 poster_night_shadows.jpg',
    rating: 3.8,
  ),
  Movie(
    id: 5,
    title: '봄날의 커피',
    genre: '로맨스',
    genreTags: ['로맨스'],
    year: 2021,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.5,
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) return movie;
  }
  return null;
}