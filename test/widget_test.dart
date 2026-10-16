
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/main.dart';

void main() {
  testWidgets('Taskly app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const TasklyApp());

    expect(find.text('Taskly'), findsWidgets);
  });
}
