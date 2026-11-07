using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using DigitalGardrop.Web.Models;

namespace DigitalGardrop.Web.Controllers;

public class HomeController : Controller
{
    public IActionResult Index()
{
    ViewBag.ProjeAdi = "Dijital Gardırop";

    ViewBag.Aciklama = "Kıyafetlerini dijital ortamda yönet, kombinler oluştur ve tarzını paylaş.";

    ViewBag.Kategoriler = new List<string>
    {
        "Üst Giyim",
        "Alt Giyim",
        "Ayakkabı",
        "Dış Giyim",
        "Aksesuar"
    };

    return View();
}

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
