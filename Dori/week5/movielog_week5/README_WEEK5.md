# UMC Flutter 5주차 빠른 실행

1. `movielog_week5` 폴더를 Android Studio 또는 VS Code로 엽니다.
2. `.env`의 `REPLACE_WITH_YOUR_TMDB_READ_ACCESS_TOKEN`을 본인 TMDB **API Read Access Token**으로 변경합니다. 토큰을 Git에 올리지 마세요.
3. 터미널에서 `flutter pub get` → `flutter run` → `flutter analyze`를 실행합니다.
4. 홈 탭 인기 영화 5개, 영화 탭 최대 30개, 장르 선택 전후 요청을 확인하고 캡처합니다.
5. 오류 상태 검증은 인터넷을 끈 상태에서 다시 실행해 확인할 수 있습니다. Empty/포스터 null은 별도 테스트 데이터로 검증해야 합니다.

**주의:** 기존 4주차의 실제 평점 Dialog는 제공된 프로젝트에 없어 영화 카드 상세 팝업에 TMDB ID 전달만 구현했습니다. 실기기 실행/네트워크 결과 및 flutter analyze는 사용자 환경에서 확인해야 합니다.
