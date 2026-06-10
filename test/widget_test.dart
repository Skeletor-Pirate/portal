import 'package:flutter_test/flutter_test.dart';
import 'package:academic_architect/main.dart';
import 'package:academic_architect/screens/login_screen.dart';

void main() {
  testWidgets('App renders LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const AcademicArchitectApp());
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
