void main() {
    
    // 영화 리스트 생성
    List<Movie> movies = [
        Movie(title: '오디세이', director: '크리스토퍼 놀란'),
        Movie(title: '기생충', director: '봉준호'),
        Movie(title: '부산행', director: '연상호')
    ];

    // for문 사용
    print('--for 사용하여 출력--');
    for(var movie in movies) {
        print(movie.title);
    }

    // map 사용
    print('--map 사용하여 출력--');
    List<String> titles = movies.map((movie) => movie.title).toList();
    print(titles);

    // nullable 닉네임 -> 완전한 기본값
    String? nickname;
    String safeNickname = nickname ?? '익명의 사용자';
    print('--nullable 처리--');
    print(safeNickname);
}

// Movie class 생성
class Movie {
    final String title;
    final String director;

    Movie({
        required this.title,
        required this.director;
    });
}