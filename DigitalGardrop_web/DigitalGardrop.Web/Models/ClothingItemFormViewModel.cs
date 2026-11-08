
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace DigitalGardrop.Web.Models
{
    public class ClothingItemFormViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Kıyafet adı zorunludur.")]
        [StringLength(80, MinimumLength = 3,
            ErrorMessage = "Kıyafet adı 3-80 karakter olmalıdır.")]
        [Display(Name = "Kıyafet Adı")]
        public string Name { get; set; } = "";

        [Required(ErrorMessage = "Kategori seçiniz.")]
        [Display(Name = "Kategori")]
        public int? CategoryId { get; set; }

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

        [ValidateNever]
        public IEnumerable<SelectListItem> Categories
            { get; set; } = new List<SelectListItem>();
    }
}
