// ignore_for_file: avoid_print
//
// 4. HAFTA: SAHTE (MOCK) WEB API SUNUCUSU
//
// Gercek ASP.NET Core Web API hazir olana kadar mobil uygulamanin HTTP
// katmanini denemek icin kullanilir. docs/api_sozlesmesi.md'deki JSON
// bicimini, gercek API ile ayni portta (5038) sunar.
//
// Calistirma (DigitalGardrop_ios klasorunde):
//   dart run tool/mock_api_sunucu.dart            -> normal veri
//   dart run tool/mock_api_sunucu.dart bos        -> bos liste []
//   dart run tool/mock_api_sunucu.dart bozuk      -> gecersiz JSON
//   dart run tool/mock_api_sunucu.dart hata       -> HTTP 500
//   dart run tool/mock_api_sunucu.dart yavas      -> 12 sn gecikme (zaman asimi)
// Durdurmak icin: Ctrl+C  (sunucu kapali durumu da boylece denenir)

import 'dart:convert';
import 'dart:io';

const int port = 5038;

const List<Map<String, Object?>> kategoriler = [
  {'id': 1, 'name': 'Üst Giyim'},
  {'id': 2, 'name': 'Alt Giyim'},
  {'id': 3, 'name': 'Ayakkabı'},
  {'id': 4, 'name': 'Dış Giyim'},
  {'id': 5, 'name': 'Aksesuar'},
];

const List<Map<String, Object?>> kiyafetler = [
  {
    'id': 1,
    'name': 'Siyah Basic Tişört',
    'category': 'Üst Giyim',
    'categoryId': 1,
    'color': 'Siyah',
    'season': 'Yaz',
    'style': 'Günlük',
    'imageUrl': null,
    'userId': null,
  },
  {
    'id': 2,
    'name': 'Mavi Kot Pantolon',
    'category': 'Alt Giyim',
    'categoryId': 2,
    'color': 'Mavi',
    'season': 'Dört Mevsim',
    'style': 'Günlük',
    'imageUrl': null,
    'userId': null,
  },
  {
    'id': 3,
    'name': 'Beyaz Spor Ayakkabı',
    'category': 'Ayakkabı',
    'categoryId': 3,
    'color': 'Beyaz',
    'season': 'Dört Mevsim',
    'style': 'Spor',
    'imageUrl': null,
    'userId': null,
  },
  {
    'id': 11,
    'name': 'Haki Yağmurluk (API)',
    'category': 'Dış Giyim',
    'categoryId': 4,
    'color': 'Haki',
    'season': 'Sonbahar',
    'style': 'Günlük',
    'imageUrl': '',
    'userId': 1,
  },
  // Eksik alanli kayit: uygulama "Belirtilmemiş" gostermeli.
  {'id': 12, 'name': 'Gümüş Kolye (eksik alanlı kayıt)', 'categoryId': 5},
  // Bozuk kayit (id yok): uygulama bu kaydi atlamali.
  {'name': 'Kimliksiz bozuk kayıt', 'color': 'Mor'},
];

Future<void> main(List<String> argumanlar) async {
  final mod = argumanlar.isEmpty ? 'normal' : argumanlar.first;
  const gecerliModlar = {'normal', 'bos', 'bozuk', 'hata', 'yavas'};

  if (!gecerliModlar.contains(mod)) {
    print('Bilinmeyen mod: $mod. Seçenekler: ${gecerliModlar.join(', ')}');
    exitCode = 64;
    return;
  }

  // anyIPv4: hem iOS Simulator (localhost) hem Android emulatoru
  // (10.0.2.2) bu sunucuya ulasabilir.
  final sunucu = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('Sahte API çalışıyor: http://localhost:$port  (mod: $mod)');
  print('  GET /api/clothingitems');
  print('  GET /api/clothingitems/{id}');
  print('  GET /api/categories');
  print('Durdurmak için Ctrl+C');

  // Her istek ayri islenir; yavas modda diger istekler beklemez.
  sunucu.listen((istek) => _istegiIsle(istek, mod));
}

Future<void> _istegiIsle(HttpRequest istek, String mod) async {
  final yol = istek.uri.path;
  print('${DateTime.now().toIso8601String()}  ${istek.method} $yol');

  final yanit = istek.response;
  yanit.headers.contentType = ContentType.json; // application/json; utf-8

  if (istek.method != 'GET') {
    await _gonder(yanit, 405, {'hata': 'Yalnızca GET destekleniyor.'});
    return;
  }

  if (mod == 'yavas') {
    await Future<void>.delayed(const Duration(seconds: 12));
  }
  if (mod == 'hata') {
    await _gonder(yanit, 500, {'hata': 'Sahte sunucu hatası'});
    return;
  }
  if (mod == 'bozuk' && yol.startsWith('/api/')) {
    yanit.statusCode = 200;
    yanit.write('{"bu": "geçersiz json"');
    await yanit.close();
    return;
  }

  final parcalar = yol.split('/').where((p) => p.isNotEmpty).toList();

  if (yol == '/api/clothingitems') {
    await _gonder(yanit, 200, mod == 'bos' ? <Object>[] : kiyafetler);
  } else if (parcalar.length == 3 &&
      parcalar[0] == 'api' &&
      parcalar[1] == 'clothingitems') {
    final id = int.tryParse(parcalar[2]);
    final bulunan = kiyafetler.where((k) => k['id'] == id).toList();
    if (bulunan.isEmpty) {
      await _gonder(yanit, 404, {'hata': 'Kıyafet bulunamadı.'});
    } else {
      await _gonder(yanit, 200, bulunan.first);
    }
  } else if (yol == '/api/categories') {
    await _gonder(yanit, 200, mod == 'bos' ? <Object>[] : kategoriler);
  } else {
    await _gonder(yanit, 404, {'hata': 'Adres bulunamadı.'});
  }
}

Future<void> _gonder(HttpResponse yanit, int kod, Object veri) async {
  yanit.statusCode = kod;
  yanit.write(jsonEncode(veri));
  await yanit.close();
}
