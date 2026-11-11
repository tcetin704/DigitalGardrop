import 'package:flutter_test/flutter_test.dart';
import 'package:digital_gardrop_mobile/models/category.dart';
import 'package:digital_gardrop_mobile/models/clothing_item.dart';

// 4. HAFTA: Model siniflari ve JSON donusum testleri.

void main() {
  group('ClothingItem.fromJson', () {
    test('tüm alanları olan geçerli JSON doğru çözülür', () {
      final kiyafet = ClothingItem.fromJson({
        'id': 1,
        'name': 'Siyah Basic Tişört',
        'category': 'Üst Giyim',
        'categoryId': 1,
        'color': 'Siyah',
        'season': 'Yaz',
        'style': 'Günlük',
        'imageUrl': 'https://ornek.com/tisort.jpg',
        'userId': 7,
      });

      expect(kiyafet.id, 1);
      expect(kiyafet.name, 'Siyah Basic Tişört');
      expect(kiyafet.category, 'Üst Giyim');
      expect(kiyafet.categoryId, 1);
      expect(kiyafet.color, 'Siyah');
      expect(kiyafet.season, 'Yaz');
      expect(kiyafet.style, 'Günlük');
      expect(kiyafet.imageUrl, 'https://ornek.com/tisort.jpg');
      expect(kiyafet.userId, 7);
    });

    test('isteğe bağlı alanlar eksikse varsayılan değer kullanılır', () {
      final kiyafet = ClothingItem.fromJson({'id': 2, 'name': 'Kot Ceket'});

      expect(kiyafet.category, ClothingItem.belirtilmemis);
      expect(kiyafet.color, ClothingItem.belirtilmemis);
      expect(kiyafet.season, ClothingItem.belirtilmemis);
      expect(kiyafet.style, ClothingItem.belirtilmemis);
      expect(kiyafet.imageUrl, isNull);
      expect(kiyafet.categoryId, isNull);
      expect(kiyafet.userId, isNull);
    });

    test('null ve boş metin alanları kontrollü ele alınır', () {
      final kiyafet = ClothingItem.fromJson({
        'id': 3,
        'name': 'Bot',
        'color': null,
        'imageUrl': '   ',
        'userId': null,
      });

      expect(kiyafet.color, ClothingItem.belirtilmemis);
      expect(kiyafet.imageUrl, isNull);
      expect(kiyafet.userId, isNull);
    });

    test('metin olarak gelen sayılar çevrilir', () {
      final kiyafet = ClothingItem.fromJson({
        'id': '15',
        'name': 'Kaban',
        'categoryId': '4',
      });

      expect(kiyafet.id, 15);
      expect(kiyafet.categoryId, 4);
    });

    test('categoryName alanı category yerine kabul edilir', () {
      final kiyafet = ClothingItem.fromJson({
        'id': 4,
        'name': 'Saat',
        'categoryName': 'Aksesuar',
      });

      expect(kiyafet.category, 'Aksesuar');
    });

    test('zorunlu alan eksik veya bozuksa FormatException fırlatır', () {
      expect(
        () => ClothingItem.fromJson({'name': 'Kimliksiz'}),
        throwsFormatException,
      );
      expect(
        () => ClothingItem.fromJson({'id': 'abc', 'name': 'Bozuk'}),
        throwsFormatException,
      );
      expect(() => ClothingItem.fromJson({'id': 5}), throwsFormatException);
      expect(
        () => ClothingItem.fromJson({'id': 5, 'name': ''}),
        throwsFormatException,
      );
    });
  });

  test('toJson ve fromJson birbirinin tersidir', () {
    const kiyafet = ClothingItem(
      id: 9,
      name: 'İpek Desenli Eşarp',
      category: 'Aksesuar',
      categoryId: 5,
      color: 'Kırmızı',
      season: 'İlkbahar',
      style: 'Klasik',
    );

    final json = kiyafet.toJson();

    expect(json['name'], 'İpek Desenli Eşarp');
    expect(json['imageUrl'], isNull);
    expect(ClothingItem.fromJson(json), kiyafet);
  });

  group('kiyafetListesiniCoz', () {
    test('bozuk kayıtları atlar, geçerlileri döndürür', () {
      final liste = kiyafetListesiniCoz([
        {'id': 1, 'name': 'Tişört', 'color': 'Siyah'},
        {'name': 'Kimliksiz kayıt'},
        'nesne olmayan değer',
        null,
        {'id': 2, 'name': 'Pantolon'},
      ]);

      expect(liste.map((k) => k.id).toList(), [1, 2]);
    });

    test('boş liste boş sonuç verir', () {
      expect(kiyafetListesiniCoz([]), isEmpty);
    });

    test('liste olmayan yanıt FormatException fırlatır', () {
      expect(() => kiyafetListesiniCoz({'id': 1}), throwsFormatException);
      expect(() => kiyafetListesiniCoz(null), throwsFormatException);
    });
  });

  group('Category', () {
    test('fromJson / toJson', () {
      final kategori = Category.fromJson({'id': 3, 'name': 'Ayakkabı'});

      expect(kategori, const Category(id: 3, name: 'Ayakkabı'));
      expect(kategori.toJson(), {'id': 3, 'name': 'Ayakkabı'});
    });

    test('ad eksikse FormatException fırlatır', () {
      expect(() => Category.fromJson({'id': 3}), throwsFormatException);
    });
  });
}
