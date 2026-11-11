import '../models/clothing_item.dart';

// 3. HAFTA: KONTROL AKISI VE FONKSIYONLAR
// Bu dosyada Flutter'a bagimli olmayan saf Dart fonksiyonlari bulunur;
// bu sayede birim testleriyle kolayca sinanabilirler.

/// Kategori filtresinde "hepsi" seçeneğini temsil eder.
const String tumKategoriler = 'Tümü';

/// Türkçe karakterlere uygun küçük harf dönüşümü.
/// Dart'ın toLowerCase() metodu 'İ' ve 'I' harflerinde Türkçe kuralını
/// uygulamadığı için önce bu iki harf elle çevrilir.
/// (Arrow fonksiyon örneği)
String turkceKucukHarf(String metin) =>
    metin.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

/// Kıyafet seçilen kategoriye uyuyor mu? (Arrow fonksiyon örneği)
bool kategoriyeUyuyorMu(ClothingItem kiyafet, String kategori) =>
    kategori == tumKategoriler || kiyafet.category == kategori;

/// Kıyafetin adı veya rengi aranan metni içeriyor mu? (if örneği)
bool aramayaUyuyorMu(ClothingItem kiyafet, String arama) {
  final aranan = turkceKucukHarf(arama.trim());

  if (aranan.isEmpty) {
    return true;
  }

  return turkceKucukHarf(kiyafet.name).contains(aranan) ||
      turkceKucukHarf(kiyafet.color).contains(aranan);
}

/// Listeyi arama metni ve kategoriye göre filtreler. (for-in örneği)
List<ClothingItem> kiyafetleriFiltrele(
  List<ClothingItem> kiyafetler, {
  String arama = '',
  String kategori = tumKategoriler,
}) {
  final sonuc = <ClothingItem>[];

  for (final kiyafet in kiyafetler) {
    if (!kategoriyeUyuyorMu(kiyafet, kategori)) {
      continue;
    }
    if (aramayaUyuyorMu(kiyafet, arama)) {
      sonuc.add(kiyafet);
    }
  }

  return sonuc;
}

/// Seçilen kategorideki kıyafet sayısını sayar. (klasik for örneği)
int kategoridekiKiyafetSayisi(List<ClothingItem> kiyafetler, String kategori) {
  if (kategori == tumKategoriler) {
    return kiyafetler.length;
  }

  var sayi = 0;
  for (var i = 0; i < kiyafetler.length; i++) {
    if (kiyafetler[i].category == kategori) {
      sayi++;
    }
  }
  return sayi;
}

/// Seçilen kıyafetle aynı renkteki ilk başka kıyafeti bulur.
/// Bulamazsa null döner. (while örneği)
ClothingItem? ayniRenktekiDigerKiyafet(
  List<ClothingItem> kiyafetler,
  ClothingItem secilen,
) {
  final renk = turkceKucukHarf(secilen.color);
  var i = 0;

  while (i < kiyafetler.length) {
    final aday = kiyafetler[i];
    if (aday.id != secilen.id && turkceKucukHarf(aday.color) == renk) {
      return aday;
    }
    i++;
  }

  return null;
}

/// Mevsime göre kısa kullanım ipucu üretir. (switch örneği)
String mevsimIpucu(String mevsim) {
  switch (mevsim) {
    case 'Yaz':
      return 'Sıcak havalar için hafif bir parça.';
    case 'Kış':
      return 'Soğuk havalarda katmanlı giyime uygun.';
    case 'İlkbahar':
    case 'Sonbahar':
      return 'Geçiş mevsimlerinde rahatça kullanılabilir.';
    case 'Dört Mevsim':
      return 'Yılın her döneminde kullanılabilir.';
    default:
      return 'Mevsim bilgisi belirtilmemiş.';
  }
}

/// Filtre sonucu boş olduğunda kullanıcıya gösterilecek mesaj.
/// (if / else if / else örneği)
String bosSonucMesaji({required String arama, required String kategori}) {
  final temizArama = arama.trim();
  final aramaVar = temizArama.isNotEmpty;
  final kategoriSecili = kategori != tumKategoriler;

  if (aramaVar && kategoriSecili) {
    return '"$temizArama" araması "$kategori" kategorisinde sonuç vermedi.';
  } else if (aramaVar) {
    return '"$temizArama" ile eşleşen kıyafet bulunamadı.';
  } else if (kategoriSecili) {
    return '"$kategori" kategorisinde henüz kıyafet yok.';
  } else {
    return 'Gardırobun boş. İlk kıyafetini eklediğinde burada görünecek.';
  }
}
