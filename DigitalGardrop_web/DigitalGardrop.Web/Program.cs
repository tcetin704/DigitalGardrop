
using DigitalGardrop.Web.Data;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// MVC VE API
builder.Services.AddControllersWithViews();

// SWAGGER
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// COOKIE AUTHENTICATION
builder.Services
    .AddAuthentication(
        CookieAuthenticationDefaults.AuthenticationScheme
    )
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.AccessDeniedPath = "/Account/AccessDenied";

        options.Cookie.Name = "DigitalGardrop.Auth";
        options.Cookie.HttpOnly = true;
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.Cookie.SecurePolicy =
            CookieSecurePolicy.SameAsRequest;

        options.ExpireTimeSpan = TimeSpan.FromMinutes(60);
        options.SlidingExpiration = true;
    });

// YETKILENDIRME
builder.Services.AddAuthorization();

// VERITABANI SECIMI
// Mac: SQLite
// Windows: SQL Server
var databaseProvider =
    builder.Configuration["Database:Provider"] ?? "SqlServer";

bool useSqlite = databaseProvider.Equals(
    "Sqlite",
    StringComparison.OrdinalIgnoreCase
);

if (useSqlite)
{
    var databasePath = Path.Combine(
        builder.Environment.ContentRootPath,
        "digitalgardrop_mac.db"
    );

    builder.Services.AddDbContext<ApplicationDbContext>(
        options => options.UseSqlite(
            $"Data Source={databasePath}"
        )
    );
}
else
{
    var connectionString =
        builder.Configuration.GetConnectionString(
            "DefaultConnection"
        )
        ?? throw new InvalidOperationException(
            "DefaultConnection bağlantı dizesi bulunamadı."
        );

    builder.Services.AddDbContext<ApplicationDbContext>(
        options => options.UseSqlServer(connectionString)
    );
}

var app = builder.Build();

// YEREL SQLITE VERITABANINI OLUSTUR
if (useSqlite && app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();

    var db = scope.ServiceProvider
        .GetRequiredService<ApplicationDbContext>();

    db.Database.EnsureCreated();
}

// HATA YONETIMI
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

// SWAGGER YALNIZCA GELISTIRME ORTAMINDA
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Calisma zamaninda yuklenen /uploads fotograflarini da sun.
app.UseStaticFiles();

app.UseRouting();

// KIMLIK DOGRULAMA VE YETKILENDIRME
app.UseAuthentication();
app.UseAuthorization();

app.MapStaticAssets();

// API ROUTING
app.MapControllers();

// MVC ROUTING
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}"
)
.WithStaticAssets();

app.Run();
