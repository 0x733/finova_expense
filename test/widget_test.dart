import 'package:finova_expense/features/onboarding/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Onboarding title renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: OnboardingPage())));
    await tester.pump();
    expect(find.text('Finova Expense'), findsOneWidget);
  });
}
