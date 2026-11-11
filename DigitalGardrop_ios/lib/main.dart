import 'package:flutter/material.dart';

import 'screens/gardirobum_sayfasi.dart';

void main() {
  runApp(const DigitalGardropApp());
}

class DigitalGardropApp extends StatelessWidget {
  const DigitalGardropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dijital Gardırop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 3. HAFTA: Isimli rotalar ile sayfa gecisi
      initialRoute: '/',
      routes: {
        '/': (context) => const AnaSayfa(),
        GardirobumSayfasi.routeName: (context) => const GardirobumSayfasi(),
      },
    );
  }
}

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. HAFTA: DART VERI TIPLERI

    // String
    String kiyafetAdi = 'Siyah Basic Tişört';
    String kategori = 'Üst Giyim';
    String renk = 'Siyah';

    // int
    int kiyafetSayisi = 3;
    const int maksimumKiyafetSayisi = 100;

    // double
    double fiyat = 249.90;
    double indirimOrani = 0.20;

    // bool: Kiyafetin ozelliginden hesaplanan deger
    bool favoriMi = kiyafetAdi.startsWith('Siyah');

    // Null safety
    String? desen = kiyafetAdi.contains('Desenli') ? 'Desenli' : null;

    String desenBilgisi = desen ?? 'Belirtilmedi';

    // var
    var mevsim = 'Yaz';

    // final
    final String kullaniciAdi = 'Demo Kullanıcı';

    // Aritmetik operator
    double indirimliFiyat = fiyat * (1 - indirimOrani);

    // Karsilastirma operatoru
    bool kapasiteUygunMu = kiyafetSayisi < maksimumKiyafetSayisi;

    // Liste
    const List<String> kategoriler = [
      'Üst Giyim',
      'Alt Giyim',
      'Ayakkabı',
      'Dış Giyim',
      'Aksesuar',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dijital Gardırop'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Center(
                child: Icon(
                  Icons.checkroom,
                  size: 75,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  'Gardırobuna Hoş Geldin!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Merhaba, $kullaniciAdi!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'Kıyafetlerini yönet, kombinlerini oluştur ve tarzını paylaş.',
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // 3. HAFTA: Gardirobum sayfasina gecis
              Center(
                child: FilledButton.icon(
                  key: const Key('gardirobumButonu'),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    GardirobumSayfasi.routeName,
                  ),
                  icon: const Icon(Icons.checkroom),
                  label: const Text('Gardırobumu Aç'),
                ),
              ),

              const SizedBox(height: 25),

              // GARDIROP OZETI
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.deepPurple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gardırop Özeti',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Toplam kıyafet: $kiyafetSayisi'),
                        Text(
                          'Kapasite: $kiyafetSayisi / $maksimumKiyafetSayisi',
                        ),
                        Text('Mevsim: $mevsim'),
                        Text(
                          'Kapasite durumu: '
                          '${kapasiteUygunMu ? "Uygun" : "Dolu"}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // KATEGORILER
              const Text(
                'Kıyafet Kategorileri',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kategoriler.map((kategoriAdi) {
                  return Chip(
                    label: Text(kategoriAdi),
                    backgroundColor: Colors.deepPurple.shade50,
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              // KIYAFETLER
              const Text(
                'Gardırobum',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: Icon(
                    favoriMi ? Icons.favorite : Icons.favorite_border,
                    color: favoriMi ? Colors.red : Colors.grey,
                  ),
                  title: Text(kiyafetAdi),
                  subtitle: Text(
                    '$kategori - $renk\n'
                    'Desen: $desenBilgisi\n'
                    'Fiyat: ${fiyat.toStringAsFixed(2)} TL',
                  ),
                  isThreeLine: true,
                  trailing: Icon(
                    favoriMi ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
              ),

              const Card(
                child: ListTile(
                  leading: Icon(Icons.checkroom, color: Colors.deepPurple),
                  title: Text('Mavi Kot Pantolon'),
                  subtitle: Text('Alt Giyim - Mavi'),
                ),
              ),

              const Card(
                child: ListTile(
                  leading: Icon(Icons.checkroom, color: Colors.deepPurple),
                  title: Text('Beyaz Spor Ayakkabı'),
                  subtitle: Text('Ayakkabı - Beyaz'),
                ),
              ),

              const SizedBox(height: 20),

              // FIYAT HESAPLAMA
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fiyat Hesaplama',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Normal fiyat: '
                          '${fiyat.toStringAsFixed(2)} TL',
                        ),
                        Text(
                          'İndirim oranı: '
                          '%${(indirimOrani * 100).toStringAsFixed(0)}',
                        ),
                        Text(
                          'İndirimli fiyat: '
                          '${indirimliFiyat.toStringAsFixed(2)} TL',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
