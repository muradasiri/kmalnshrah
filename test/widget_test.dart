import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kmalnshrah/baloot_calculator_page.dart';
import 'package:kmalnshrah/main.dart';
import 'package:kmalnshrah/diwaniya/player_provider.dart'; // استيراد صفحة حاسبة بلوت

void main() {
  testWidgets('HomePage has three cards with correct texts', (WidgetTester tester) async {
    await tester.pumpWidget(KmalnshrahApp(localUserId: '',));

    expect(find.text('كم النشرة'), findsOneWidget);
    expect(find.text('حاسبة بلوت'), findsOneWidget);
    expect(find.text('دقة الولد'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);

  });

  testWidgets('Navigates to BalootCalculatorPage when "حاسبة بلوت" card is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(KmalnshrahApp(localUserId: '',));

    await tester.tap(find.text('حاسبة بلوت'));
    await tester.pumpAndSettle();

    expect(find.byType(BalootCalculatorPage), findsOneWidget);
  });

  // إضافة اختبارات أخرى كما تراه مناسباً
}
