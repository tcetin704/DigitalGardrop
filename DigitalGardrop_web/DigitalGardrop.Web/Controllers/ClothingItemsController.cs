
using DigitalGardrop.Web.Data;
using DigitalGardrop.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;

namespace DigitalGardrop.Web.Controllers
{
    public class ClothingItemsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public ClothingItemsController(ApplicationDbContext context)
        {
            _context = context;
        }

        private async Task FillCategoriesAsync(
            ClothingItemFormViewModel model)
        {
            var categories = await _context.Categories
                .AsNoTracking()
                .OrderBy(c => c.Name)
                .ToListAsync();

            model.Categories = new SelectList(
                categories, "Id", "Name", model.CategoryId);
        }

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var items = await _context.ClothingItems
                .AsNoTracking()
                .OrderBy(x => x.Id)
                .ToListAsync();

            return View(items);
        }

        [HttpGet]
        public async Task<IActionResult> Create()
        {
            var model = new ClothingItemFormViewModel();

            await FillCategoriesAsync(model);

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(
            ClothingItemFormViewModel model)
        {
            if (!ModelState.IsValid)
            {
                await FillCategoriesAsync(model);
                return View(model);
            }

            var category = await _context.Categories
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    c => c.Id == model.CategoryId);

            if (category == null)
            {
                ModelState.AddModelError(
                    nameof(model.CategoryId),
                    "Geçerli bir kategori seçiniz.");

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
                Style = model.Style
            };

            _context.ClothingItems.Add(item);
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] =
                $"{item.Name} gardırobuna başarıyla eklendi.";

            return RedirectToAction(nameof(Index));
        }

        [HttpGet]
        public async Task<IActionResult> Details(int id)
        {
            var item = await _context.ClothingItems
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id);

            if (item == null)
                return NotFound();

            return View(item);
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var item = await _context.ClothingItems
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

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(
            int id, ClothingItemFormViewModel model)
        {
            var item = await _context.ClothingItems
                .FindAsync(id);

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
                    c => c.Id == model.CategoryId);

            if (category == null)
            {
                ModelState.AddModelError(
                    nameof(model.CategoryId),
                    "Geçerli bir kategori seçiniz.");

                await FillCategoriesAsync(model);
                return View(model);
            }

            item.Name = model.Name;
            item.CategoryId = category.Id;
            item.Category = category.Name;
            item.Color = model.Color;
            item.Season = model.Season;
            item.Style = model.Style;

            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] =
                $"{item.Name} başarıyla güncellendi.";

            return RedirectToAction(nameof(Index));
        }

        [HttpGet]
        public async Task<IActionResult> Delete(int id)
        {
            var item = await _context.ClothingItems
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id);

            if (item == null)
                return NotFound();

            return View(item);
        }

        [HttpPost]
        [ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var item = await _context.ClothingItems
                .FindAsync(id);

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
