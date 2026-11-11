# Mobil – Web API Sözleşmesi (Taslak)

> **Durum (4. hafta):** Mobil taraf bu sözleşmeye göre hazırlandı
> (`ClothingItem.fromJson`, `ApiClient`). Web API henüz yazılmadı; denemeler
> `tool/mock_api_sunucu.dart` sahte sunucusuyla yapılıyor. Alan adları ve uç
> noktalar web ekibiyle teyit edildikçe bu belge güncellenecek. Flutter uygulaması
> SQL Server'a doğrudan bağlanmaz, yalnızca bu REST API'yi kullanır.

## Kıyafet (ClothingItem)

Web tarafındaki `Models/ClothingItem.cs` ile eşleşen alanlar. ASP.NET Core
varsayılan olarak JSON alan adlarını **camelCase** üretir.

| JSON alanı   | Dart tipi  | Zorunlu | Not |
|--------------|------------|---------|-----|
| `id`         | `int`      | Evet    | |
| `name`       | `String`   | Evet    | 3–80 karakter |
| `category`   | `String`   | Evet    | Kategori adı (ör. "Üst Giyim") |
| `categoryId` | `int?`     | Hayır   | Categories tablosuna yabancı anahtar |
| `color`      | `String`   | Evet    | En fazla 30 karakter |
| `season`     | `String`   | Evet    | İlkbahar, Yaz, Sonbahar, Kış, Dört Mevsim |
| `style`      | `String`   | Evet    | Günlük, Spor, Klasik, Resmi |
| `imageUrl`   | `String?`  | Hayır   | Görsel yoksa `null`; mobil yedek ikon gösterir |
| `userId`     | `int?`     | Hayır   | Kimlik doğrulama gelene kadar boş olabilir |

Örnek yanıt:

```json
{
  "id": 1,
  "name": "Siyah Basic Tişört",
  "category": "Üst Giyim",
  "categoryId": 1,
  "color": "Siyah",
  "season": "Yaz",
  "style": "Günlük",
  "imageUrl": null,
  "userId": null
}
```

## Kategori (Category)

| JSON alanı | Dart tipi | Not |
|------------|-----------|-----|
| `id`       | `int`     | 1: Üst Giyim, 2: Alt Giyim, 3: Ayakkabı, 4: Dış Giyim, 5: Aksesuar |
| `name`     | `String`  | Benzersiz |

## Beklenen uç noktalar

| Metot  | Yol                       | Başarılı yanıt | Mobilde kullanım |
|--------|---------------------------|----------------|------------------|
| GET    | `/api/clothingitems`      | 200 + liste    | Gardırobum listesi (4. hafta) |
| GET    | `/api/clothingitems/{id}` | 200 / 404      | Kıyafet detayı |
| POST   | `/api/clothingitems`      | 201 / 400      | Kıyafet ekleme (5. hafta) |
| PUT    | `/api/clothingitems/{id}` | 204 / 400 / 404| Kıyafet düzenleme (5. hafta) |
| DELETE | `/api/clothingitems/{id}` | 204 / 404      | Kıyafet silme (5. hafta) |
| GET    | `/api/categories`         | 200 + liste    | Kategori filtresi |

Yetkisiz isteklerde `401`, başka kullanıcıya ait kayıtta `403` beklenir.

## Geliştirme ortamında taban adres

| Çalıştırılan yer | Taban adres |
|------------------|-------------|
| iOS Simulator    | `http://localhost:5038` |
| Android emülatörü| `http://10.0.2.2:5038` (emülatör için host makinenin adresi) |

Gerçek telefonda: `--dart-define=API_BASE_URL=http://<bilgisayar-IP>:5038`

Port, web projesindeki `Properties/launchSettings.json` içindeki `http`
profilinden alınmıştır. Taban adreste gizli anahtar bulunmaz.

## Mobil tarafın eksik/bozuk veriye davranışı

| Durum | Mobil uygulamanın davranışı |
|-------|-----------------------------|
| `id` veya `name` eksik / bozuk | Kayıt atlanır, diğerleri gösterilir |
| `color`, `season`, `style`, `category` eksik | "Belirtilmemiş" gösterilir |
| `imageUrl` boş veya `null` | Kategori ikonu gösterilir |
| Sayı alanı metin olarak gelir (`"5"`) | Sayıya çevrilir |
| Yanıt liste değil / geçersiz JSON | "Sunucudan gelen veri okunamadı" + Tekrar dene |
| 401/403, 404, 5xx | Duruma özel mesaj + Tekrar dene |
| 8 sn içinde yanıt yok | Zaman aşımı mesajı + Tekrar dene |

## Web ekibine sorulacaklar

- [ ] JSON alan adları yukarıdaki gibi camelCase mi olacak?
- [ ] Liste yanıtında `category` adı da dönecek mi, yoksa yalnızca `categoryId` mi?
- [ ] `/api/categories` uç noktası eklenecek mi?
- [ ] Geliştirmede HTTP (5038) açık kalacak mı, yoksa sadece HTTPS mi?
