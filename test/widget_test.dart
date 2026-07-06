import 'package:flutter_test/flutter_test.dart';

import 'package:ciantis_basic/main.dart';
import 'package:ciantis_basic/screens/dashboard_screen.dart';

void main() {
  testWidgets('dashboard renders the base CIANTIS screen', (tester) async {
    await tester.pumpWidget(const CiantisApp());

    expect(find.text('C I A N T I S'), findsOneWidget);
    expect(find.text(DailyVerse.today().text), findsOneWidget);
    expect(find.text('Add reminder'), findsOneWidget);
    expect(find.bySemanticsLabel('Spaces'), findsOneWidget);
    expect(find.bySemanticsLabel('Calendar'), findsOneWidget);
    expect(find.bySemanticsLabel('Notes'), findsOneWidget);
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    expect(find.text('Spaces'), findsNothing);
    expect(find.text('Calendar'), findsNothing);
    expect(find.text('Notes'), findsNothing);
    expect(find.text('Settings'), findsNothing);
    expect(find.text('At a glance'), findsNothing);
  });

  testWidgets('universal grid menu opens and switches views', (tester) async {
    await tester.pumpWidget(const CiantisApp());

    await tester.tap(find.bySemanticsLabel('Grid menu'));
    await tester.pumpAndSettle();

    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Grid'), findsNothing);
    expect(find.text('List'), findsNothing);
    expect(find.text('By Space'), findsNothing);
  });
}
