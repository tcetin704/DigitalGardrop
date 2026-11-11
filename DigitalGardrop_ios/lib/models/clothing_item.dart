import 'json_yardimcilari.dart';

/// Gardıroptaki tek bir kıyafeti temsil eden model sınıfı.
///
/// Alan adları web tarafındaki ClothingItem modeliyle aynı tutulmuştur
/// (bkz. docs/api_sozlesmesi.md).
class ClothingItem {
  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.season,
    required this.style,
    this.imageUrl,
    this.categoryId,
    this.userId,
  });

  /// Eksik isteğe bağlı alanlar için gösterilen değer.
  static const String belirtilmemis = 'Belirtilmemiş';

  final int id;
  final String name;
  final String category;
  final String color;
  final String season;
  final String style;

  /// Görsel henüz eklenmemiş olabilir; bu yüzden nullable.
  final String? imageUrl;

  /// 4. HAFTA: Web API ile uyum için eklenen alanlar.
  final int? categoryId;
  final int? userId;

  /// 4. HAFTA: JSON -> ClothingItem dönüşümü.
  ///
  /// - `id` ve `name` zorunludur; yoksa [FormatException] fırlatılır.
  /// - `category`, `color`, `season`, `style` eksikse "Belirtilmemiş" olur.
  /// - `imageUrl` boş metin ise null kabul edilir.
  /// - Sayı alanları metin olarak gelirse ("5") sayıya çevrilir.
  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: zorunluInt(json, 'id'),
      name: zorunluString(json, 'name'),
      category:
          istegeBagliString(json, 'category') ??
          istegeBagliString(json, 'categoryName') ??
          belirtilmemis,
      color: istegeBagliString(json, 'color') ?? belirtilmemis,
      season: istegeBagliString(json, 'season') ?? belirtilmemis,
      style: istegeBagliString(json, 'style') ?? belirtilmemis,
      imageUrl: istegeBagliString(json, 'imageUrl'),
      categoryId: istegeBagliInt(json, 'categoryId'),
      userId: istegeBagliInt(json, 'userId'),
    );
  }

  /// 4. HAFTA: ClothingItem -> JSON dönüşümü (POST/PUT istekleri için).
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'categoryId': categoryId,
    'color': color,
    'season': season,
    'style': style,
    'imageUrl': imageUrl,
    'userId': userId,
  };

  @override
  bool operator ==(Object other) =>
      other is ClothingItem &&
      other.id == id &&
      other.name == name &&
      other.category == category &&
      other.color == color &&
      other.season == season &&
      other.style == style &&
      other.imageUrl == imageUrl &&
      other.categoryId == categoryId &&
      other.userId == userId;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    color,
    season,
    style,
    imageUrl,
    categoryId,
    userId,
  );

  @override
  String toString() => 'ClothingItem($id, $name)';
}

/// API'den gelen liste yanıtını ClothingItem listesine çevirir.
///
/// Yanıt bir liste değilse [FormatException] fırlatır. Listedeki bozuk
/// kayıtlar (nesne olmayan veya zorunlu alanı eksik olanlar) atlanır,
/// böylece tek bir hatalı kayıt tüm ekranı bozmaz.
/// (where / map / whereType koleksiyon dönüşümleri örneği)
List<ClothingItem> kiyafetListesiniCoz(Object? json) {
  if (json is! List) {
    throw const FormatException('Kıyafet listesi bekleniyordu.');
  }

  return json
      .whereType<Map<String, dynamic>>()
      .map(_guvenliCoz)
      .whereType<ClothingItem>()
      .toList();
}

ClothingItem? _guvenliCoz(Map<String, dynamic> json) {
  try {
    return ClothingItem.fromJson(json);
  } on FormatException {
    return null;
  }
}
