import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(SudokuApp());

    // Basic check: app renders something
    expect(find.byType(SudokuApp), findsOneWidget);
  });
}