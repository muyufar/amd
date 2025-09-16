# Google Sign-In Sederhana (Tanpa Firebase)

## 🎯 **Logika Sederhana:**

1. **User klik tombol Google Sign-In**
2. **Google Sign-In popup muncul**
3. **User pilih akun Google**
4. **Dapat ID Token dari Google**
5. **Kirim ID Token ke backend: `https://andidigital.andipublisher.com/api/auth/google-login`**
6. **Backend verifikasi dan kembalikan token aplikasi**
7. **User login berhasil**

## 📋 **Setup Google Cloud Console:**

### 1. **Buat OAuth 2.0 Client ID**

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. **APIs & Services** > **Credentials**
3. Klik **+ CREATE CREDENTIALS** > **OAuth 2.0 Client IDs**
4. Pilih **Android**
5. Isi:
   - Package name: `com.andi.digital.andi_digital`
   - SHA-1: `52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B`

### 2. **Buat Web Application Client ID**

1. Klik **+ CREATE CREDENTIALS** > **OAuth 2.0 Client IDs**
2. Pilih **Web application**
3. Isi:
   - Name: `Andi Digital Web Client`
   - Authorized JavaScript origins: `https://andidigital.andipublisher.com`
   - Authorized redirect URIs: `https://andidigital.andipublisher.com/auth/google/callback`

### 3. **Aktifkan APIs**

1. **APIs & Services** > **Library**
2. Aktifkan:
   - **Google Sign-In API**
   - **Google Identity Services API**

## 🔧 **Kode Flutter:**

### **AuthController yang Sudah Diupdate:**

```dart
// Google Sign-In instance
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'profile',
  ],
  serverClientId: AppConfig.googleWebClientId,
);

// Login method
Future<void> loginWithGoogle() async {
  try {
    // Trigger Google Sign-In
    final GoogleSignInAccount? account = await _googleSignIn.signIn();

    if (account == null) return; // User cancelled

    // Get authentication
    final GoogleSignInAuthentication auth = await account.authentication;

    // Get ID token
    final idToken = auth.idToken;
    if (idToken == null) {
      throw Exception('ID Token not available');
    }

    // Call backend
    final result = await _authService.googleLogin(idToken: idToken);

    if (result['code'] == 200) {
      // Store user data and navigate
      box.write('token', result['content']['access_token']);
      box.write('user', result['content']['user']);
      Get.offAllNamed('/home');
    }
  } catch (e) {
    // Handle error
  }
}
```

## 🧪 **Testing:**

### **Expected Debug Output:**

```
🟡 [AUTH CONTROLLER] Starting Google login...
🟡 [AUTH CONTROLLER] Starting Google Sign-In...
🟡 [AUTH CONTROLLER] Google account obtained: user@example.com
🟡 [AUTH CONTROLLER] Processing Google authentication...
🟡 [AUTH CONTROLLER] Google authentication obtained
🟡 [AUTH CONTROLLER] ID Token: Available
🟢 [AUTH CONTROLLER] Google ID Token obtained, calling backend...
🟢 [AUTH CONTROLLER] Backend login successful!
```

## 📡 **API Call ke Backend:**

### **Request:**

```http
POST https://andidigital.andipublisher.com/api/auth/google-login
Content-Type: application/json

{
  "idToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### **Expected Response:**

```json
{
  "code": 200,
  "message": "Login successful",
  "content": {
    "access_token": "your_app_token",
    "user": {
      "id": 123,
      "email": "user@example.com",
      "name": "User Name"
    },
    "expires_at": "2024-01-01T12:00:00Z"
  }
}
```

## 🚨 **Troubleshooting:**

### **Jika Error "sign_in_failed":**

1. Pastikan SHA-1 fingerprint sudah terdaftar di Google Cloud
2. Pastikan package name sesuai: `com.andi.digital.andi_digital`
3. Pastikan Web Client ID benar di `AppConfig.googleWebClientId`
4. Test di device fisik, bukan emulator

### **Jika Error "ID Token NULL":**

1. Pastikan Google Sign-In berhasil
2. Pastikan user memberikan permission email dan profile
3. Cek koneksi internet

## 📱 **Keuntungan Pendekatan Sederhana:**

| Aspek            | Firebase | Google Sign-In Sederhana |
| ---------------- | -------- | ------------------------ |
| **Setup**        | Mudah    | Sedikit lebih rumit      |
| **Dependencies** | Banyak   | Minimal                  |
| **Bundle Size**  | Besar    | Kecil                    |
| **Complexity**   | Tinggi   | Rendah                   |
| **Control**      | Terbatas | Penuh                    |

## 🔗 **Referensi:**

- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [OAuth 2.0 for Mobile](https://developers.google.com/identity/protocols/oauth2/native-app)

## 📞 **Support:**

Jika masih error:

1. Share debug output lengkap
2. Pastikan SHA-1 fingerprint benar
3. Pastikan Web Client ID benar
4. Test di device fisik
