# Fix Login-Logout Issue

## Masalah yang Ditemukan

Setelah login, logout, dan login kembali, aplikasi mengalami error "ClientException with SocketException: Connection reset by peer" ketika mengakses list buku.

### Root Cause Analysis:

1. **Inkonsistensi URL API**:

   - `ApiService` menggunakan `AppConfig.baseUrl` (`https://andidigital.andipublisher.com/api`)
   - `BookService` menggunakan `AppConfig.baseUrlApp` (`https://andidigital.andipublisher.com/api/dev`)

2. **Token Management Issue**:

   - Setelah logout, token dihapus dari storage
   - Ketika login ulang, token baru disimpan
   - Tapi `BookService` masih menggunakan endpoint yang salah atau token yang tidak valid

3. **Connection Reset Error**:
   - Error "Connection reset by peer" terjadi karena server menolak koneksi
   - Kemungkinan karena endpoint yang salah atau token yang tidak valid

## Solusi yang Diimplementasikan

### 1. Menyelaraskan URL API

- Mengubah semua method di `BookService` untuk menggunakan `AppConfig.baseUrl` + `/dev`
- Memastikan konsistensi URL di seluruh aplikasi

### 2. Memperbaiki Error Handling

- Menambahkan logging yang lebih detail untuk debugging
- Menambahkan try-catch yang lebih komprehensif
- Menambahkan informasi status code dan response body

### 3. Memperbaiki Token Management

- Memastikan token yang valid digunakan untuk endpoint yang memerlukan autentikasi
- Menambahkan pengecekan token sebelum mengirim request
- Memperbaiki handling untuk endpoint public vs private

### 4. Menambahkan Method Refresh

- Menambahkan method `refreshData()` di `HomeController` untuk refresh data setelah login ulang

## Perubahan yang Dibuat

### File: `lib/services/book_service.dart`

- ✅ Mengubah URL dari `AppConfig.baseUrlApp` ke `AppConfig.baseUrl + '/dev'`
- ✅ Menambahkan logging yang lebih detail
- ✅ Memperbaiki error handling dengan try-catch
- ✅ Menambahkan Content-Type header
- ✅ Memperbaiki semua method: `fetchBukuTerbaru`, `fetchBukuTerlaris`, `fetchDetailBuku`, `fetchBukuOwned`, `createReview`

### File: `lib/controllers/home_controller.dart`

- ✅ Menambahkan logging yang lebih detail
- ✅ Menambahkan method `refreshData()` untuk refresh data setelah login ulang

## Testing

Untuk menguji fix ini:

1. **Login** ke aplikasi
2. **Logout** dari aplikasi
3. **Login kembali** ke aplikasi
4. **Akses halaman home** - seharusnya tidak ada error "Connection reset by peer"
5. **Periksa console logs** untuk memastikan request berhasil

## Expected Behavior

Setelah fix ini:

- ✅ URL API konsisten di seluruh aplikasi
- ✅ Token management berfungsi dengan baik
- ✅ Tidak ada error "Connection reset by peer"
- ✅ List buku terbaru dan terlaris dapat dimuat dengan normal
- ✅ Logging yang lebih detail untuk debugging

## Monitoring

Perhatikan log console untuk:

- 🔵 `[BOOK SERVICE]` - Request dan response dari BookService
- 🔵 `[HOME CONTROLLER]` - Status loading data di HomeController
- 🔴 Error messages jika masih ada masalah

Jika masih ada masalah, periksa:

1. Koneksi internet
2. Status server API
3. Token yang tersimpan di storage
4. URL endpoint yang digunakan
