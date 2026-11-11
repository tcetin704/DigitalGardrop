# Dijital Gardırop – Flutter Mobil Uygulaması

BLM4587 iOS ile Mobil Uygulama Geliştirme I dersi kapsamında geliştirilen
Dijital Gardırop platformunun Flutter istemcisi. Ortak backend ve veritabanı
web projesiyle (`../DigitalGardrop_web`) paylaşılır.

## Gereksinimler

- Flutter 3.47.x (stable), Dart 3.13.x
- iOS için: macOS, Xcode ve iOS Simulator
- Android için: Android SDK ve emülatör

## Çalıştırma

```bash
cd DigitalGardrop_ios
flutter pub get
flutter run            # cihaz seçimi için
flutter analyze        # statik analiz
flutter test           # birim ve widget testleri
```

## Klasör yapısı

```
lib/
  main.dart                       Uygulama, rotalar ve Ana Sayfa
  models/clothing_item.dart       Kıyafet modeli
  data/ornek_kiyafetler.dart      Yerel örnek veriler (API hazır olana kadar)
  logic/gardirop_islemleri.dart   Filtreleme ve yardımcı fonksiyonlar (saf Dart)
  widgets/kiyafet_karti.dart      Liste kartı ve kategori ikonu
  screens/gardirobum_sayfasi.dart Arama + kategori filtresi + liste
  screens/kiyafet_detay_sayfasi.dart Kıyafet detay ekranı
  hafta2_dart_temelleri.dart      2. hafta Dart konsol alıştırmaları
test/
  widget_test.dart                Ekran ve gezinme testleri
  gardirop_islemleri_test.dart    Filtreleme birim testleri
docs/
  api_sozlesmesi.md               Mobil – Web API sözleşmesi taslağı
```

## Haftalık ilerleme

### 1–2. Hafta (Lider: Taha Çetin)
- Flutter kurulumu, proje iskeleti ve Dijital Gardırop ana ekranı
- Dart veri tipleri, var/final/const, null safety ve operatörler

### 3. Hafta (Lider: Hüseyin Can Özdüzen)
- **Ekranlar ve gezinme:** Ana Sayfa → Gardırobum → Kıyafet Detay
  (`Navigator.pushNamed`, `Navigator.push`, `Navigator.popUntil`)
- **Arama ve filtre:** Ad veya renge göre arama (Türkçe İ/ı uyumlu),
  kategori çipleri ve kategori başına kıyafet sayısı
- **Boş durumlar:** Sonuçsuz arama, boş kategori ve boş gardırop mesajları
- **Dart kontrol akışı** (`lib/logic/gardirop_islemleri.dart`):
  - `if / else if / else` → `bosSonucMesaji`
  - `switch` → `mevsimIpucu`, switch ifadesi → `kategoriIkonu`
  - `for-in` → `kiyafetleriFiltrele`, klasik `for` → `kategoridekiKiyafetSayisi`
  - `while` → `ayniRenktekiDigerKiyafet`
  - Arrow fonksiyonlar → `turkceKucukHarf`, `kategoriyeUyuyorMu`
- **Yerleşim:** `Padding`, `Column`, `Row`, `Expanded`; uzun adlar için
  `maxLines` / `TextOverflow.ellipsis`
- **Testler:** Gezinme, arama (sonuçlu/sonuçsuz), kategori filtresi,
  boş gardırop ve dar ekranda uzun ad testleri
- **API sözleşmesi:** `docs/api_sozlesmesi.md` (web ekibiyle teyit edilecek)

> Not: Gardırobum ekranı şu an **yerel örnek veri** kullanır. Web API'ye
> bağlantı 4. haftada eklenecektir.
