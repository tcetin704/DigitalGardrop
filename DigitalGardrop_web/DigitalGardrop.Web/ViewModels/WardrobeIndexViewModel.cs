using DigitalGardrop.Web.Models;

namespace DigitalGardrop.Web.ViewModels
{
    // Gardirobum sayfasinin liste + filtre seceneklerini birlikte tasir.
    public class WardrobeIndexViewModel
    {
        public List<ClothingItem> Items { get; set; } = new();
        public List<string> Categories { get; set; } = new();
        public List<string> Seasons { get; set; } = new();
        public List<string> Colors { get; set; } = new();

        public int TotalCount { get; set; }
        public string Search { get; set; } = "";
        public string Category { get; set; } = "";
        public string Season { get; set; } = "";
        public string Color { get; set; } = "";
        public string Sort { get; set; } = "newest";

        public bool HasActiveFilters =>
            !string.IsNullOrWhiteSpace(Search) ||
            !string.IsNullOrWhiteSpace(Category) ||
            !string.IsNullOrWhiteSpace(Season) ||
            !string.IsNullOrWhiteSpace(Color);
    }
}
