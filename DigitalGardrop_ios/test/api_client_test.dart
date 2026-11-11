import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:digital_gardrop_mobile/services/api_client.dart';
import 'package:digital_gardrop_mobile/services/api_exception.dart';
import 'package:digital_gardrop_mobile/services/kiyafet_repository.dart';

// 4. HAFTA: ApiClient ve ApiKiyafetRepository testleri.
// Gercek sunucu yerine http paketinin MockClient sinifi kullanilir.

const _tabanAdres = 'http://test-sunucu:5038';

/// Verilen yanıtı döndüren sahte istemciyle bir repository oluşturur.
ApiKiyafetRepository _repository(
  MockClientHandler handler, {
  Duration zamanAsimi = const Duration(seconds: 2),
}) {
  return ApiKiyafetRepository(
    ApiClient(
      client: MockClient(handler),
      tabanAdres: _tabanAdres,
      zamanAsimi: zamanAsimi,
    ),
  );
}

/// UTF-8 kodlu JSON yanıtı (Türkçe karakterler için).
http.Response _jsonYanit(Object veri, [int kod = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(veri)), kod);

/// Beklenen hata türünü kontrol eden eşleştirici.
Matcher _apiHatasi(ApiHataTuru tur) =>
    throwsA(isA<ApiException>().having((h) => h.tur, 'tur', tur));

void main() {
  test('doğru adrese Accept başlığıyla GET isteği gönderir', () async {
    late http.Request gonderilen;
    final repo = _repository((istek) async {
      gonderilen = istek;
      return _jsonYanit([]);
    });

    await repo.kiyafetleriGetir();

    expect(gonderilen.method, 'GET');
    expect(gonderilen.url.toString(), '$_tabanAdres/api/clothingitems');
    expect(gonderilen.headers['Accept'], 'application/json');
  });

  test('başarılı yanıtı Türkçe karakterlerle birlikte çözer', () async {
    final repo = _repository(
      (_) async => _jsonYanit([
        {
          'id': 1,
          'name': 'Siyah Basic Tişört',
          'category': 'Üst Giyim',
          'color': 'Siyah',
          'season': 'Yaz',
          'style': 'Günlük',
        },
        {
          'id': 2,
          'name': 'İpek Eşarp',
          'category': 'Aksesuar',
          'color': 'Kırmızı',
          'season': 'İlkbahar',
          'style': 'Klasik',
        },
      ]),
    );

    final liste = await repo.kiyafetleriGetir();

    expect(liste, hasLength(2));
    expect(liste.first.name, 'Siyah Basic Tişört');
    expect(liste.first.category, 'Üst Giyim');
    expect(liste.last.name, 'İpek Eşarp');
  });

  test('boş liste yanıtı boş liste döndürür', () async {
    final repo = _repository((_) async => _jsonYanit([]));
    expect(await repo.kiyafetleriGetir(), isEmpty);
  });

  test('taban adresin sonundaki / işareti çift / oluşturmaz', () async {
    late Uri adres;
    final api = ApiClient(
      client: MockClient((istek) async {
        adres = istek.url;
        return _jsonYanit([]);
      }),
      tabanAdres: '$_tabanAdres/',
    );

    await api.getJson('/api/clothingitems');
    expect(adres.toString(), '$_tabanAdres/api/clothingitems');
  });

  group('hata durumları', () {
    test('sunucu kapalı -> bağlantı hatası', () async {
      final repo = _repository(
        (istek) async =>
            throw http.ClientException('Connection refused', istek.url),
      );
      await expectLater(
        repo.kiyafetleriGetir(),
        _apiHatasi(ApiHataTuru.baglanti),
      );
    });

    test('yanıt gecikirse -> zaman aşımı hatası', () async {
      final repo = _repository((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return _jsonYanit([]);
      }, zamanAsimi: const Duration(milliseconds: 50));

      await expectLater(
        repo.kiyafetleriGetir(),
        _apiHatasi(ApiHataTuru.zamanAsimi),
      );
    });

    test('500 -> sunucu hatası ve durum kodu', () async {
      final repo = _repository((_) async => http.Response('Hata', 500));
      await expectLater(
        repo.kiyafetleriGetir(),
        throwsA(
          isA<ApiException>()
              .having((h) => h.tur, 'tur', ApiHataTuru.sunucu)
              .having((h) => h.durumKodu, 'durumKodu', 500)
              .having(
                (h) => h.kullaniciMesaji,
                'kullaniciMesaji',
                contains('500'),
              ),
        ),
      );
    });

    test('404 -> bulunamadı hatası', () async {
      final repo = _repository((_) async => http.Response('', 404));
      await expectLater(
        repo.kiyafetleriGetir(),
        _apiHatasi(ApiHataTuru.bulunamadi),
      );
    });

    test('401 -> yetkisiz hatası', () async {
      final repo = _repository((_) async => http.Response('', 401));
      await expectLater(
        repo.kiyafetleriGetir(),
        _apiHatasi(ApiHataTuru.yetkisiz),
      );
    });

    test('geçersiz JSON -> geçersiz veri hatası', () async {
      final repo = _repository(
        (_) async => http.Response('bu json degil {', 200),
      );
      await expectLater(
        repo.kiyafetleriGetir(),
        _apiHatasi(ApiHataTuru.gecersizVeri),
      );
    });

    test('boş gövde -> geçersiz veri hatası', () async {
      final repo = _repository((_) async => http.Response('', 200));
      await expectLater(
        repo.kiyafetleriGetir(),
        _apiHatasi(ApiHataTuru.gecersizVeri),
      );
    });

    test('liste yerine nesne -> geçersiz veri hatası', () async {
      final repo = _repository((_) async => _jsonYanit({'id': 1}));
      await expectLater(
        repo.kiyafetleriGetir(),
        _apiHatasi(ApiHataTuru.gecersizVeri),
      );
    });
  });

  test('kategorileriGetir kategori listesini çözer', () async {
    final repo = _repository(
      (_) async => _jsonYanit([
        {'id': 1, 'name': 'Üst Giyim'},
        {'id': 3, 'name': 'Ayakkabı'},
      ]),
    );

    final kategoriler = await repo.kategorileriGetir();
    expect(kategoriler.map((k) => k.name).toList(), ['Üst Giyim', 'Ayakkabı']);
  });
}
