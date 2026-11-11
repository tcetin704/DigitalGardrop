import 'package:flutter_test/flutter_test.dart';
import 'package:digital_gardrop_mobile/logic/gardirop_islemleri.dart';
import 'package:digital_gardrop_mobile/models/clothing_item.dart';

// 3. HAFTA: Filtreleme ve yardimci fonksiyonlarin birim testleri.

const _tisort = ClothingItem(
  id: 1,
  name: 'Siyah Basic Tişört',
  category: 'Üst Giyim',
  color: 'Siyah',
  season: 'Yaz',
  style: 'Günlük',
);
const _ceket = ClothingItem(
  id: 2,
  name: 'Siyah Deri Ceket',
  category: 'Dış Giyim',
  color: 'Siyah',
  season: 'Sonbahar',
  style: 'Klasik',
);
const _ayakkabi = ClothingItem(
  id: 3,
  name: 'Beyaz Spor Ayakkabı',
  category: 'Ayakkabı',
  color: 'Beyaz',
  season: 'Dört Mevsim',
  style: 'Spor',
);
const _esarp = ClothingItem(
  id: 4,
  name: 'İpek Desenli Eşarp',
  category: 'Aksesuar',
  color: 'Kırmızı',
  season: 'İlkbahar',
  style: 'Klasik',
);

const _liste = [_tisort, _ceket, _ayakkabi, _esarp];

void main() {
  group('kiyafetleriFiltrele', () {
    test('boş arama ve "Tümü" tüm listeyi döndürür', () {
      expect(kiyafetleriFiltrele(_liste), _liste);
    });

    test('renge göre arama büyük/küçük harf duyarsızdır', () {
      expect(kiyafetleriFiltrele(_liste, arama: 'siyah'), [_tisort, _ceket]);
      expect(kiyafetleriFiltrele(_liste, arama: 'SİYAH'), [_tisort, _ceket]);
    });

    test('Türkçe İ harfi doğru eşleşir', () {
      expect(kiyafetleriFiltrele(_liste, arama: 'ipek'), [_esarp]);
    });

    test('kategori filtresi uygulanır', () {
      expect(kiyafetleriFiltrele(_liste, kategori: 'Ayakkabı'), [_ayakkabi]);
    });

    test('arama + kategori birlikte uygulanır', () {
      expect(
        kiyafetleriFiltrele(_liste, arama: 'siyah', kategori: 'Dış Giyim'),
        [_ceket],
      );
    });

    test('eşleşme yoksa boş liste döner', () {
      expect(kiyafetleriFiltrele(_liste, arama: 'xyz'), isEmpty);
      expect(kiyafetleriFiltrele(const [], arama: 'siyah'), isEmpty);
    });
  });

  test('kategoridekiKiyafetSayisi doğru sayar', () {
    expect(kategoridekiKiyafetSayisi(_liste, tumKategoriler), 4);
    expect(kategoridekiKiyafetSayisi(_liste, 'Aksesuar'), 1);
    expect(kategoridekiKiyafetSayisi(_liste, 'Alt Giyim'), 0);
  });

  test('ayniRenktekiDigerKiyafet kendisi dışındaki ilk eşleşmeyi bulur', () {
    expect(ayniRenktekiDigerKiyafet(_liste, _tisort), _ceket);
    expect(ayniRenktekiDigerKiyafet(_liste, _esarp), isNull);
  });

  test('mevsimIpucu her mevsim için mesaj üretir', () {
    expect(mevsimIpucu('Kış'), contains('Soğuk'));
    expect(mevsimIpucu('İlkbahar'), mevsimIpucu('Sonbahar'));
    expect(mevsimIpucu('Bilinmeyen'), 'Mevsim bilgisi belirtilmemiş.');
  });

  test('bosSonucMesaji duruma göre farklı mesaj verir', () {
    expect(
      bosSonucMesaji(arama: '', kategori: tumKategoriler),
      startsWith('Gardırobun boş'),
    );
    expect(
      bosSonucMesaji(arama: ' xyz ', kategori: tumKategoriler),
      '"xyz" ile eşleşen kıyafet bulunamadı.',
    );
    expect(
      bosSonucMesaji(arama: '', kategori: 'Aksesuar'),
      '"Aksesuar" kategorisinde henüz kıyafet yok.',
    );
    expect(
      bosSonucMesaji(arama: 'xyz', kategori: 'Aksesuar'),
      contains('kategorisinde sonuç vermedi'),
    );
  });

  // 4. HAFTA: Koleksiyon fonksiyonlari (List / Map / Set)

  test('farkliRenkler tekrar eden renkleri bir kez sayar', () {
    expect(farkliRenkler(_liste), {'Siyah', 'Beyaz', 'Kırmızı'});
    expect(farkliRenkler(const []), isEmpty);
  });

  test('kategoriyeGoreGrupla kıyafetleri kategoriye göre ayırır', () {
    final gruplar = kategoriyeGoreGrupla([..._liste, _tisort]);

    expect(gruplar.keys, hasLength(4));
    expect(gruplar['Üst Giyim'], [_tisort, _tisort]);
    expect(gruplar['Ayakkabı'], [_ayakkabi]);
  });

  test('filtreKategorileri bilinen sırayı korur, bilinmeyenleri sona ekler', () {
    const sapka = ClothingItem(
      id: 5,
      name: 'Hasır Şapka',
      category: 'Şapka',
      color: 'Bej',
      season: 'Yaz',
      style: 'Günlük',
    );
    const bilinenSira = ['Üst Giyim', 'Alt Giyim', 'Ayakkabı', 'Aksesuar'];

    expect(
      filtreKategorileri([sapka, ..._liste], bilinenSira),
      ['Üst Giyim', 'Ayakkabı', 'Aksesuar', 'Dış Giyim', 'Şapka'],
    );
  });
}
