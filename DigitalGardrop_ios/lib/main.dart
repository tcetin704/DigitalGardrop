
import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> kategoriler = [
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
              const SizedBox(height: 15),

              const Center(
                child: Icon(
                  Icons.checkroom,
                  size: 85,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Gardırobuna Hoş Geldin!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Kıyafetlerini yönet, kombinlerini oluştur ve tarzını paylaş.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Kıyafet Kategorileri',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kategoriler.map((kategori) {
                  return Chip(
                    label: Text(kategori),
                    backgroundColor: Colors.deepPurple.shade50,
                  );
                }).toList(),
              ),

              const SizedBox(height: 35),

              const Text(
                'Gardırobum',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.checkroom,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Siyah Basic Tişört'),
                  subtitle: const Text('Üst Giyim - Siyah - Yaz'),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.checkroom,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Mavi Kot Pantolon'),
                  subtitle: const Text('Alt Giyim - Mavi'),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.checkroom,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Beyaz Spor Ayakkabı'),
                  subtitle: const Text('Ayakkabı - Beyaz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
