using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;

namespace DigitalGardrop.Web.ViewModels
{
    public class EditProfileViewModel
    {
        [Required(ErrorMessage = "Kullanıcı adı zorunludur.")]
        [StringLength(80, MinimumLength = 2,
            ErrorMessage = "Kullanıcı adı 2-80 karakter olmalıdır.")]
        [Display(Name = "Kullanıcı Adı")]
        public string DisplayName { get; set; } = "";

        [Required(ErrorMessage = "E-posta zorunludur.")]
        [EmailAddress(ErrorMessage = "Geçerli bir e-posta adresi giriniz.")]
        [StringLength(254)]
        [Display(Name = "E-posta")]
        public string Email { get; set; } = "";

        [StringLength(2048, ErrorMessage = "Görsel adresi çok uzun.")]
        [Display(Name = "Profil Fotoğrafı URL (isteğe bağlı)")]
        public string? ProfileImageUrl { get; set; }

        [Display(Name = "Mac'ten Profil Fotoğrafı Seç")]
        [ValidateNever]
        public IFormFile? ProfilePhoto { get; set; }
    }
}
