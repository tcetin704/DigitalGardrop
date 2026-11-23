
using System.Security.Claims;
using DigitalGardrop.Web.Data;
using DigitalGardrop.Web.Models;
using DigitalGardrop.Web.Services;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;

namespace DigitalGardrop.Web.Controllers
{
    // Gardiroba yalnizca giris yapmis kisiler erisebilir.
    [Authorize]
    public class ClothingItemsController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _environment;

        public ClothingItemsController(ApplicationDbContext context,
            IWebHostEnvironment environment)
        {
            _context = context;
            _environment = environment;
        }

        // Giris yapan kullanicinin Id bilgisini al.
        private int? GetCurrentUserId()
        {
            string? value = User.FindFirst(
                ClaimTypes.NameIdentifier
            )?.Value;

            return int.TryParse(value, out int userId)
                ? userId
                : null;
        }

        // Normal kullanici sadece kendi kiyafetlerine erisir.
        // Admin tum kiyafetleri gorebilir.
        private IQueryable<ClothingItem> AccessibleItems(
            int userId)
        {
            IQueryable<ClothingItem> query =
                _context.ClothingItems;

            if (!User.IsInRole("Admin"))
            {
                query = query.Where(
                    item => item.UserId == userId
                );
            }

            return query;
        }

        // Kategori secim listesini doldur.
        private async Task FillCategoriesAsync(
            ClothingItemFormViewModel model)
        {
            var categories = await _context.Categories
                .AsNoTracking()
                .OrderBy(c => c.Name)
                .ToListAsync();

            model.Categories = new SelectList(
                categories,
                "Id",
                "Name",
                model.CategoryId
            );
        }

        // GET: /ClothingItems?search=...&category=...&season=...&color=...&sort=...
        [HttpGet]
        public async Task<IActionResult> Index(
            [FromQuery] string? search,
            [FromQuery] string? category,
            [FromQuery] string? season,
            [FromQuery] string? color,
            [FromQuery] string? sort)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Forbid();

            // Filtre secenekleri yalnizca kullanicinin gorme yetkisi olan veriden gelir.
            var accessible = AccessibleItems(userId.Value).AsNoTracking();
            var facets = await accessible
                .Select(x => new { x.Category, x.Season, x.Color })
                .ToListAsync();

            var query = accessible;
            string cleanSearch = (search ?? "").Trim();
            if (cleanSearch.Length > 80) cleanSearch = cleanSearch[..80];
            string cleanCategory = (category ?? "").Trim();
            string cleanSeason = (season ?? "").Trim();
            string cleanColor = (color ?? "").Trim();
            string cleanSort = sort switch
            {
                "oldest" => "oldest",
                "name" => "name",
                "category" => "category",
                _ => "newest"
            };

            if (!string.IsNullOrWhiteSpace(cleanSearch))
            {
                var keyword = cleanSearch.ToLowerInvariant();
                query = query.Where(x =>
                    x.Name.ToLower().Contains(keyword) ||
                    x.Category.ToLower().Contains(keyword) ||
                    x.Color.ToLower().Contains(keyword) ||
                    x.Season.ToLower().Contains(keyword) ||
                    x.Style.ToLower().Contains(keyword));
            }
            if (!string.IsNullOrWhiteSpace(cleanCategory))
                query = query.Where(x => x.Category == cleanCategory);
            if (!string.IsNullOrWhiteSpace(cleanSeason))
                query = query.Where(x => x.Season == cleanSeason);
            if (!string.IsNullOrWhiteSpace(cleanColor))
                query = query.Where(x => x.Color == cleanColor);

            query = cleanSort switch
            {
                "oldest" => query.OrderBy(x => x.Id),
                "name" => query.OrderBy(x => x.Name).ThenBy(x => x.Id),
                "category" => query.OrderBy(x => x.Category).ThenBy(x => x.Name),
                _ => query.OrderByDescending(x => x.Id)
            };

            var model = new DigitalGardrop.Web.ViewModels.WardrobeIndexViewModel
            {
                Items = await query.ToListAsync(),
                TotalCount = facets.Count,
                Search = cleanSearch,
                Category = cleanCategory,
                Season = cleanSeason,
                Color = cleanColor,
                Sort = cleanSort,
                Categories = facets.Select(x => x.Category).Where(x => !string.IsNullOrWhiteSpace(x))
                    .Distinct(StringComparer.OrdinalIgnoreCase).OrderBy(x => x).ToList(),
                Seasons = facets.Select(x => x.Season).Where(x => !string.IsNullOrWhiteSpace(x))
                    .Distinct(StringComparer.OrdinalIgnoreCase).OrderBy(x => x).ToList(),
                Colors = facets.Select(x => x.Color).Where(x => !string.IsNullOrWhiteSpace(x))
                    .Distinct(StringComparer.OrdinalIgnoreCase).OrderBy(x => x).ToList()
            };

            return View(model);
        }

        // GET: /ClothingItems/Create
        [HttpGet]
        public async Task<IActionResult> Create()
        {
            if (!GetCurrentUserId().HasValue)
                return Forbid();

            var model = new ClothingItemFormViewModel();

            await FillCategoriesAsync(model);

            return View(model);
        }

        // POST: /ClothingItems/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(
            ClothingItemFormViewModel model)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Forbid();

            if (!ModelState.IsValid)
            {
                await FillCategoriesAsync(model);
                return View(model);
            }

            var category = await _context.Categories
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    c => c.Id == model.CategoryId
                );

            if (category == null)
            {
                ModelState.AddModelError(
                    nameof(model.CategoryId),
                    "Geçerli bir kategori seçiniz."
                );

                await FillCategoriesAsync(model);

                return View(model);
            }

            string? newImageUrl = null;
            if (model.ImageFile is not null)
            {
                var uploaded = await LocalImageStorage.SaveAsync(
                    model.ImageFile, _environment, "clothing", userId.Value,
                    HttpContext.RequestAborted);
                if (!uploaded.IsSuccess)
                {
                    ModelState.AddModelError(nameof(model.ImageFile), uploaded.Error!);
                    await FillCategoriesAsync(model);
                    return View(model);
                }
                newImageUrl = uploaded.Url;
            }

            var item = new ClothingItem
            {
                Name = model.Name,
                CategoryId = category.Id,
                Category = category.Name,
                Color = model.Color,
                Season = model.Season,
                Style = model.Style,

                ImageUrl = newImageUrl,

                // Kiyafetin sahibini sunucu belirler.
                UserId = userId.Value
            };

            _context.ClothingItems.Add(item);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch
            {
                LocalImageStorage.DeleteIfOwned(newImageUrl, _environment, "clothing", userId.Value);
                throw;
            }

            TempData["SuccessMessage"] =
                $"{item.Name} gardırobuna başarıyla eklendi.";

            return RedirectToAction(nameof(Index));
        }

        // GET: /ClothingItems/Details/5
        [HttpGet]
        public async Task<IActionResult> Details(int id)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Forbid();

            var item = await AccessibleItems(userId.Value)
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id);

            if (item == null)
                return NotFound();

            return View(item);
        }

        // GET: /ClothingItems/Edit/5
        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Forbid();

            var item = await AccessibleItems(userId.Value)
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id);

            if (item == null)
                return NotFound();

            int? categoryId = item.CategoryId;

            if (categoryId == null)
            {
                categoryId = await _context.Categories
                    .Where(c => c.Name == item.Category)
                    .Select(c => (int?)c.Id)
                    .FirstOrDefaultAsync();
            }

            var model = new ClothingItemFormViewModel
            {
                Id = item.Id,
                Name = item.Name,
                CategoryId = categoryId,
                Color = item.Color,
                Season = item.Season,
                Style = item.Style,
                ExistingImageUrl = item.ImageUrl
            };

            await FillCategoriesAsync(model);

            return View(model);
        }

        // POST: /ClothingItems/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(
            int id,
            ClothingItemFormViewModel model)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Forbid();

            // Sadece erisim yetkisi olan kiyafeti bul.
            var item = await AccessibleItems(userId.Value)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (item == null)
                return NotFound();

            model.Id = id;
            model.ExistingImageUrl = item.ImageUrl;

            if (!ModelState.IsValid)
            {
                await FillCategoriesAsync(model);
                return View(model);
            }

            var category = await _context.Categories
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    c => c.Id == model.CategoryId
                );

            if (category == null)
            {
                ModelState.AddModelError(
                    nameof(model.CategoryId),
                    "Geçerli bir kategori seçiniz."
                );

                await FillCategoriesAsync(model);

                return View(model);
            }

            string? previousImageUrl = item.ImageUrl;
            string? newLocalImageUrl = null;
            int imageOwnerId = item.UserId ?? userId.Value;

            if (model.ImageFile is not null)
            {
                var uploaded = await LocalImageStorage.SaveAsync(
                    model.ImageFile, _environment, "clothing", imageOwnerId,
                    HttpContext.RequestAborted);
                if (!uploaded.IsSuccess)
                {
                    ModelState.AddModelError(nameof(model.ImageFile), uploaded.Error!);
                    await FillCategoriesAsync(model);
                    return View(model);
                }
                newLocalImageUrl = uploaded.Url;
                item.ImageUrl = uploaded.Url;
            }
            else if (model.RemoveImage)
            {
                item.ImageUrl = null;
            }

            item.Name = model.Name;
            item.CategoryId = category.Id;
            item.Category = category.Name;
            item.Color = model.Color;
            item.Season = model.Season;
            item.Style = model.Style;

            // UserId degistirilmez.
            try
            {
                await _context.SaveChangesAsync();
            }
            catch
            {
                LocalImageStorage.DeleteIfOwned(newLocalImageUrl, _environment, "clothing", imageOwnerId);
                throw;
            }

            if (previousImageUrl != item.ImageUrl)
                LocalImageStorage.DeleteIfOwned(previousImageUrl, _environment, "clothing", imageOwnerId);

            TempData["SuccessMessage"] =
                $"{item.Name} başarıyla güncellendi.";

            return RedirectToAction(nameof(Index));
        }

        // GET: /ClothingItems/Delete/5
        [HttpGet]
        public async Task<IActionResult> Delete(int id)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Forbid();

            var item = await AccessibleItems(userId.Value)
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id);

            if (item == null)
                return NotFound();

            return View(item);
        }

        // POST: /ClothingItems/Delete/5
        [HttpPost]
        [ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(
            int id)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Forbid();

            var item = await AccessibleItems(userId.Value)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (item == null)
                return NotFound();

            string name = item.Name;
            string? imageUrl = item.ImageUrl;
            int imageOwnerId = item.UserId ?? userId.Value;

            _context.ClothingItems.Remove(item);
            await _context.SaveChangesAsync();
            LocalImageStorage.DeleteIfOwned(imageUrl, _environment, "clothing", imageOwnerId);

            TempData["SuccessMessage"] =
                $"{name} gardırobundan silindi.";

            return RedirectToAction(nameof(Index));
        }
    }
}
