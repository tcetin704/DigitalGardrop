import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_ayarlari.dart';
import 'api_exception.dart';

/// 4. HAFTA: Web API ile konuşan düşük seviyeli istemci.
///
/// Sorumlulukları ayrı adımlara bölünmüştür:
///   1) Adresi oluştur  2) İsteği zaman aşımıyla gönder
///   3) Durum kodunu kontrol et  4) JSON'u çöz
/// Her adımdaki hata [ApiException]'a çevrilir.
class ApiClient {
  ApiClient({http.Client? client, String? tabanAdres, Duration? zamanAsimi})
    : _client = client ?? http.Client(),
      tabanAdres = tabanAdres ?? ApiAyarlari.tabanAdres,
      _zamanAsimi = zamanAsimi ?? ApiAyarlari.zamanAsimi;

  final http.Client _client;
  final String tabanAdres;
  final Duration _zamanAsimi;

  /// GET isteği gönderir ve çözülmüş JSON değerini döndürür.
  Future<Object?> getJson(String yol) async {
    final adres = _adresOlustur(yol);
    final yanit = await _gonder(adres);
    _durumKodunuKontrolEt(yanit, adres);
    return _jsonCoz(yanit, adres);
  }

  Uri _adresOlustur(String yol) {
    final temizTaban = tabanAdres.endsWith('/')
        ? tabanAdres.substring(0, tabanAdres.length - 1)
        : tabanAdres;
    return Uri.parse('$temizTaban$yol');
  }

  Future<http.Response> _gonder(Uri adres) async {
    try {
      return await _client
          .get(adres, headers: const {'Accept': 'application/json'})
          .timeout(_zamanAsimi);
    } on TimeoutException {
      throw ApiException(ApiHataTuru.zamanAsimi, ayrinti: adres.toString());
    } on http.ClientException catch (hata) {
      // Sunucu kapali, adres yanlis veya ag yok.
      throw ApiException(
        ApiHataTuru.baglanti,
        ayrinti: '$adres - ${hata.message}',
      );
    }
  }

  void _durumKodunuKontrolEt(http.Response yanit, Uri adres) {
    final kod = yanit.statusCode;

    if (kod >= 200 && kod < 300) {
      return;
    } else if (kod == 401 || kod == 403) {
      throw ApiException(
        ApiHataTuru.yetkisiz,
        durumKodu: kod,
        ayrinti: adres.toString(),
      );
    } else if (kod == 404) {
      throw ApiException(
        ApiHataTuru.bulunamadi,
        durumKodu: kod,
        ayrinti: adres.toString(),
      );
    } else {
      throw ApiException(
        ApiHataTuru.sunucu,
        durumKodu: kod,
        ayrinti: adres.toString(),
      );
    }
  }

  Object? _jsonCoz(http.Response yanit, Uri adres) {
    // Turkce karakterlerin dogru gorunmesi icin govde UTF-8 olarak cozulur.
    final govde = utf8.decode(yanit.bodyBytes, allowMalformed: true);

    if (govde.trim().isEmpty) {
      throw ApiException(
        ApiHataTuru.gecersizVeri,
        durumKodu: yanit.statusCode,
        ayrinti: '$adres - boş yanıt',
      );
    }

    try {
      return jsonDecode(govde);
    } on FormatException catch (hata) {
      throw ApiException(
        ApiHataTuru.gecersizVeri,
        durumKodu: yanit.statusCode,
        ayrinti: '$adres - ${hata.message}',
      );
    }
  }

  /// Uygulama kapanırken bağlantıları serbest bırakır.
  void kapat() => _client.close();
}
