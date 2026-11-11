import 'json_yardimcilari.dart';

/// Kıyafet kategorisi. Web tarafındaki ClothingCategory modeliyle eşleşir.
class Category {
  const Category({required this.id, required this.name});

  final int id;
  final String name;

  /// API'den gelen JSON nesnesini Category nesnesine çevirir.
  /// id veya name eksikse FormatException fırlatır.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: zorunluInt(json, 'id'),
      name: zorunluString(json, 'name'),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      other is Category && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Category($id, $name)';
}
