import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_gardrop_mobile/main.dart';
import 'package:digital_gardrop_mobile/models/clothing_item.dart';
import 'package:digital_gardrop_mobile/screens/gardirobum_sayfasi.dart';
import 'package:digital_gardrop_mobile/screens/kiyafet_detay_sayfasi.dart';
import 'package:digital_gardrop_mobile/services/api_exception.dart';
import 'package:digital_gardrop_mobile/services/kiyafet_repository.dart';
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
    await tester.pumpWidget(
      DigitalGardropApp(repository: OrnekVeriRepository()),
    );

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
    await tester.pumpWidget(
      MaterialApp(home: GardirobumSayfasi(repository: OrnekVeriRepository())),
    );
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(
      MaterialApp(home: GardirobumSayfasi(repository: OrnekVeriRepository())),
    );
    await tester.pumpAndSettle();

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
      MaterialApp(
        home: GardirobumSayfasi(
          repository: OrnekVeriRepository(kiyafetler: const []),
        ),
      ),
    );
    await tester.pumpAndSettle();

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

  // 4. HAFTA TESTLERI: yukleniyor / hata / tekrar dene

  testWidgets('Yükleniyor -> hata -> tekrar dene -> liste', (
    WidgetTester tester,
  ) async {
    final ilkIstek = Completer<List<ClothingItem>>();
    final repo = _SahteRepository([
      () => ilkIstek.future,
      () async => const [
        ClothingItem(
          id: 1,
          name: 'API Tişörtü',
          category: 'Üst Giyim',
          color: 'Yeşil',
          season: 'Yaz',
          style: 'Spor',
        ),
      ],
    ]);

    await tester.pumpWidget(MaterialApp(home: GardirobumSayfasi(repository: repo)));

    // 1) Istek surerken yukleniyor gorunumu.
    expect(find.text('Kıyafetler yükleniyor...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 2) Sunucu kapali: hata gorunumu.
    ilkIstek.completeError(const ApiException(ApiHataTuru.baglanti));
    await tester.pump();
    expect(find.text('Kıyafetler yüklenemedi'), findsOneWidget);
    expect(
      find.text(const ApiException(ApiHataTuru.baglanti).kullaniciMesaji),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);

    // 3) Tekrar dene: ikinci istek basarili.
    await tester.tap(find.byKey(const Key('tekrarDeneButonu')));
    await tester.pumpAndSettle();
    expect(repo.cagriSayisi, 2);
    expect(find.text('API Tişörtü'), findsOneWidget);
    expect(find.text('Sahte API'), findsOneWidget);
  });

  testWidgets('Hata ekranından örnek verilerle devam edilebilir', (
    WidgetTester tester,
  ) async {
    final repo = _SahteRepository([
      () async => throw const ApiException(ApiHataTuru.sunucu, durumKodu: 500),
    ]);

    await tester.pumpWidget(MaterialApp(home: GardirobumSayfasi(repository: repo)));
    await tester.pumpAndSettle();

    expect(find.textContaining('kod: 500'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);

    await tester.tap(find.byKey(const Key('ornekVeriButonu')));
    await tester.pumpAndSettle();

    expect(find.byType(KiyafetKarti), findsWidgets);
    expect(find.text('Yerel örnek veri'), findsOneWidget);
  });

  testWidgets('Beklenmeyen hata da hata ekranında gösterilir', (
    WidgetTester tester,
  ) async {
    final repo = _SahteRepository([() async => throw StateError('beklenmeyen')]);

    await tester.pumpWidget(MaterialApp(home: GardirobumSayfasi(repository: repo)));
    await tester.pumpAndSettle();

    expect(
      find.text(const ApiException(ApiHataTuru.bilinmeyen).kullaniciMesaji),
      findsOneWidget,
    );
  });
}

/// Testlerde sırayla verilen yanıtları döndüren sahte veri kaynağı.
class _SahteRepository extends KiyafetRepository {
  _SahteRepository(this._yanitlar);

  final List<Future<List<ClothingItem>> Function()> _yanitlar;
  int cagriSayisi = 0;

  @override
  String get kaynakAdi => 'Sahte API';

  @override
  Future<List<ClothingItem>> kiyafetleriGetir() => _yanitlar[cagriSayisi++]();
}
