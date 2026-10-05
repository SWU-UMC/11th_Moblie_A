// 1. 변수와 타입
final String appName = 'MovieLog';
const int currentWeek = 0;
var isReady = false;

// 2. 함수와 Named Parameter
String greeting({required String name, int week = 0}) {
  return '$name님, Flutter $week주차를 시작합니다.';
}

// 3. Null Safety
String displayName(String? nickname) {
  return nickname?.trim().isNotEmpty == true ? nickname! : '이름 없음';
}

// 4. Class
class Movie {
  const Movie({required this.id, required this.title});

  final int id;
  final String title;
}

void main() {
  // 5. List와 Map
  final genres = <String>['드라마', 'SF', '애니메이션'];
  final profile = <String, Object>{
    'nickname': '무비러버',
    'week': 0,
  };
  final List<Movie> movies = [
    const Movie(id: 1, title: '인터스텔라'),
    const Movie(id: 2, title: '다크 나이트'),
    const Movie(id: 3, title: '인셉션'),
  ];

  // 테스트
  print('앱 이름: $appName');
  print('준비 상태: $isReady');
  
  // Named Parameter를 사용해 함수 호출
  print(greeting(name: '유진', week: 0)); 
  
  print('장르 리스트: $genres');
  print('프로필 맵: $profile');
  print('--- 영화 목록 ---');
  for (var movie in movies) {
    print(movie.title);
  }
  
  // Null Safety 테스트
  print('닉네임 테스트(null): ${displayName(null)}');
  print('닉네임 테스트(정상): ${displayName('무비러버')}');
}