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
  models/category.dart            Kategori modeli (4. hafta)
  models/json_yardimcilari.dart   Güvenli JSON alan okuma (4. hafta)
  services/api_ayarlari.dart      Taban adres ve zaman aşımı (4. hafta)
  services/api_client.dart        HTTP istemcisi (4. hafta)
  services/api_exception.dart     Hata türleri ve kullanıcı mesajları (4. hafta)
  services/kiyafet_repository.dart Veri kaynağı: Web API / yerel örnek (4. hafta)
  hafta2_dart_temelleri.dart      2. hafta Dart konsol alıştırmaları
test/
  widget_test.dart                Ekran ve gezinme testleri
  gardirop_islemleri_test.dart    Filtreleme ve koleksiyon birim testleri
  model_test.dart                 fromJson / toJson testleri
  api_client_test.dart            MockClient ile API ve hata testleri
tool/
  mock_api_sunucu.dart            Sahte Web API (gerçek API hazır olana kadar)
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

### 4. Hafta (Lider: Hüseyin Can Özdüzen)
- **Model sınıfları:** `ClothingItem` ve `Category`; null safety kurallarına
  uygun `fromJson` / `toJson`. Eksik isteğe bağlı alanlar "Belirtilmemiş",
  zorunlu alanı (`id`, `name`) eksik kayıtlar `FormatException` ile reddedilir;
  listedeki bozuk kayıtlar atlanır.
- **Koleksiyonlar:** `farkliRenkler` (Set), `kategoriyeGoreGrupla` (Map),
  `filtreKategorileri` (Set + where), `kiyafetListesiniCoz` (whereType + map).
- **API katmanı:** `http` paketiyle `ApiClient` (adres, zaman aşımı, durum
  kodu, UTF-8 JSON çözme ayrı adımlar) ve `KiyafetRepository` arayüzü.
- **Durumlar:** Yükleniyor, hata (bağlantı / zaman aşımı / sunucu / geçersiz
  veri), **Tekrar dene**, **Örnek verilerle devam et** ve boş liste.
- **Platform ayarları:**
  - Android emülatörü → `http://10.0.2.2:5038`, iOS Simulator →
    `http://localhost:5038` (`lib/services/api_ayarlari.dart`)
  - Android: `INTERNET` izni ve yalnızca yerel adresler için HTTP izni
    (`android/app/src/main/res/xml/network_security_config.xml`)
  - iOS: `NSAllowsLocalNetworking` (Info.plist)
- **Testler:** Model, API (MockClient ile 200/401/404/500, zaman aşımı,
  bağlantı hatası, geçersiz JSON) ve ekran durum testleri.

> Not: Gerçek ASP.NET Core Web API web ekibi tarafından geliştirilmektedir.
> Hazır olana kadar `tool/mock_api_sunucu.dart` ile deneme yapılır.

## Sahte API ile deneme

```bash
# 1. Terminal: sahte sunucu (modlar: normal, bos, bozuk, hata, yavas)
dart run tool/mock_api_sunucu.dart

# 2. Terminal: uygulama
flutter run
```

Gerçek bir telefonda denemek için bilgisayarın yerel IP adresi verilir:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:5038
```
