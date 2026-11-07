
using System.ComponentModel.DataAnnotations;

namespace DigitalGardrop.Web.Models
{
    public class ClothingCategory
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Kategori adı zorunludur.")]
        [StringLength(50, MinimumLength = 2)]
        [Display(Name = "Kategori Adı")]
        public string Name { get; set; } = "";

        // Bir kategoriye ait birden fazla kiyafet olabilir.
        public ICollection<ClothingItem> ClothingItems
            { get; set; } = new List<ClothingItem>();
    }
}
