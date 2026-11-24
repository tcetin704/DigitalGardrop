using System.Security.Claims;
using DigitalGardrop.Web.Data;
using DigitalGardrop.Web.Models;
using DigitalGardrop.Web.ViewModels;
using DigitalGardrop.Web.Services;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DigitalGardrop.Web.Controllers
{
    [Authorize]
    public class ProfileController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _environment;
        private readonly PasswordHasher<AppUser> _passwordHasher = new();

        public ProfileController(ApplicationDbContext context, IWebHostEnvironment environment)
        {
            _context = context;
            _environment = environment;
        }

        private int? CurrentUserId()
        {
            return int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out int id)
                ? id
                : null;
        }

        // Sadece oturumdaki kullanicinin profilini goster.
        [HttpGet]
        public async Task<IActionResult> Index()
        {
            int? userId = CurrentUserId();
            if (userId is null) return Forbid();

            var user = await _context.Users.AsNoTracking()
                .FirstOrDefaultAsync(u => u.Id == userId.Value);

            if (user is null) return await SignOutStaleUserAsync();

            int clothingCount = await _context.ClothingItems
                .CountAsync(item => item.UserId == user.Id);

            return View(new ProfileSummaryViewModel
            {
                DisplayName = user.DisplayName,
                Email = user.Email,
                Role = user.Role,
                ProfileImageUrl = user.ProfileImageUrl,
                ClothingCount = clothingCount
            });
        }

        [HttpGet]
        public async Task<IActionResult> Edit()
        {
            int? userId = CurrentUserId();
            if (userId is null) return Forbid();

            var user = await _context.Users.AsNoTracking()
                .FirstOrDefaultAsync(u => u.Id == userId.Value);

            if (user is null) return await SignOutStaleUserAsync();

            return View(new EditProfileViewModel
            {
                DisplayName = user.DisplayName,
                Email = user.Email,
                ProfileImageUrl = user.ProfileImageUrl
            });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(EditProfileViewModel model)
        {
            int? userId = CurrentUserId();
            if (userId is null) return Forbid();

            string displayName = (model.DisplayName ?? "").Trim();
            string email = (model.Email ?? "").Trim().ToLowerInvariant();
            string? imageUrl = string.IsNullOrWhiteSpace(model.ProfileImageUrl)
                ? null
                : model.ProfileImageUrl.Trim();

            if (displayName.Length < 2 || displayName.Length > 80)
                ModelState.AddModelError(nameof(model.DisplayName),
                    "Kullanıcı adı 2-80 karakter olmalıdır.");

            if (model.ProfilePhoto is null && imageUrl is not null &&
                (!Uri.TryCreate(imageUrl, UriKind.Absolute, out var parsedUrl) ||
                 parsedUrl.Scheme != Uri.UriSchemeHttps))
            {
                ModelState.AddModelError(nameof(model.ProfileImageUrl),
                    "Profil fotoğrafı için https:// ile başlayan geçerli bir bağlantı giriniz.");
            }

            if (!ModelState.IsValid) return View(model);

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId.Value);

            if (user is null) return await SignOutStaleUserAsync();

            bool emailExists = await _context.Users.AnyAsync(
                u => u.Id != user.Id && u.Email.ToLower() == email);

            if (emailExists)
            {
                ModelState.AddModelError(nameof(model.Email),
                    "Bu e-posta başka bir kullanıcı tarafından kullanılıyor.");
                return View(model);
            }

            string? previousImageUrl = user.ProfileImageUrl;
            string? newLocalImageUrl = null;

            if (model.ProfilePhoto is not null)
            {
                var uploaded = await LocalImageStorage.SaveAsync(
                    model.ProfilePhoto, _environment, "profile", user.Id, HttpContext.RequestAborted);
                if (!uploaded.IsSuccess)
                {
                    ModelState.AddModelError(nameof(model.ProfilePhoto), uploaded.Error!);
                    return View(model);
                }

                imageUrl = uploaded.Url;
                newLocalImageUrl = uploaded.Url;
            }

            user.DisplayName = displayName;
            user.Email = email;
            user.ProfileImageUrl = imageUrl;
            // Role, Id ve PasswordHash formdan alinamaz ve degistirilmez.

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                LocalImageStorage.DeleteIfOwned(newLocalImageUrl, _environment, "profile", user.Id);
                ModelState.AddModelError(nameof(model.Email),
                    "Değişiklikler kaydedilemedi. E-posta başka bir hesapta kullanılıyor olabilir.");
                return View(model);
            }

            if (previousImageUrl != imageUrl)
                LocalImageStorage.DeleteIfOwned(previousImageUrl, _environment, "profile", user.Id);

            // Kullanici adi/e-posta navbar'da hemen yenilensin.
            await RefreshAuthenticationAsync(user);
            TempData["SuccessMessage"] = "Profil bilgileriniz güncellendi.";
            return RedirectToAction(nameof(Index));
        }

        [HttpGet]
        public IActionResult ChangePassword()
        {
            return View(new ChangePasswordViewModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ChangePassword(ChangePasswordViewModel model)
        {
            int? userId = CurrentUserId();
            if (userId is null) return Forbid();
            if (!ModelState.IsValid) return View(model);

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId.Value);

            if (user is null) return await SignOutStaleUserAsync();

            if (string.IsNullOrWhiteSpace(user.PasswordHash) ||
                _passwordHasher.VerifyHashedPassword(
                    user, user.PasswordHash, model.CurrentPassword) ==
                    PasswordVerificationResult.Failed)
            {
                ModelState.AddModelError(nameof(model.CurrentPassword),
                    "Mevcut şifre hatalı.");
                return View(model);
            }

            user.PasswordHash = _passwordHasher.HashPassword(user, model.NewPassword);
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = "Şifreniz başarıyla değiştirildi.";
            return RedirectToAction(nameof(Index));
        }

        private async Task RefreshAuthenticationAsync(AppUser user)
        {
            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new(ClaimTypes.Name, user.DisplayName),
                new(ClaimTypes.Email, user.Email),
                new(ClaimTypes.Role, user.Role)
            };

            var identity = new ClaimsIdentity(
                claims, CookieAuthenticationDefaults.AuthenticationScheme);

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(identity),
                new AuthenticationProperties { IsPersistent = false });
        }

        private async Task<IActionResult> SignOutStaleUserAsync()
        {
            await HttpContext.SignOutAsync(
                CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Login", "Account");
        }
    }
}
