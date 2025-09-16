# Google Cloud Console Setup Guide

## Informasi OAuth 2.0 Client:

### Web Application Client ID:

```
Client ID: 1053029938463-v3ct33fb3cjmtutefeu2gp1tqa6mn08s.apps.googleusercontent.com
Client Secret: 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
Tipe: Web application
```

### Android Client ID (Perlu dibuat):

```
Package name: com.andi.digital.andi_digital
SHA-1: 52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B
SHA-256: 52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B
```

## Langkah-langkah Konfigurasi:

### 1. Buka Google Cloud Console

1. Kunjungi [https://console.cloud.google.com/](https://console.cloud.google.com/)
2. Pilih project Anda
3. Buka **APIs & Services** > **Credentials**

### 2. Konfigurasi Web Application Client ID

1. Cari client ID: `1053029938463-v3ct33fb3cjmtutefeu2gp1tqa6mn08s.apps.googleusercontent.com`
2. Pastikan tipe: **Web application**
3. Di **Authorized JavaScript origins**, tambahkan:
   ```
   https://andidigital.andipublisher.com
   http://localhost:8080
   http://localhost:3000
   ```
4. Di **Authorized redirect URIs**, tambahkan:
   ```
   https://andidigital.andipublisher.com/auth/google/callback
   http://localhost:8080/auth/google/callback
   ```

### 3. Buat Android Client ID

1. Klik **+ CREATE CREDENTIALS** > **OAuth 2.0 Client IDs**
2. Pilih **Android** sebagai Application type
3. Isi form:
   - **Package name**: `com.andi.digital.andi_digital`
   - **SHA-1 certificate fingerprint**: `52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B`
4. Klik **Create**

### 4. Aktifkan APIs yang Diperlukan

1. Buka **APIs & Services** > **Library**
2. Cari dan aktifkan:
   - **Google Sign-In API**
   - **Google+ API** (jika masih ada)
   - **Google Identity Services API**

### 5. Konfigurasi OAuth Consent Screen

1. Buka **APIs & Services** > **OAuth consent screen**
2. Pilih **External** atau **Internal**
3. Isi informasi aplikasi:
   - **App name**: Andi Digital
   - **User support email**: [email Anda]
   - **Developer contact information**: [email Anda]
4. Di **Scopes**, tambahkan:
   - `.../auth/userinfo.email`
   - `.../auth/userinfo.profile`
5. Di **Test users**, tambahkan email yang akan test

## Testing dan Debug:

### 1. Test di Device Fisik

- Google Sign-In lebih reliable di device fisik
- Pastikan device memiliki Google Play Services
- Pastikan device terhubung ke internet

### 2. Debug Output

Aplikasi akan menampilkan debug log seperti:

```
🟡 [AUTH CONTROLLER] Starting Google login...
🟡 [AUTH CONTROLLER] Web Client ID: 1053029938463-v3ct33fb3cjmtutefeu2gp1tqa6mn08s.apps.googleusercontent.com
🟡 [AUTH CONTROLLER] Initializing GoogleSignIn...
🟡 [AUTH CONTROLLER] Calling GoogleSignIn.signIn()...
🟡 [AUTH CONTROLLER] Google account obtained: user@example.com
🟡 [AUTH CONTROLLER] Getting authentication...
🟡 [AUTH CONTROLLER] Authentication obtained
🟡 [AUTH CONTROLLER] Access token: Available
🟡 [AUTH CONTROLLER] ID token: Available
```

### 3. Troubleshooting

Jika masih error:

1. **Cek SHA fingerprint** sudah benar
2. **Cek package name** sesuai
3. **Cek Web Client ID** benar
4. **Test di device fisik**
5. **Cek Google Play Services**

## Fitur Baru yang Ditambahkan:

### 1. **Auto Sign-In**

- Jika user sudah login, langsung ambil data tanpa popup lagi
- Menggunakan `_googleSignIn.currentUser`

### 2. **Google Play Services Check**

- Cek ketersediaan Google Play Services
- Error handling yang lebih baik

### 3. **Enhanced Error Handling**

- Error message yang lebih user-friendly
- Kategorisasi error berdasarkan tipe

### 4. **Additional Scopes**

- `email` dan `profile` scope
- Akses ke display name dan photo URL

### 5. **Sign Out & Disconnect**

- Method untuk sign out dari Google
- Method untuk revoke access (disconnect)

## Catatan Penting:

- **Web Client ID** digunakan di kode Flutter
- **Android Client ID** diperlukan untuk verifikasi Android
- **Client Secret** tidak digunakan di mobile app (hanya untuk backend)
- Test selalu di device fisik untuk hasil yang akurat
