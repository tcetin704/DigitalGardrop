
using System.ComponentModel.DataAnnotations;

namespace DigitalGardrop.Web.Models
{
    public class AppUser
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Kullanıcı adı zorunludur.")]
        [StringLength(80, MinimumLength = 2)]
        [Display(Name = "Kullanıcı Adı")]
        public string DisplayName { get; set; } = "";

        [Required(ErrorMessage = "E-posta zorunludur.")]
        [EmailAddress(ErrorMessage = "Geçerli bir e-posta giriniz.")]
        [StringLength(254)]
        [Display(Name = "E-posta")]
        public string Email { get; set; } = "";

        // Gercek sifre degil, sifrenin guvenli hash degeri saklanir.
        // Eski kullanici kayitlariyla uyumluluk icin nullable.
        [StringLength(512)]
        public string? PasswordHash { get; set; }

        // Roller: User veya Admin
        [Required]
        [StringLength(20)]
        public string Role { get; set; } = "User";

        [Url(ErrorMessage = "Geçerli bir görsel adresi giriniz.")]
        public string? ProfileImageUrl { get; set; }

        // Bir kullanicinin birden fazla kiyafeti olabilir.
        public ICollection<ClothingItem> ClothingItems
            { get; set; } = new List<ClothingItem>();
    }
}
