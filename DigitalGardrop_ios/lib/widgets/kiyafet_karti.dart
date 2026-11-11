import 'package:flutter/material.dart';

import '../models/clothing_item.dart';

/// Kategoriye göre ikon seçer. (Dart 3 switch ifadesi örneği)
IconData kategoriIkonu(String kategori) => switch (kategori) {
  'Üst Giyim' => Icons.checkroom,
  'Alt Giyim' => Icons.accessibility_new,
  'Ayakkabı' => Icons.directions_walk,
  'Dış Giyim' => Icons.dry_cleaning,
  'Aksesuar' => Icons.watch,
  _ => Icons.category,
};

/// Gardırobum listesindeki tek bir kıyafet kartı.
class KiyafetKarti extends StatelessWidget {
  const KiyafetKarti({super.key, required this.kiyafet, required this.onTap});

  final ClothingItem kiyafet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(kategoriIkonu(kiyafet.category))),
        // Uzun adlar tek satirda "..." ile kisaltilir.
        title: Text(
          kiyafet.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${kiyafet.category} • ${kiyafet.color} • ${kiyafet.season}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
