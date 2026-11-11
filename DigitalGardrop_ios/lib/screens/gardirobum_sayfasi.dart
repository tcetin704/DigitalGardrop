import 'package:flutter/material.dart';

import '../data/ornek_kiyafetler.dart';
import '../logic/gardirop_islemleri.dart';
import '../models/clothing_item.dart';
import '../widgets/kiyafet_karti.dart';
import 'kiyafet_detay_sayfasi.dart';

/// Gardırobum ekranı: arama, kategori filtresi ve kıyafet listesi.
class GardirobumSayfasi extends StatefulWidget {
  const GardirobumSayfasi({super.key, this.kiyafetler = ornekKiyafetler});

  /// Ana sayfadan Navigator.pushNamed ile açılırken kullanılan rota adı.
  static const String routeName = '/gardirobum';

  /// Gösterilecek kıyafetler. Varsayılan olarak yerel örnek veriler.
  /// (Testlerde boş liste vererek boş gardırop durumu denenebilir.)
  final List<ClothingItem> kiyafetler;

  @override
  State<GardirobumSayfasi> createState() => _GardirobumSayfasiState();
}

class _GardirobumSayfasiState extends State<GardirobumSayfasi> {
  final TextEditingController _aramaController = TextEditingController();
  String _arama = '';
  String _secilenKategori = tumKategoriler;

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  void _aramayiTemizle() {
    _aramaController.clear();
    setState(() => _arama = '');
  }

  void _detayaGit(ClothingItem kiyafet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KiyafetDetaySayfasi(
          kiyafet: kiyafet,
          tumKiyafetler: widget.kiyafetler,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sonuclar = kiyafetleriFiltrele(
      widget.kiyafetler,
      arama: _arama,
      kategori: _secilenKategori,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Gardırobum'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            // ARAMA ALANI
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                key: const Key('aramaAlani'),
                controller: _aramaController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Ad veya renge göre ara (ör. siyah)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _arama.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Aramayı temizle',
                          icon: const Icon(Icons.clear),
                          onPressed: _aramayiTemizle,
                        ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (deger) => setState(() => _arama = deger),
              ),
            ),

            // KATEGORI FILTRESI
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  for (final kategori in [tumKategoriler, ...kategoriler])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          '$kategori '
                          '(${kategoridekiKiyafetSayisi(widget.kiyafetler, kategori)})',
                        ),
                        selected: _secilenKategori == kategori,
                        onSelected: (_) =>
                            setState(() => _secilenKategori = kategori),
                      ),
                    ),
                ],
              ),
            ),

            // SONUC SAYISI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${sonuclar.length} / ${widget.kiyafetler.length} '
                      'kıyafet gösteriliyor',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    'Yerel örnek veri',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // LISTE VEYA BOS SONUC
            Expanded(
              child: sonuclar.isEmpty
                  ? _BosSonuc(
                      mesaj: bosSonucMesaji(
                        arama: _arama,
                        kategori: _secilenKategori,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: sonuclar.length,
                      itemBuilder: (context, index) {
                        final kiyafet = sonuclar[index];
                        return KiyafetKarti(
                          kiyafet: kiyafet,
                          onTap: () => _detayaGit(kiyafet),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filtre sonucu boş olduğunda gösterilen bilgilendirme alanı.
class _BosSonuc extends StatelessWidget {
  const _BosSonuc({required this.mesaj});

  final String mesaj;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(mesaj, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
