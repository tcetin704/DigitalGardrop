/// API isteğinde oluşabilecek hata türleri.
enum ApiHataTuru {
  baglanti,
  zamanAsimi,
  yetkisiz,
  bulunamadi,
  sunucu,
  gecersizVeri,
  bilinmeyen,
}

/// API katmanının fırlattığı tek hata sınıfı. Ekranlar yalnızca bu sınıfı
/// yakalar; http, JSON veya zaman aşımı ayrıntılarını bilmek zorunda kalmaz.
class ApiException implements Exception {
  const ApiException(this.tur, {this.durumKodu, this.ayrinti});

  final ApiHataTuru tur;

  /// Sunucudan gelen HTTP durum kodu (varsa).
  final int? durumKodu;

  /// Geliştiriciye yönelik teknik açıklama (ör. istek adresi).
  final String? ayrinti;

  /// Kullanıcıya gösterilecek anlaşılır mesaj. (switch ifadesi örneği)
  String get kullaniciMesaji => switch (tur) {
    ApiHataTuru.baglanti =>
      'Sunucuya bağlanılamadı. Web API çalışıyor mu kontrol edin.',
    ApiHataTuru.zamanAsimi =>
      'Sunucu zamanında yanıt vermedi. Lütfen tekrar deneyin.',
    ApiHataTuru.yetkisiz => 'Bu işlem için giriş yapmanız gerekiyor.',
    ApiHataTuru.bulunamadi => 'İstenen kayıt veya adres bulunamadı.',
    ApiHataTuru.sunucu => 'Sunucuda bir hata oluştu (kod: $durumKodu).',
    ApiHataTuru.gecersizVeri => 'Sunucudan gelen veri okunamadı.',
    ApiHataTuru.bilinmeyen => 'Beklenmeyen bir hata oluştu.',
  };

  /// Bağlantı kaynaklı hatalarda farklı ikon göstermek için.
  bool get baglantiHatasiMi =>
      tur == ApiHataTuru.baglanti || tur == ApiHataTuru.zamanAsimi;

  @override
  String toString() =>
      'ApiException($tur, durumKodu: $durumKodu, ayrinti: $ayrinti)';
}
