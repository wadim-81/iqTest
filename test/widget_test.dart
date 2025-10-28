import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:iq_test/main.dart';
import 'package:iq_test/providers/quiz_provider.dart';

void main() {
  testWidgets('App starts and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that home screen is displayed
    expect(find.textContaining('IQ Test'), findsOneWidget);
    expect(find.text('Начать тест'), findsOneWidget);
    expect(find.text('Выберите язык'), findsOneWidget);
  });

  testWidgets('Language selection works', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Find and tap the language dropdown
    final dropdownFinder = find.byType(DropdownButton<String>);
    expect(dropdownFinder, findsOneWidget);
    
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    // Verify language options are available
    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
  });

  testWidgets('Start test navigates to quiz screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Tap the start button
    await tester.tap(find.text('Начать тест'));
    await tester.pumpAndSettle();

    // Verify we're on quiz screen
    expect(find.text('Вопрос'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('Answering questions progresses through quiz', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Start the test
    await tester.tap(find.text('Начать тест'));
    await tester.pumpAndSettle();

    // Answer first question
    final firstAnswer = find.byType(Card).first;
    await tester.tap(firstAnswer);
    await tester.pumpAndSettle();

    // Should be on next question or results
    expect(find.text('Вопрос'), findsOneWidget);
  });

  testWidgets('Quiz provider state management', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify provider is initialized correctly
    final provider = tester.widget<ChangeNotifierProvider<QuizProvider>>(
      find.byType(ChangeNotifierProvider<QuizProvider>)
    );
    
    expect(provider, isNotNull);
  });
}