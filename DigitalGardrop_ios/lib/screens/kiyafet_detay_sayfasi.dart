import 'package:flutter/material.dart';

import '../data/ornek_kiyafetler.dart';
import '../logic/gardirop_islemleri.dart';
import '../models/clothing_item.dart';
import '../widgets/kiyafet_karti.dart';
import 'gardirobum_sayfasi.dart';

/// Seçilen kıyafetin ayrıntılarını gösteren ekran.
class KiyafetDetaySayfasi extends StatelessWidget {
  const KiyafetDetaySayfasi({
    super.key,
    required this.kiyafet,
    this.tumKiyafetler = ornekKiyafetler,
  });

  final ClothingItem kiyafet;

  /// "Aynı renkte" önerisini bulmak için kullanılan liste.
  final List<ClothingItem> tumKiyafetler;

  void _gardirobaDon(BuildContext context) {
    // Arka arkaya birden fazla detay acildiysa hepsini kapatip
    // Gardirobum ekranina (veya ilk ekrana) geri doner.
    Navigator.popUntil(
      context,
      (route) =>
          route.settings.name == GardirobumSayfasi.routeName || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final benzer = ayniRenktekiDigerKiyafet(tumKiyafetler, kiyafet);

    return Scaffold(
      appBar: AppBar(title: const Text('Kıyafet Detayı'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _GorselAlani(imageUrl: kiyafet.imageUrl, kategori: kiyafet.category),
            const SizedBox(height: 16),

            // Uzun adlar alt satira gecer, tasma olmaz.
            Text(
              kiyafet.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _BilgiKutusu(baslik: 'Kategori', deger: kiyafet.category),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BilgiKutusu(baslik: 'Renk', deger: kiyafet.color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BilgiKutusu(baslik: 'Mevsim', deger: kiyafet.season),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BilgiKutusu(baslik: 'Stil', deger: kiyafet.style),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.wb_sunny_outlined),
                title: const Text('Mevsim ipucu'),
                subtitle: Text(mevsimIpucu(kiyafet.season)),
              ),
            ),

            // Ayni renkte baska kiyafet varsa oneri karti gosterilir.
            if (benzer != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(
                    'Aynı renkte: ${benzer.name}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text('Kombin için göz atabilirsin'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KiyafetDetaySayfasi(
                        kiyafet: benzer,
                        tumKiyafetler: tumKiyafetler,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _gardirobaDon(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Gardıroba dön'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Görsel varsa gösterir; yoksa veya yüklenemezse kategori ikonu gösterir.
class _GorselAlani extends StatelessWidget {
  const _GorselAlani({required this.imageUrl, required this.kategori});

  final String? imageUrl;
  final String kategori;

  @override
  Widget build(BuildContext context) {
    final yedekGorunum = Container(
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(kategoriIkonu(kategori), size: 72),
          const SizedBox(height: 8),
          const Text('Görsel henüz eklenmedi'),
        ],
      ),
    );

    final adres = imageUrl;
    if (adres == null || adres.isEmpty) {
      return yedekGorunum;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        adres,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => yedekGorunum,
      ),
    );
  }
}

/// Başlık + değer gösteren küçük bilgi kutusu.
class _BilgiKutusu extends StatelessWidget {
  const _BilgiKutusu({required this.baslik, required this.deger});

  final String baslik;
  final String deger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            deger,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
