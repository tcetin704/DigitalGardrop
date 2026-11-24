using System.ComponentModel.DataAnnotations;

namespace DigitalGardrop.Web.ViewModels
{
    public class ChangePasswordViewModel
    {
        [Required(ErrorMessage = "Mevcut şifrenizi giriniz.")]
        [DataType(DataType.Password)]
        [Display(Name = "Mevcut Şifre")]
        public string CurrentPassword { get; set; } = "";

        [Required(ErrorMessage = "Yeni şifre zorunludur.")]
        [StringLength(128, MinimumLength = 8,
            ErrorMessage = "Yeni şifre 8-128 karakter olmalıdır.")]
        [DataType(DataType.Password)]
        [Display(Name = "Yeni Şifre")]
        public string NewPassword { get; set; } = "";

        [Required(ErrorMessage = "Yeni şifre tekrarını giriniz.")]
        [DataType(DataType.Password)]
        [Compare(nameof(NewPassword), ErrorMessage = "Yeni şifreler eşleşmiyor.")]
        [Display(Name = "Yeni Şifre Tekrarı")]
        public string ConfirmNewPassword { get; set; } = "";
    }
}
