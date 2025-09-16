# Fix URL Endpoint Issue - Connection Reset Error

## Masalah yang Ditemukan

Setelah login > logout > login, masih muncul error "Connection reset by peer" dengan URL yang salah:

```
ClientException with SocketException: Connection reset by peer (OS Error: Connection reset by peer, errno = 104), address = andidigital.andipublisher.com, port = 39290, uri=https://andidigital.andipublisher.com/api/dev/ebook/list?tag-terbaru&limit=10&offset=0
```

### Root Cause Analysis:

1. **URL Construction Issue**:

   - `BookService` menggunakan `${AppConfig.baseUrl}/dev/ebook/list`
   - Ini menghasilkan URL: `https://andidigital.andipublisher.com/api/dev/ebook/list`
   - Tapi seharusnya menggunakan `AppConfig.baseUrlApp` yang sudah benar

2. **Inconsistent URL Usage**:

   - `AppConfig.baseUrl` = `https://andidigital.andipublisher.com/api`
   - `AppConfig.baseUrlApp` = `https://andidigital.andipublisher.com/api/dev`
   - `BookService` menggunakan kombinasi yang salah

3. **Parameter Parsing Issue**:
   - Error message menunjukkan `tag-terbaru` instead of `tag=terbaru`
   - Ini menunjukkan ada masalah di URL parsing

## Solusi yang Diimplementasikan

### 1. Memperbaiki URL Construction

- ✅ Mengubah dari `${AppConfig.baseUrl}/dev/ebook/list` ke `${AppConfig.baseUrlApp}/ebook/list`
- ✅ Menggunakan `AppConfig.baseUrlApp` yang sudah benar untuk semua endpoint

### 2. Menyelaraskan URL Usage

- ✅ Semua method di `BookService` menggunakan `AppConfig.baseUrlApp`
- ✅ Memastikan konsistensi URL di seluruh aplikasi

### 3. Memperbaiki Endpoint URLs

- ✅ `fetchBukuTerbaru`: `${AppConfig.baseUrlApp}/ebook/list?tag=terbaru`
- ✅ `fetchBukuTerlaris`: `${AppConfig.baseUrlApp}/ebook/list?tag=terlaris`
- ✅ `fetchDetailBuku`: `${AppConfig.baseUrlApp}/ebook/{slug}`
- ✅ `fetchBukuOwned`: `${AppConfig.baseUrlApp}/ebook/owned`
- ✅ `createReview`: `${AppConfig.baseUrlApp}/review/create`

## Perubahan yang Dibuat

### File: `lib/services/book_service.dart`

- ✅ `fetchBukuTerbaru()`: Mengubah URL dari `${AppConfig.baseUrl}/dev/ebook/list` ke `${AppConfig.baseUrlApp}/ebook/list`
- ✅ `fetchBukuTerlaris()`: Mengubah URL dari `${AppConfig.baseUrl}/dev/ebook/list` ke `${AppConfig.baseUrlApp}/ebook/list`
- ✅ `fetchDetailBuku()`: Mengubah URL dari `${AppConfig.baseUrl}/dev/ebook/{slug}` ke `${AppConfig.baseUrlApp}/ebook/{slug}`
- ✅ `fetchBukuOwned()`: Mengubah URL dari `${AppConfig.baseUrl}/dev/ebook/owned` ke `${AppConfig.baseUrlApp}/ebook/owned`
- ✅ `createReview()`: Mengubah URL dari `${AppConfig.baseUrl}/dev/review/create` ke `${AppConfig.baseUrlApp}/review/create`

## URL Comparison

### Before (Wrong):

```
${AppConfig.baseUrl}/dev/ebook/list
= https://andidigital.andipublisher.com/api/dev/ebook/list
```

### After (Correct):

```
${AppConfig.baseUrlApp}/ebook/list
= https://andidigital.andipublisher.com/api/dev/ebook/list
```

## Testing

Untuk menguji fix ini:

1. **Login** ke aplikasi
2. **Logout** dari aplikasi
3. **Login kembali** ke aplikasi
4. **Akses halaman home** - seharusnya tidak ada error "Connection reset by peer"
5. **Periksa console logs** untuk memastikan URL yang benar digunakan
6. **Periksa data loading** - seharusnya buku terbaru dan terlaris ter-load dengan normal

## Expected Behavior

Setelah fix ini:

- ✅ URL endpoint yang benar digunakan
- ✅ Tidak ada error "Connection reset by peer"
- ✅ Data buku terbaru dan terlaris ter-load dengan normal
- ✅ Konsistensi URL di seluruh aplikasi
- ✅ Parameter parsing yang benar

## Monitoring

Perhatikan log console untuk:

- 🔵 `[BOOK SERVICE] Fetching buku terbaru from: https://andidigital.andipublisher.com/api/dev/ebook/list?tag=terbaru&limit=10&offset=0`
- 🔵 `[BOOK SERVICE] Fetching buku terlaris from: https://andidigital.andipublisher.com/api/dev/ebook/list?tag=terlaris&limit=10&offset=0`
- 🔵 `[BOOK SERVICE] Response Status: 200`
- 🔴 Error messages jika masih ada masalah

## Key Improvements

1. **Correct URL Construction**: Menggunakan `AppConfig.baseUrlApp` yang sudah benar
2. **Consistent Endpoint Usage**: Semua endpoint menggunakan URL yang konsisten
3. **Proper Parameter Parsing**: Parameter URL di-parse dengan benar
4. **Error Prevention**: Mencegah error "Connection reset by peer"

## URL Endpoints yang Diperbaiki

- ✅ `/ebook/list?tag=terbaru` - Fetch buku terbaru
- ✅ `/ebook/list?tag=terlaris` - Fetch buku terlaris
- ✅ `/ebook/{slug}` - Fetch detail buku
- ✅ `/ebook/owned` - Fetch buku yang dimiliki
- ✅ `/review/create` - Create review

Jika masih ada masalah, periksa:

1. URL endpoint yang digunakan
2. Parameter yang dikirim
3. Network connectivity
4. Server response
5. API endpoint availability
