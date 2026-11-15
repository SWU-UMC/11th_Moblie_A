import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/app/movie_log_app.dart';

void main() {
  testWidgets('앱이 정상적으로 뜨는지 확인', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieLogApp());

    expect(find.text('내 프로필'), findsOneWidget);
  });
}