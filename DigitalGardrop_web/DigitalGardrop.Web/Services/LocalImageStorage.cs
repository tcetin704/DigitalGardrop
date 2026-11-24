using System.Globalization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Hosting;

namespace DigitalGardrop.Web.Services
{
    // Gelistirme ortaminda fotolari wwwroot/uploads altinda tutar.
    // Dosya adi kullanicidan alinmaz; GUID ile uretilir.
    public static class LocalImageStorage
    {
        public const long MaxFileSizeBytes = 5 * 1024 * 1024;

        private static readonly HashSet<string> AllowedExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg", ".jpeg", ".png", ".webp"
        };

        public sealed record SaveResult(string? Url, string? Error)
        {
            public bool IsSuccess => Error is null;
        }

        public static async Task<SaveResult> SaveAsync(
            IFormFile photo, IWebHostEnvironment environment,
            string category, int ownerId, CancellationToken cancellationToken = default)
        {
            if (category is not ("clothing" or "profile") || ownerId <= 0)
                throw new ArgumentException("Gecersiz gorsel klasoru/kullanici.");

            if (photo.Length <= 0 || photo.Length > MaxFileSizeBytes)
                return new(null, "Fotoğraf 5 MB'den küçük ve boş olmayan bir dosya olmalıdır.");

            string extension = Path.GetExtension(photo.FileName).ToLowerInvariant();
            if (!AllowedExtensions.Contains(extension))
                return new(null, "Yalnızca JPG, PNG ve WEBP fotoğrafları yükleyebilirsiniz.");

            byte[] contents;
            try
            {
                await using var memory = new MemoryStream((int)photo.Length);
                await photo.CopyToAsync(memory, cancellationToken);
                contents = memory.ToArray();
            }
            catch (IOException)
            {
                return new(null, "Fotoğraf okunamadı. Lütfen tekrar deneyiniz.");
            }

            if (contents.Length == 0 || contents.Length > MaxFileSizeBytes ||
                !HasExpectedSignature(contents, extension))
            {
                return new(null, "Dosya içeriği seçilen görsel formatıyla uyuşmuyor.");
            }

            string ownerFolder = ownerId.ToString(CultureInfo.InvariantCulture);
            string name = $"{Guid.NewGuid():N}{extension}";
            string webRoot = environment.WebRootPath ?? Path.Combine(environment.ContentRootPath, "wwwroot");
            string folder = Path.Combine(webRoot, "uploads", category, ownerFolder);
            string fullPath = Path.Combine(folder, name);

            try
            {
                Directory.CreateDirectory(folder);
                await using var target = new FileStream(fullPath, FileMode.CreateNew, FileAccess.Write, FileShare.None);
                await target.WriteAsync(contents, cancellationToken);
            }
            catch (IOException)
            {
                TryDeleteFile(fullPath);
                return new(null, "Fotoğraf diske kaydedilemedi. Lütfen tekrar deneyiniz.");
            }
            catch (UnauthorizedAccessException)
            {
                TryDeleteFile(fullPath);
                return new(null, "Fotoğraf klasörüne yazma izni bulunamadı.");
            }

            return new($"/uploads/{category}/{ownerFolder}/{name}", null);
        }

        // Sadece uygulamanin olusturdugu ve verilen kullaniciya ait dosyalari siler.
        public static void DeleteIfOwned(string? url, IWebHostEnvironment environment,
            string category, int ownerId)
        {
            if (category is not ("clothing" or "profile") || ownerId <= 0 || string.IsNullOrEmpty(url))
                return;

            string prefix = $"/uploads/{category}/{ownerId.ToString(CultureInfo.InvariantCulture)}/";
            if (!url.StartsWith(prefix, StringComparison.Ordinal))
                return;

            string fileName = url[prefix.Length..];
            if (fileName.Length is < 36 or > 37 || // GUID (32) + .png/.jpg (4) veya .jpeg/.webp (5)
                fileName.Contains('/') || fileName.Contains('\\'))
                return;

            string extension = Path.GetExtension(fileName).ToLowerInvariant();
            string basename = Path.GetFileNameWithoutExtension(fileName);
            if (!AllowedExtensions.Contains(extension) || basename.Length != 32 ||
                !basename.All(c => char.IsAsciiHexDigit(c)))
                return;

            string webRoot = environment.WebRootPath ?? Path.Combine(environment.ContentRootPath, "wwwroot");
            string fullPath = Path.Combine(webRoot, "uploads", category,
                ownerId.ToString(CultureInfo.InvariantCulture), fileName);
            TryDeleteFile(fullPath);
        }

        private static bool HasExpectedSignature(byte[] bytes, string extension)
        {
            if (extension is ".jpg" or ".jpeg")
                return bytes.Length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
            if (extension == ".png")
                return bytes.Length >= 8 && bytes.AsSpan(0, 8).SequenceEqual(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 });
            return bytes.Length >= 12 &&
                bytes.AsSpan(0, 4).SequenceEqual("RIFF"u8) &&
                bytes.AsSpan(8, 4).SequenceEqual("WEBP"u8);
        }

        private static void TryDeleteFile(string path)
        {
            try { if (File.Exists(path)) File.Delete(path); }
            catch (IOException) { /* Silme basarisizsa uygulamayi durdurma. */ }
            catch (UnauthorizedAccessException) { /* Loglama ileride eklenecek. */ }
        }
    }
}
