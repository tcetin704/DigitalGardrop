
using System.ComponentModel.DataAnnotations;

namespace DigitalGardrop.Web.Models
{
    public class ClothingItem
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Kıyafet adı zorunludur.")]
        [StringLength(80, MinimumLength = 3,
            ErrorMessage = "Kıyafet adı 3-80 karakter olmalıdır.")]
        [Display(Name = "Kıyafet Adı")]
        public string Name { get; set; } = "";

        [Required(ErrorMessage = "Lütfen kategori seçiniz.")]
        [Display(Name = "Kategori")]
        public string Category { get; set; } = "";

        // Kategori iliskisi
        public int? CategoryId { get; set; }

        public ClothingCategory? CategoryEntity { get; set; }

        // Kullanici iliskisi
        public int? UserId { get; set; }

        public AppUser? Owner { get; set; }

        [Required(ErrorMessage = "Renk zorunludur.")]
        [StringLength(30)]
        [Display(Name = "Renk")]
        public string Color { get; set; } = "";

        [Required(ErrorMessage = "Mevsim seçiniz.")]
        [Display(Name = "Mevsim")]
        public string Season { get; set; } = "";

        [Required(ErrorMessage = "Stil seçiniz.")]
        [Display(Name = "Stil")]
        public string Style { get; set; } = "";

        [Display(Name = "Görsel Adresi")]
        public string? ImageUrl { get; set; }
    }
}
