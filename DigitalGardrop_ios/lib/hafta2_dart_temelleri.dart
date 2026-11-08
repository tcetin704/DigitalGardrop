// Bu dosya 2. hafta Dart konsol alistirmalarini icerir.
// print() kullanimi yalnizca egitim amaclidir.
// ignore_for_file: avoid_print

void main() {
  // 1. TEMEL VERI TIPLERI

  String kiyafetAdi = 'Siyah Basic Tişört';
  String kategori = 'Üst Giyim';
  String renk = 'Siyah';

  int kiyafetSayisi = 3;
  double fiyat = 249.90;
  bool favoriMi = true;

  print('=== DİJİTAL GARDIROP ===');
  print('Kıyafet: $kiyafetAdi');
  print('Kategori: $kategori');
  print('Renk: $renk');
  print('Toplam kıyafet: $kiyafetSayisi');
  print('Fiyat: $fiyat TL');
  print('Favori mi: $favoriMi');

  // 2. VAR, FINAL VE CONST

  var mevsim = 'Yaz';
  final String kullaniciAdi = 'Demo Kullanıcı';
  const int maksimumKiyafetSayisi = 100;

  print('\n=== DEĞİŞKENLER ===');
  print('Mevsim: $mevsim');
  print('Kullanıcı: $kullaniciAdi');
  print('Kapasite: $maksimumKiyafetSayisi');

  mevsim = 'İlkbahar';
  print('Güncellenen mevsim: $mevsim');

  // 3. NULL SAFETY

  String? desen;

  print('\n=== NULL SAFETY ===');
  print('Desen: ${desen ?? "Belirtilmedi"}');

  desen = 'Düz';
  print('Güncel desen: $desen');

  // 4. ARITMETIK OPERATORLER

  int yeniEklenenKiyafet = 2;
  int toplamKiyafet = kiyafetSayisi + yeniEklenenKiyafet;

  double indirimOrani = 0.20;
  double indirimliFiyat = fiyat * (1 - indirimOrani);

  print('\n=== HESAPLAMALAR ===');
  print('Yeni toplam kıyafet: $toplamKiyafet');
  print('İndirimli fiyat: ${indirimliFiyat.toStringAsFixed(2)} TL');

  // 5. KARSILASTIRMA VE MANTIKSAL OPERATORLER

  bool kapasiteUygunMu = toplamKiyafet < maksimumKiyafetSayisi;

  bool favoriVeUygunMu = favoriMi && kapasiteUygunMu;

  print('\n=== KONTROLLER ===');
  print('Kapasite uygun mu: $kapasiteUygunMu');
  print('Favori ve kapasite uygun mu: $favoriVeUygunMu');

  // 6. STRING INTERPOLATION

  String ozet =
      '$kullaniciAdi adlı kullanıcının gardırobunda '
      '$toplamKiyafet kıyafet bulunuyor.';

  print('\n=== GARDIROP ÖZETİ ===');
  print(ozet);
}
