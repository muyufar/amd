# Sistem Manajemen Token dan Auto-Logout

## Fitur yang Diimplementasikan

### 1. Pengecekan Token Expiry

- **Otomatis saat aplikasi dimulai**: Token akan dicek saat aplikasi pertama kali dibuka
- **Pengecekan berkala**: Token dicek setiap 30 detik di halaman yang memerlukan authentication
- **Pengecekan saat request API**: Setiap request API akan mengecek validitas token

### 2. Auto-Logout

- **Token habis**: User otomatis logout ketika token expired
- **Popup notifikasi**: Menampilkan popup "Maaf sesi login telah habis, silahkan login kembali"
- **Redirect ke login**: User otomatis diarahkan ke halaman login

### 3. API Service dengan Interceptor

- **Automatic token injection**: Token otomatis ditambahkan ke header Authorization
- **401 response handling**: Jika API mengembalikan 401, user otomatis logout
- **Debug logging**: Semua request dan response di-log untuk debugging

## Cara Penggunaan

### 1. Menggunakan ApiService untuk Request API

```dart
// GET request
final response = await ApiService().get('/api/books');

// POST request
final response = await ApiService().post('/api/books', body: {
  'title': 'Judul Buku',
  'author': 'Penulis'
});

// PUT request
final response = await ApiService().put('/api/books/1', body: {
  'title': 'Judul Baru'
});

// DELETE request
final response = await ApiService().delete('/api/books/1');
```

### 2. Menambahkan Token Check di Controller

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Mulai pengecekan token secara berkala
    final authController = AuthController.instance;
    authController.startTokenCheck();
  }
}
```

### 3. Mengecek Token Secara Manual

```dart
// Gunakan static method untuk memastikan AuthController tersedia
final authController = AuthController.instance;

// Cek apakah token masih valid
if (authController.isTokenValid()) {
  // Token masih valid
} else {
  // Token sudah expired
}

// Dapatkan token yang valid (akan auto logout jika expired)
final token = authController.getValidToken();

// Cek dan logout jika expired
authController.checkTokenAndLogoutIfExpired();
```

## Flow Auto-Logout

1. **Saat aplikasi dimulai**:

   - `app.dart` memanggil `authController.checkTokenAndLogoutIfExpired()`
   - Jika token expired, tampilkan popup dan redirect ke login

2. **Saat request API**:

   - `ApiService` mengecek token sebelum request
   - Jika token expired, throw exception dan auto logout
   - Jika response 401, auto logout dan tampilkan popup

3. **Pengecekan berkala**:
   - Controller memanggil `authController.startTokenCheck()`
   - Token dicek setiap 30 detik
   - Jika expired, auto logout dan tampilkan popup

## Debug Console

Sistem ini menyediakan debug console yang detail:

- 🔵 API Service logs (request/response)
- 🟡 Auth Controller logs (token check, login process)
- 🟢 Success messages
- 🔴 Error messages dan exception details

## Popup Messages

- **"Sesi Berakhir"**: Ketika token expired dan user sedang di halaman yang memerlukan login
- **"Login Gagal"**: Ketika login gagal dengan pesan dari API
- **"Error"**: Ketika terjadi exception atau network error

## Keamanan

- Token disimpan di GetStorage (local storage)
- Token otomatis dihapus saat logout
- Semua request API menggunakan Bearer token
- Auto logout mencegah akses unauthorized
