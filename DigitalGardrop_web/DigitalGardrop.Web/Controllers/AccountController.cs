
using System.Security.Claims;
using DigitalGardrop.Web.Data;
using DigitalGardrop.Web.Models;
using DigitalGardrop.Web.ViewModels;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DigitalGardrop.Web.Controllers
{
    public class AccountController : Controller
    {
        private readonly ApplicationDbContext _context;

        private readonly PasswordHasher<AppUser> _passwordHasher =
            new PasswordHasher<AppUser>();

        public AccountController(ApplicationDbContext context)
        {
            _context = context;
        }

        // KAYIT SAYFASI
        [HttpGet]
        [AllowAnonymous]
        public IActionResult Register()
        {
            return View();
        }

        // KULLANICI KAYDI
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Register(
            RegisterViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            string email = model.Email.Trim().ToLowerInvariant();

            bool emailExists = await _context.Users
                .AnyAsync(u => u.Email.ToLower() == email);

            if (emailExists)
            {
                ModelState.AddModelError(
                    nameof(model.Email),
                    "Bu e-posta adresi zaten kayıtlı."
                );

                return View(model);
            }

            var user = new AppUser
            {
                DisplayName = model.DisplayName.Trim(),
                Email = email,
                Role = "User"
            };

            user.PasswordHash = _passwordHasher.HashPassword(
                user,
                model.Password
            );

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] =
                "Kayıt başarılı! Artık giriş yapabilirsiniz.";

            return RedirectToAction(nameof(Login));
        }

        // GIRIS SAYFASI
        [HttpGet]
        [AllowAnonymous]
        public IActionResult Login()
        {
            return View();
        }

        // KULLANICI GIRISI
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(
            LoginViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            string email = model.Email.Trim().ToLowerInvariant();

            var user = await _context.Users
                .FirstOrDefaultAsync(
                    u => u.Email.ToLower() == email
                );

            if (user == null ||
                string.IsNullOrWhiteSpace(user.PasswordHash))
            {
                ModelState.AddModelError(
                    "",
                    "E-posta veya şifre hatalı."
                );

                return View(model);
            }

            // Veritabanindaki hash ile sifreyi dogrula.
            var result = _passwordHasher.VerifyHashedPassword(
                user,
                user.PasswordHash,
                model.Password
            );

            if (result == PasswordVerificationResult.Failed)
            {
                ModelState.AddModelError(
                    "",
                    "E-posta veya şifre hatalı."
                );

                return View(model);
            }

            // Gerekirse eski hash formatini guncelle.
            if (result ==
                PasswordVerificationResult.SuccessRehashNeeded)
            {
                user.PasswordHash = _passwordHasher.HashPassword(
                    user,
                    model.Password
                );

                await _context.SaveChangesAsync();
            }

            // Kullanici kimlik ve rol bilgileri.
            var claims = new List<Claim>
            {
                new Claim(
                    ClaimTypes.NameIdentifier,
                    user.Id.ToString()
                ),
                new Claim(
                    ClaimTypes.Name,
                    user.DisplayName
                ),
                new Claim(
                    ClaimTypes.Email,
                    user.Email
                ),
                new Claim(
                    ClaimTypes.Role,
                    user.Role
                )
            };

            var identity = new ClaimsIdentity(
                claims,
                CookieAuthenticationDefaults.AuthenticationScheme
            );

            var principal = new ClaimsPrincipal(identity);

            // Guvenli oturum cookie'si olustur.
            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                principal,
                new AuthenticationProperties
                {
                    IsPersistent = false
                }
            );

            TempData["SuccessMessage"] =
                "Başarıyla giriş yaptınız.";

            return RedirectToAction("Index", "Home");
        }

        // OTURUMU KAPAT
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(
                CookieAuthenticationDefaults.AuthenticationScheme
            );

            return RedirectToAction(nameof(Login));
        }
    }
}
