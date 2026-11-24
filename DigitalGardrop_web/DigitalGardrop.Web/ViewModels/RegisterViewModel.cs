
using System.ComponentModel.DataAnnotations;

namespace DigitalGardrop.Web.ViewModels
{
    public class RegisterViewModel
    {
        [Required(ErrorMessage = "Kullanıcı adı zorunludur.")]
        [StringLength(80, MinimumLength = 2)]
        [Display(Name = "Kullanıcı Adı")]
        public string DisplayName { get; set; } = "";

        [Required(ErrorMessage = "E-posta zorunludur.")]
        [EmailAddress(ErrorMessage = "Geçerli bir e-posta giriniz.")]
        [StringLength(254)]
        [Display(Name = "E-posta")]
        public string Email { get; set; } = "";

        [Required(ErrorMessage = "Şifre zorunludur.")]
        [StringLength(128, MinimumLength = 8,
            ErrorMessage = "Şifre en az 8 karakter olmalıdır.")]
        [DataType(DataType.Password)]
        [Display(Name = "Şifre")]
        public string Password { get; set; } = "";

        [Required(ErrorMessage = "Şifre tekrarı zorunludur.")]
        [DataType(DataType.Password)]
        [Compare(nameof(Password),
            ErrorMessage = "Şifreler eşleşmiyor.")]
        [Display(Name = "Şifre Tekrarı")]
        public string ConfirmPassword { get; set; } = "";
    }
}
