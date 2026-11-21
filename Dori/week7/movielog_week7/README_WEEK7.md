# MovieLog · UMC Flutter 7주차

## 실행
1. Flutter SDK 설치 후 이 폴더를 VS Code 또는 Android Studio로 엽니다.
2. `.env`에 기존 TMDB 토큰을 설정합니다(원본 .env가 있으면 유지).
3. `flutter pub get`
4. `flutter run`

## 구현
- v7 로그인, flutter_secure_storage JWT 저장, 시작 시 GET me로 세션 복원
- 보호 요청에만 Bearer JWT를 붙이는 Dio interceptor
- 내 정보, 닉네임 수정(409 처리), 로그아웃, 401 만료 처리
- v7 평점 등록/수정/삭제 및 현재 세션 평점 UI
- 기존 TMDB 영화 조회, 회원가입 유지

## API 한계
v7 로그인 응답에는 memberId가 없고, '내 평점 전체 조회' API도 없습니다. 현재 로그인 중 등록한 평점만 마이페이지에서 관리하며, 재시작/재로그인 시 과거 평점 목록은 복원하지 않습니다. 공개 유저별 평점 조회는 memberId가 있는 경우에만 가능합니다.

## 검증
이 환경에는 Flutter SDK가 없어 `flutter analyze` 및 실제 앱 실행 검증은 수행하지 못했습니다. 실행 후 오류가 나오면 로그를 확인해 주세요.

## 주의
토큰이나 비밀번호가 포함된 콘솔/네트워크 캡처는 제출하지 마세요. 실제 기기에서 secure storage 동작을 검증해야 합니다.
