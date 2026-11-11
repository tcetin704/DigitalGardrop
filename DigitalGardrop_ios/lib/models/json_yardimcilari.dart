// 4. HAFTA: JSON ALANLARINI GUVENLI OKUMA
// API'den gelen veride alanlar eksik, null veya beklenenden farkli tipte
// olabilir. Bu fonksiyonlar bu durumlari kontrollu bicimde ele alir.

/// Zorunlu bir tam sayı alanı okur. Sayı olarak yazılmış metni de ("5")
/// kabul eder. Alan yoksa veya sayıya çevrilemiyorsa FormatException fırlatır.
int zorunluInt(Map<String, dynamic> json, String alan) {
  final deger = istegeBagliInt(json, alan);
  if (deger == null) {
    throw FormatException('"$alan" alanı eksik veya sayı değil.', json[alan]);
  }
  return deger;
}

/// İsteğe bağlı bir tam sayı alanı okur; okunamazsa null döner.
int? istegeBagliInt(Map<String, dynamic> json, String alan) {
  final deger = json[alan];
  if (deger is int) {
    return deger;
  }
  if (deger is num) {
    return deger.toInt();
  }
  if (deger is String) {
    return int.tryParse(deger.trim());
  }
  return null;
}

/// Zorunlu bir metin alanı okur. Boş metin de eksik sayılır.
String zorunluString(Map<String, dynamic> json, String alan) {
  final deger = istegeBagliString(json, alan);
  if (deger == null) {
    throw FormatException('"$alan" alanı eksik veya boş.', json[alan]);
  }
  return deger;
}

/// İsteğe bağlı bir metin alanı okur. Yoksa, boşsa veya metin değilse null.
String? istegeBagliString(Map<String, dynamic> json, String alan) {
  final deger = json[alan];
  if (deger is String && deger.trim().isNotEmpty) {
    return deger.trim();
  }
  return null;
}
