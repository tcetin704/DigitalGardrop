
using DigitalGardrop.Web.Models;
using Microsoft.EntityFrameworkCore;

namespace DigitalGardrop.Web.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(
            DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<ClothingItem> ClothingItems
            => Set<ClothingItem>();

        public DbSet<ClothingCategory> Categories
            => Set<ClothingCategory>();

        public DbSet<AppUser> Users
            => Set<AppUser>();

        protected override void OnModelCreating(
            ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Kategori adlari benzersiz olacak.
            modelBuilder.Entity<ClothingCategory>()
                .HasIndex(c => c.Name)
                .IsUnique();

            // E-posta adresleri benzersiz olacak.
            modelBuilder.Entity<AppUser>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // Kategori - Kiyafet: 1-N
            modelBuilder.Entity<ClothingItem>()
                .HasOne(k => k.CategoryEntity)
                .WithMany(c => c.ClothingItems)
                .HasForeignKey(k => k.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            // Kullanici - Kiyafet: 1-N
            modelBuilder.Entity<ClothingItem>()
                .HasOne(k => k.Owner)
                .WithMany(u => u.ClothingItems)
                .HasForeignKey(k => k.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Baslangic kategorileri
            modelBuilder.Entity<ClothingCategory>().HasData(
                new ClothingCategory
                {
                    Id = 1,
                    Name = "Üst Giyim"
                },
                new ClothingCategory
                {
                    Id = 2,
                    Name = "Alt Giyim"
                },
                new ClothingCategory
                {
                    Id = 3,
                    Name = "Ayakkabı"
                },
                new ClothingCategory
                {
                    Id = 4,
                    Name = "Dış Giyim"
                },
                new ClothingCategory
                {
                    Id = 5,
                    Name = "Aksesuar"
                }
            );

            // Baslangic kiyafetleri
            modelBuilder.Entity<ClothingItem>().HasData(
                new ClothingItem
                {
                    Id = 1,
                    Name = "Siyah Basic Tişört",
                    Category = "Üst Giyim",
                    CategoryId = 1,
                    Color = "Siyah",
                    Season = "Yaz",
                    Style = "Günlük"
                },
                new ClothingItem
                {
                    Id = 2,
                    Name = "Mavi Kot Pantolon",
                    Category = "Alt Giyim",
                    CategoryId = 2,
                    Color = "Mavi",
                    Season = "Dört Mevsim",
                    Style = "Günlük"
                },
                new ClothingItem
                {
                    Id = 3,
                    Name = "Beyaz Spor Ayakkabı",
                    Category = "Ayakkabı",
                    CategoryId = 3,
                    Color = "Beyaz",
                    Season = "Dört Mevsim",
                    Style = "Spor"
                }
            );
        }
    }
}
