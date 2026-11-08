
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_gardrop_mobile/main.dart';

void main() {
  testWidgets('Dijital Gardrop ana sayfa testi', (WidgetTester tester) async {
    // Uygulamayi baslat.
    await tester.pumpWidget(const DigitalGardropApp());

    // Ana sayfa basligini kontrol et.
    expect(
      find.text('Gardırobuna Hoş Geldin!'),
      findsOneWidget,
    );

    // Kategori basligini kontrol et.
    expect(
      find.text('Kıyafet Kategorileri'),
      findsOneWidget,
    );

    // Ornek kiyafet kontrolu.
    expect(
      find.text('Siyah Basic Tişört'),
      findsOneWidget,
    );

    // Ana sayfanin temel yapisini kontrol et.
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
