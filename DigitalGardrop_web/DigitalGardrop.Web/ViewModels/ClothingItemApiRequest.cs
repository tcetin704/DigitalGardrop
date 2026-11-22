
using System.ComponentModel.DataAnnotations;

namespace DigitalGardrop.Web.ViewModels
{
    public class ClothingItemApiRequest
    {
        [Required(ErrorMessage = "Kıyafet adı zorunludur.")]
        [StringLength(80, MinimumLength = 3)]
        public string Name { get; set; } = "";

        [Required(ErrorMessage = "Kategori seçiniz.")]
        public int? CategoryId { get; set; }

        [Required(ErrorMessage = "Renk zorunludur.")]
        [StringLength(30)]
        public string Color { get; set; } = "";

        [Required(ErrorMessage = "Mevsim zorunludur.")]
        public string Season { get; set; } = "";

        [Required(ErrorMessage = "Stil zorunludur.")]
        public string Style { get; set; } = "";

        [Url(ErrorMessage = "Geçerli bir görsel URL'si giriniz.")]
        public string? ImageUrl { get; set; }
    }
}
