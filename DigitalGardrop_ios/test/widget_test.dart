import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_gardrop_mobile/main.dart';
import 'package:digital_gardrop_mobile/models/clothing_item.dart';
import 'package:digital_gardrop_mobile/screens/gardirobum_sayfasi.dart';
import 'package:digital_gardrop_mobile/screens/kiyafet_detay_sayfasi.dart';
import 'package:digital_gardrop_mobile/widgets/kiyafet_karti.dart';

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

  // 3. HAFTA TESTLERI

  testWidgets('Ana Sayfa -> Gardırobum -> Detay -> geri dönüş', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DigitalGardropApp());

    // Ana sayfadan Gardirobum ekranina gec.
    final buton = find.byKey(const Key('gardirobumButonu'));
    await tester.ensureVisible(buton);
    await tester.tap(buton);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('aramaAlani')), findsOneWidget);

    // Bir kiyafete dokunup detay ekranina gec.
    await tester.tap(find.text('Mavi Kot Pantolon'));
    await tester.pumpAndSettle();
    expect(find.text('Kıyafet Detayı'), findsOneWidget);
    expect(find.text('Mavi Kot Pantolon'), findsOneWidget);
    expect(find.text('Dört Mevsim'), findsOneWidget);

    // Geri tusuyla Gardirobum ekranina don.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('aramaAlani')), findsOneWidget);

    // Bir geri daha: ana sayfa.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Gardırobuna Hoş Geldin!'), findsOneWidget);
  });

  testWidgets('Arama sonuçlu ve sonuçsuz durumda doğru çalışır', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GardirobumSayfasi()));

    // Buyuk harf ve Turkce karakterle arama: SİYAH -> 2 sonuc.
    await tester.enterText(find.byKey(const Key('aramaAlani')), 'SİYAH');
    await tester.pump();
    expect(find.byType(KiyafetKarti), findsNWidgets(2));
    expect(find.text('Siyah Deri Ceket'), findsOneWidget);

    // Eslesmeyen arama: bos sonuc mesaji.
    await tester.enterText(find.byKey(const Key('aramaAlani')), 'zzz');
    await tester.pump();
    expect(find.byType(KiyafetKarti), findsNothing);
    expect(
      find.text('"zzz" ile eşleşen kıyafet bulunamadı.'),
      findsOneWidget,
    );
  });

  testWidgets('Kategori filtresi yalnızca o kategoriyi gösterir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GardirobumSayfasi()));

    final ayakkabiCipi = find.text('Ayakkabı (2)');
    await tester.ensureVisible(ayakkabiCipi);
    await tester.tap(ayakkabiCipi);
    await tester.pump();

    expect(find.byType(KiyafetKarti), findsNWidgets(2));
    expect(find.text('Beyaz Spor Ayakkabı'), findsOneWidget);
    expect(find.text('Kahverengi Deri Bot'), findsOneWidget);
  });

  testWidgets('Boş gardırop mesajı gösterilir', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GardirobumSayfasi(kiyafetler: [])),
    );

    expect(find.byType(KiyafetKarti), findsNothing);
    expect(
      find.text('Gardırobun boş. İlk kıyafetini eklediğinde burada görünecek.'),
      findsOneWidget,
    );
  });

  testWidgets('Uzun kıyafet adı dar ekranda taşma hatası vermez', (
    WidgetTester tester,
  ) async {
    // 320 x 640 boyutunda dar bir telefon ekrani.
    tester.view.physicalSize = const Size(960, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    const uzunKiyafet = ClothingItem(
      id: 99,
      name: 'Çok Uzun İsimli Oversize Yünlü Balıkçı Yaka Kazak Kış Koleksiyonu',
      category: 'Üst Giyim',
      color: 'Açık Gri Melanj Tonlarında',
      season: 'Dört Mevsim',
      style: 'Günlük',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: KiyafetDetaySayfasi(kiyafet: uzunKiyafet, tumKiyafetler: []),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Çok Uzun İsimli'), findsOneWidget);
  });
}
