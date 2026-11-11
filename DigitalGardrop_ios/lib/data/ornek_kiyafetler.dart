import '../models/clothing_item.dart';

// 3. HAFTA: YEREL ORNEK VERILER
// Web API hazir olana kadar ekranlar bu listeyle calisir.
// Kategori, mevsim ve stil degerleri web formundaki seceneklerle aynidir.

const List<String> kategoriler = [
  'Üst Giyim',
  'Alt Giyim',
  'Ayakkabı',
  'Dış Giyim',
  'Aksesuar',
];

const List<ClothingItem> ornekKiyafetler = [
  ClothingItem(
    id: 1,
    name: 'Siyah Basic Tişört',
    category: 'Üst Giyim',
    color: 'Siyah',
    season: 'Yaz',
    style: 'Günlük',
  ),
  ClothingItem(
    id: 2,
    name: 'Mavi Kot Pantolon',
    category: 'Alt Giyim',
    color: 'Mavi',
    season: 'Dört Mevsim',
    style: 'Günlük',
  ),
  ClothingItem(
    id: 3,
    name: 'Beyaz Spor Ayakkabı',
    category: 'Ayakkabı',
    color: 'Beyaz',
    season: 'Dört Mevsim',
    style: 'Spor',
  ),
  ClothingItem(
    id: 4,
    name: 'Beyaz Oxford Gömlek',
    category: 'Üst Giyim',
    color: 'Beyaz',
    season: 'İlkbahar',
    style: 'Klasik',
  ),
  ClothingItem(
    id: 5,
    name: 'Bej Kumaş Pantolon',
    category: 'Alt Giyim',
    color: 'Bej',
    season: 'Sonbahar',
    style: 'Resmi',
  ),
  ClothingItem(
    id: 6,
    name: 'Kahverengi Deri Bot',
    category: 'Ayakkabı',
    color: 'Kahverengi',
    season: 'Kış',
    style: 'Günlük',
  ),
  ClothingItem(
    id: 7,
    name: 'Siyah Deri Ceket',
    category: 'Dış Giyim',
    color: 'Siyah',
    season: 'Sonbahar',
    style: 'Klasik',
  ),
  ClothingItem(
    id: 8,
    name: 'Lacivert Kaban',
    category: 'Dış Giyim',
    color: 'Lacivert',
    season: 'Kış',
    style: 'Resmi',
  ),
  ClothingItem(
    id: 9,
    name: 'İpek Desenli Eşarp',
    category: 'Aksesuar',
    color: 'Kırmızı',
    season: 'İlkbahar',
    style: 'Klasik',
  ),
  // Uzun ad: kart ve detay ekraninda tasma (overflow) testi icin.
  ClothingItem(
    id: 10,
    name: 'Oversize Yünlü Uzun Kollu Balıkçı Yaka Kazak (Kış Koleksiyonu)',
    category: 'Üst Giyim',
    color: 'Gri',
    season: 'Kış',
    style: 'Günlük',
  ),
];
