
using Microsoft.AspNetCore.Mvc;
using DigitalGardrop.Web.Models;

namespace DigitalGardrop.Web.Controllers
{
    public class ClothingItemsController : Controller
    {
        private static int sonId = 3;

        private static readonly List<ClothingItem> kiyafetler = new()
        {
            new ClothingItem
            {
                Id = 1,
                Name = "Siyah Basic Tişört",
                Category = "Üst Giyim",
                Color = "Siyah",
                Season = "Yaz",
                Style = "Günlük"
            },
            new ClothingItem
            {
                Id = 2,
                Name = "Mavi Kot Pantolon",
                Category = "Alt Giyim",
                Color = "Mavi",
                Season = "Dört Mevsim",
                Style = "Günlük"
            },
            new ClothingItem
            {
                Id = 3,
                Name = "Beyaz Spor Ayakkabı",
                Category = "Ayakkabı",
                Color = "Beyaz",
                Season = "Dört Mevsim",
                Style = "Spor"
            }
        };

        public IActionResult Index()
        {
            return View(kiyafetler);
        }

        [HttpGet]
        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(
            [Bind("Name,Category,Color,Season,Style")]
            ClothingItem yeniKiyafet)
        {
            sonId++;

            yeniKiyafet.Id = sonId;

            kiyafetler.Add(yeniKiyafet);

            return RedirectToAction("Index");
        }
    }
}
