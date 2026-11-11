import '../data/ornek_kiyafetler.dart';
import '../models/category.dart';
import '../models/clothing_item.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// 4. HAFTA: Ekranların veri kaynağı.
///
/// Ekranlar verinin API'den mi yoksa yerel listeden mi geldiğini bilmez;
/// yalnızca bu arayüzü kullanır. Böylece testlerde sahte kaynak verilebilir.
abstract class KiyafetRepository {
  /// Ekranda "veri kaynağı" etiketi olarak gösterilir.
  String get kaynakAdi;

  Future<List<ClothingItem>> kiyafetleriGetir();

  /// Kaynak bağlantı açıyorsa kapatır. Varsayılan: hiçbir şey yapmaz.
  void kapat() {}
}

/// Gerçek ASP.NET Core Web API'den veri çeken kaynak.
class ApiKiyafetRepository extends KiyafetRepository {
  ApiKiyafetRepository([ApiClient? api]) : _api = api ?? ApiClient();

  final ApiClient _api;

  @override
  String get kaynakAdi => 'Web API';

  @override
  Future<List<ClothingItem>> kiyafetleriGetir() async {
    final json = await _api.getJson('/api/clothingitems');
    try {
      return kiyafetListesiniCoz(json);
    } on FormatException catch (hata) {
      throw ApiException(ApiHataTuru.gecersizVeri, ayrinti: hata.message);
    }
  }

  /// Kategori uç noktası web ekibince eklendiğinde kullanılacak.
  Future<List<Category>> kategorileriGetir() async {
    final json = await _api.getJson('/api/categories');
    if (json is! List) {
      throw const ApiException(
        ApiHataTuru.gecersizVeri,
        ayrinti: 'Kategori listesi bekleniyordu.',
      );
    }
    try {
      return json
          .whereType<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList();
    } on FormatException catch (hata) {
      throw ApiException(ApiHataTuru.gecersizVeri, ayrinti: hata.message);
    }
  }

  @override
  void kapat() => _api.kapat();
}

/// API hazır değilken veya testlerde kullanılan yerel örnek veri kaynağı.
class OrnekVeriRepository extends KiyafetRepository {
  OrnekVeriRepository({this.kiyafetler = ornekKiyafetler});

  final List<ClothingItem> kiyafetler;

  @override
  String get kaynakAdi => 'Yerel örnek veri';

  @override
  Future<List<ClothingItem>> kiyafetleriGetir() async => kiyafetler;
}
