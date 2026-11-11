/// Gardıroptaki tek bir kıyafeti temsil eden model sınıfı.
///
/// Alan adları web tarafındaki ClothingItem modeliyle aynı tutulmuştur
/// (bkz. docs/api_sozlesmesi.md). 4. haftada bu sınıfa fromJson/toJson
/// dönüşümleri ve categoryId/userId alanları eklenecektir.
class ClothingItem {
  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.season,
    required this.style,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String category;
  final String color;
  final String season;
  final String style;

  /// Görsel henüz eklenmemiş olabilir; bu yüzden nullable.
  final String? imageUrl;
}
