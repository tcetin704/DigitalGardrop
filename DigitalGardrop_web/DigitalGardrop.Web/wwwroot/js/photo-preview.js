// Mac'ten secilen fotografi yuklemeden once kullaniciya gosterir.
document.querySelectorAll('[data-photo-preview]').forEach((input) => {
    const img = document.getElementById(input.dataset.photoPreview);
    if (!img) return;

    let previousObjectUrl = null;
    input.addEventListener('change', () => {
        if (previousObjectUrl) {
            URL.revokeObjectURL(previousObjectUrl);
            previousObjectUrl = null;
        }
        const file = input.files?.[0];
        if (!file) return;
        if (!file.type.startsWith('image/')) return;
        previousObjectUrl = URL.createObjectURL(file);
        img.src = previousObjectUrl;
        img.classList.remove('d-none');
    });
});
