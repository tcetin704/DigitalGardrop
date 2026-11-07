
# Dijital Gardırop

ASP.NET Core MVC ve Flutter teknolojileriyle geliştirilen
web ve mobil tabanlı dijital gardırop platformu.

## Projenin Amacı

Kullanıcıların kıyafetlerini dijital ortamda yönetmesini,
kombin oluşturmasını ve kombinlerini diğer kullanıcılarla
paylaşmasını sağlamak.

## Kullanılan Teknolojiler

- ASP.NET Core MVC (.NET 10)
- C#
- Razor Views
- HTML, CSS, Bootstrap
- Git ve GitHub

Planlanan teknolojiler:
- ASP.NET Core Web API
- Entity Framework Core
- Microsoft SQL Server
- Flutter / Dart
- Yapay zekâ servisleri

## Tamamlanan Özellikler (1. Hafta)

- ASP.NET Core MVC proje yapısı
- Ana sayfa ve ortak navigasyon menüsü
- Dinamik kıyafet kategorileri
- ClothingItem veri modeli
- Örnek kıyafetlerin listelenmesi
- Kıyafet ekleme formu
- GET ve POST işlemleri
- Model Binding
- Sayfalar arası yönlendirme

Not: Kıyafetler şu anda bellekte tutulmaktadır.
Uygulama yeniden başlatıldığında yeni kayıtlar kaybolur.

## Projeyi Çalıştırma

Gereksinim: .NET 10 SDK

Projeyi bilgisayarınıza klonlayın:

git clone https://github.com/tcetin704/DigitalGardrop.git

Proje klasörüne girin:

cd DigitalGardrop/DigitalGardrop.Web

Uygulamayı başlatın:

dotnet run

Terminalde gösterilen localhost adresini tarayıcıda açın.

## Sayfalar

/ - Ana sayfa

/ClothingItems - Gardırobum

/ClothingItems/Create - Yeni kıyafet ekleme

## Veritabanı

MS SQL Server ve Entity Framework Core entegrasyonu
planlanmaktadır. İlk haftada veritabanı kullanılmamaktadır.

## Dersler

- BLM4581 Ağ Tabanlı Teknolojiler ve Uygulamaları
- iOS / Mobil Uygulama Geliştirme

Her iki ders kapsamında ortak bir backend ve
veritabanı kullanılması hedeflenmektedir.
