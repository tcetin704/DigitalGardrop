import 'package:flutter/material.dart';

import '../data/ornek_kiyafetler.dart';
import '../logic/gardirop_islemleri.dart';
import '../models/clothing_item.dart';
import '../services/api_exception.dart';
import '../services/kiyafet_repository.dart';
import '../widgets/kiyafet_karti.dart';
import 'kiyafet_detay_sayfasi.dart';

/// Ekranın hangi durumda olduğunu belirtir.
enum _YuklemeDurumu { yukleniyor, hazir, hata }

/// Gardırobum ekranı: veriyi yükler, arama ve kategori filtresi uygular.
class GardirobumSayfasi extends StatefulWidget {
  const GardirobumSayfasi({super.key, this.repository});

  /// Ana sayfadan Navigator.pushNamed ile açılırken kullanılan rota adı.
  static const String routeName = '/gardirobum';

  /// Veri kaynağı. Verilmezse Web API kullanılır.
  /// (Testlerde sahte veya yerel kaynak verilebilir.)
  final KiyafetRepository? repository;

  @override
  State<GardirobumSayfasi> createState() => _GardirobumSayfasiState();
}

class _GardirobumSayfasiState extends State<GardirobumSayfasi> {
  final TextEditingController _aramaController = TextEditingController();

  late KiyafetRepository _repository;
  late bool _repositoryBizim;

  _YuklemeDurumu _durum = _YuklemeDurumu.yukleniyor;
  List<ClothingItem> _kiyafetler = const [];
  ApiException? _hata;
  String _kaynakAdi = '';

  String _arama = '';
  String _secilenKategori = tumKategoriler;

  @override
  void initState() {
    super.initState();
    _repositoryBizim = widget.repository == null;
    _repository = widget.repository ?? ApiKiyafetRepository();
    _kiyafetleriYukle();
  }

  @override
  void dispose() {
    _aramaController.dispose();
    // Kaynagi bu ekran olusturduysa baglantiyi da bu ekran kapatir.
    if (_repositoryBizim) {
      _repository.kapat();
    }
    super.dispose();
  }

  // 4. HAFTA: Yukleme -> basari / hata akisi
  Future<void> _kiyafetleriYukle() async {
    // initState'ten ilk cagrida durum zaten "yukleniyor"dur.
    if (_durum != _YuklemeDurumu.yukleniyor) {
      setState(() {
        _durum = _YuklemeDurumu.yukleniyor;
        _hata = null;
      });
    }

    try {
      final liste = await _repository.kiyafetleriGetir();
      if (!mounted) return;
      setState(() {
        _kiyafetler = liste;
        _kaynakAdi = _repository.kaynakAdi;
        _durum = _YuklemeDurumu.hazir;
      });
    } on ApiException catch (hata) {
      if (!mounted) return;
      setState(() {
        _hata = hata;
        _durum = _YuklemeDurumu.hata;
      });
    } catch (hata) {
      if (!mounted) return;
      setState(() {
        _hata = ApiException(
          ApiHataTuru.bilinmeyen,
          ayrinti: hata.toString(),
        );
        _durum = _YuklemeDurumu.hata;
      });
    }
  }

  /// API'ye ulaşılamadığında demo için yerel örnek verilere geçer.
  void _ornekVeriyleDevamEt() {
    if (_repositoryBizim) {
      _repository.kapat();
    }
    setState(() {
      _repository = OrnekVeriRepository();
      _repositoryBizim = true;
    });
    _kiyafetleriYukle();
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
          tumKiyafetler: _kiyafetler,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gardırobum'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('yenileButonu'),
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh),
            onPressed: _durum == _YuklemeDurumu.yukleniyor
                ? null
                : _kiyafetleriYukle,
          ),
        ],
      ),
      body: SafeArea(child: _govde()),
    );
  }

  Widget _govde() {
    switch (_durum) {
      case _YuklemeDurumu.yukleniyor:
        return const _YukleniyorGorunumu();
      case _YuklemeDurumu.hata:
        return _HataGorunumu(
          hata: _hata!,
          tekrarDene: _kiyafetleriYukle,
          ornekVeriyleDevamEt: _repository is OrnekVeriRepository
              ? null
              : _ornekVeriyleDevamEt,
        );
      case _YuklemeDurumu.hazir:
        return _listeGorunumu();
    }
  }

  Widget _listeGorunumu() {
    final sonuclar = kiyafetleriFiltrele(
      _kiyafetler,
      arama: _arama,
      kategori: _secilenKategori,
    );
    final kategoriSecenekleri = [
      tumKategoriler,
      ...filtreKategorileri(_kiyafetler, kategoriler),
    ];
    final renkSayisi = farkliRenkler(_kiyafetler).length;

    return Column(
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
              for (final kategori in kategoriSecenekleri)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      '$kategori '
                      '(${kategoridekiKiyafetSayisi(_kiyafetler, kategori)})',
                    ),
                    selected: _secilenKategori == kategori,
                    onSelected: (_) =>
                        setState(() => _secilenKategori = kategori),
                  ),
                ),
            ],
          ),
        ),

        // SONUC SAYISI VE VERI KAYNAGI
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${sonuclar.length} / ${_kiyafetler.length} kıyafet • '
                  '$renkSayisi farklı renk',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                _kaynakAdi,
                key: const Key('veriKaynagi'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
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
    );
  }
}

/// Veri yüklenirken gösterilen görünüm.
class _YukleniyorGorunumu extends StatelessWidget {
  const _YukleniyorGorunumu();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Kıyafetler yükleniyor...'),
        ],
      ),
    );
  }
}

/// Yükleme başarısız olduğunda gösterilen görünüm.
class _HataGorunumu extends StatelessWidget {
  const _HataGorunumu({
    required this.hata,
    required this.tekrarDene,
    required this.ornekVeriyleDevamEt,
  });

  final ApiException hata;
  final VoidCallback tekrarDene;

  /// null ise "örnek verilerle devam et" düğmesi gösterilmez.
  final VoidCallback? ornekVeriyleDevamEt;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hata.baglantiHatasiMi ? Icons.wifi_off : Icons.error_outline,
              size: 64,
              color: renkler.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Kıyafetler yüklenemedi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hata.kullaniciMesaji,
              key: const Key('hataMesaji'),
              textAlign: TextAlign.center,
            ),
            if (hata.ayrinti != null) ...[
              const SizedBox(height: 8),
              Text(
                hata.ayrinti!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: renkler.outline),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('tekrarDeneButonu'),
              onPressed: tekrarDene,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
            if (ornekVeriyleDevamEt != null)
              TextButton(
                key: const Key('ornekVeriButonu'),
                onPressed: ornekVeriyleDevamEt,
                child: const Text('Örnek verilerle devam et'),
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
