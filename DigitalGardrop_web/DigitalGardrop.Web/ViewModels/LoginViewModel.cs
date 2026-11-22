
using System.ComponentModel.DataAnnotations;

namespace DigitalGardrop.Web.ViewModels
{
    public class LoginViewModel
    {
        [Required(ErrorMessage = "E-posta zorunludur.")]
        [EmailAddress(ErrorMessage = "Geçerli bir e-posta giriniz.")]
        [Display(Name = "E-posta")]
        public string Email { get; set; } = "";

        [Required(ErrorMessage = "Şifre zorunludur.")]
        [DataType(DataType.Password)]
        [Display(Name = "Şifre")]
        public string Password { get; set; } = "";
    }
}
