
using System.Security.Claims;
using DigitalGardrop.Web.Data;
using DigitalGardrop.Web.Models;
using DigitalGardrop.Web.ViewModels;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DigitalGardrop.Web.Controllers
{
    [ApiController]
    [Route("api/clothingitems")]
    [Authorize]
    public class ClothingItemsApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IAntiforgery _antiforgery;

        public ClothingItemsApiController(
            ApplicationDbContext context,
            IAntiforgery antiforgery)
        {
            _context = context;
            _antiforgery = antiforgery;
        }

        private int? GetCurrentUserId()
        {
            string? value = User.FindFirst(
                ClaimTypes.NameIdentifier
            )?.Value;

            return int.TryParse(value, out int userId)
                ? userId
                : null;
        }

        // Normal kullanici kendi kiyafetlerini,
        // Admin ise tum kiyafetleri yonetebilir.
        private IQueryable<ClothingItem> AccessibleItems(
            int userId)
        {
            var query = _context.ClothingItems.AsQueryable();

            if (!User.IsInRole("Admin"))
            {
                query = query.Where(
                    item => item.UserId == userId
                );
            }

            return query;
        }

        // GET: /api/clothingitems/antiforgery-token
        [HttpGet("antiforgery-token")]
        public IActionResult GetAntiforgeryToken()
        {
            var tokens = _antiforgery.GetAndStoreTokens(
                HttpContext
            );

            Response.Headers["Cache-Control"] = "no-store";

            return Ok(new
            {
                requestToken = tokens.RequestToken
            });
        }

        // GET: /api/clothingitems
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Unauthorized();

            var items = await AccessibleItems(userId.Value)
                .AsNoTracking()
                .OrderBy(item => item.Id)
                .Select(item => new
                {
                    item.Id,
                    item.Name,
                    item.Category,
                    item.CategoryId,
                    item.Color,
                    item.Season,
                    item.Style,
                    item.ImageUrl,
                    item.UserId
                })
                .ToListAsync();

            return Ok(items);
        }

        // GET: /api/clothingitems/5
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Unauthorized();

            var item = await AccessibleItems(userId.Value)
                .AsNoTracking()
                .Where(item => item.Id == id)
                .Select(item => new
                {
                    item.Id,
                    item.Name,
                    item.Category,
                    item.CategoryId,
                    item.Color,
                    item.Season,
                    item.Style,
                    item.ImageUrl,
                    item.UserId
                })
                .FirstOrDefaultAsync();

            if (item == null)
                return NotFound();

            return Ok(item);
        }

        // POST: /api/clothingitems
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(
            [FromBody] ClothingItemApiRequest model)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Unauthorized();

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

                return ValidationProblem(ModelState);
            }

            var item = new ClothingItem
            {
                Name = model.Name.Trim(),
                CategoryId = category.Id,
                Category = category.Name,
                Color = model.Color.Trim(),
                Season = model.Season.Trim(),
                Style = model.Style.Trim(),
                ImageUrl = model.ImageUrl,
                UserId = userId.Value
            };

            _context.ClothingItems.Add(item);
            await _context.SaveChangesAsync();

            return CreatedAtAction(
                nameof(GetById),
                new { id = item.Id },
                new
                {
                    item.Id,
                    item.Name,
                    item.Category,
                    item.CategoryId,
                    item.Color,
                    item.Season,
                    item.Style,
                    item.ImageUrl,
                    item.UserId
                }
            );
        }

        // PUT: /api/clothingitems/5
        [HttpPut("{id:int}")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Update(
            int id,
            [FromBody] ClothingItemApiRequest model)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Unauthorized();

            var item = await AccessibleItems(userId.Value)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (item == null)
                return NotFound();

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

                return ValidationProblem(ModelState);
            }

            item.Name = model.Name.Trim();
            item.CategoryId = category.Id;
            item.Category = category.Name;
            item.Color = model.Color.Trim();
            item.Season = model.Season.Trim();
            item.Style = model.Style.Trim();
            item.ImageUrl = model.ImageUrl;

            // Kiyafetin sahibi degistirilmez.
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: /api/clothingitems/5
        [HttpDelete("{id:int}")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            int? userId = GetCurrentUserId();

            if (!userId.HasValue)
                return Unauthorized();

            // Yalnizca yetkili olunan kiyafet silinebilir.
            var item = await AccessibleItems(userId.Value)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (item == null)
                return NotFound();

            _context.ClothingItems.Remove(item);

            await _context.SaveChangesAsync();

            // Basarili silme: HTTP 204
            return NoContent();
        }
    }
}
