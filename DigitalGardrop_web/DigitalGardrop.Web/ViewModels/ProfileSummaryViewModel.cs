namespace DigitalGardrop.Web.ViewModels
{
    public class ProfileSummaryViewModel
    {
        public string DisplayName { get; set; } = "";
        public string Email { get; set; } = "";
        public string Role { get; set; } = "User";
        public string? ProfileImageUrl { get; set; }
        public int ClothingCount { get; set; }
    }
}
