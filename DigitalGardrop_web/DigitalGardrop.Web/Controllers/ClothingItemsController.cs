
using System.Security.Claims;
using DigitalGardrop.Web.Data;
using DigitalGardrop.Web.Models;
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

        public ClothingItemsController(
            ApplicationDbContext context)
        {
            _context = context;
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

        // GET: /ClothingItems
        [HttpGet]
        public async Task<IActionResult> Index()
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Forbid();

            var items = await AccessibleItems(userId.Value)
                .AsNoTracking()
                .OrderBy(x => x.Id)
                .ToListAsync();

            return View(items);
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

            var item = new ClothingItem
            {
                Name = model.Name,
                CategoryId = category.Id,
                Category = category.Name,
                Color = model.Color,
                Season = model.Season,
                Style = model.Style,

                // Kiyafetin sahibini sunucu belirler.
                UserId = userId.Value
            };

            _context.ClothingItems.Add(item);

            await _context.SaveChangesAsync();

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
                Style = item.Style
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

            item.Name = model.Name;
            item.CategoryId = category.Id;
            item.Category = category.Name;
            item.Color = model.Color;
            item.Season = model.Season;
            item.Style = model.Style;

            // UserId degistirilmez.
            await _context.SaveChangesAsync();

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

            _context.ClothingItems.Remove(item);

            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] =
                $"{name} gardırobundan silindi.";

            return RedirectToAction(nameof(Index));
        }
    }
}
