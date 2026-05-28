import 'package:finova_expense/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('İlk açılış -> işlem ekleme -> dashboard toplam görünümü', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Finova Expense'), findsWidgets);

    await tester.tap(find.text('Başla'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('İşlem Ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Tutar (₺)'), '2500');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Toplam Bakiye'), findsOneWidget);
  });
}
