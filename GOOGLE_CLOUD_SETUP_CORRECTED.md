# Google Cloud Console Setup Guide - CORRECTED

## ⚠️ MASALAH YANG DITEMUKAN:

### 1. **OAuth Playground Redirect URI SALAH**

- ❌ JANGAN gunakan: `https://developers.google.com/oauthplayground`
- ✅ Gunakan: Domain aplikasi Anda sendiri

### 2. **Client ID Configuration SALAH**

- ❌ Jangan gunakan `clientId` di Android
- ✅ Gunakan `serverClientId` untuk Android

## 🔧 SOLUSI LENGKAP:

### 1. **Google Cloud Console Configuration**

#### A. Web Application Client ID

```
Client ID: 1053029938463-n1f640ku3r92hrtsrmj0si1k5f6b06iq.apps.googleusercontent.com
Client Secret: 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
Tipe: Web application
```

**Authorized JavaScript origins:**

```
https://andidigital.andipublisher.com
http://localhost:8080
http://localhost:3000
```

**Authorized redirect URIs:**

```
https://andidigital.andipublisher.com/auth/google/callback
http://localhost:8080/auth/google/callback
http://localhost:3000/auth/google/callback
```

#### B. Android Client ID (WAJIB DIBUAT)

```
Package name: com.andi.digital.andi_digital
SHA-1: 52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B
```

### 2. **Langkah-langkah di Google Cloud Console:**

#### Step 1: Buat Android Client ID

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. **APIs & Services** > **Credentials**
3. Klik **+ CREATE CREDENTIALS** > **OAuth 2.0 Client IDs**
4. Pilih **Android**
5. Isi:
   - Package name: `com.andi.digital.andi_digital`
   - SHA-1: `52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B`

#### Step 2: Update Web Client ID

1. Cari Web Client ID yang sudah ada
2. **HAPUS** redirect URI yang mengandung `oauthplayground`
3. Tambahkan redirect URI yang benar (domain Anda)

#### Step 3: Aktifkan APIs

1. **APIs & Services** > **Library**
2. Cari dan aktifkan:
   - **Google Sign-In API**
   - **Google Identity Services API**

### 3. **Kode Flutter yang Sudah Diperbaiki:**

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'profile',
  ],
  // ✅ Gunakan serverClientId untuk Android
  serverClientId: AppConfig.googleWebClientId,
);
```

## 🧪 TESTING:

### 1. **Clean dan Rebuild**

```bash
flutter clean
flutter pub get
flutter run --debug
```

### 2. **Expected Debug Output (Tanpa Warning)**

```
🟡 [AUTH CONTROLLER] Starting Google login...
🟡 [AUTH CONTROLLER] Web Client ID: 1053029938463-n1f640ku3r92hrtsrmj0si1k5f6b06iq.apps.googleusercontent.com
🟡 [AUTH CONTROLLER] Attempting silent sign in...
🟡 [AUTH CONTROLLER] Silent sign in returned null
🟡 [AUTH CONTROLLER] Initializing GoogleSignIn...
🟡 [AUTH CONTROLLER] Calling GoogleSignIn.signIn()...
🟡 [AUTH CONTROLLER] Google account obtained: user@example.com
🟡 [AUTH CONTROLLER] Getting authentication...
🟡 [AUTH CONTROLLER] Authentication obtained
🟡 [AUTH CONTROLLER] ID token: Available
```

### 3. **Tidak Ada Lagi Warning:**

- ❌ `clientId is not supported on Android`
- ❌ `PlatformException(sign_in_failed, ApiException: 10)`

## 🚨 TROUBLESHOOTING:

### **Jika Masih Error "sign_in_failed":**

1. **Pastikan Android Client ID sudah dibuat**

   - Package name: `com.andi.digital.andi_digital`
   - SHA-1: `52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B`

2. **Pastikan Web Client ID benar**

   - Tipe: **Web application** (bukan Android)
   - Redirect URIs: Domain aplikasi Anda (bukan oauthplayground)

3. **Test di Device Fisik**

   - Google Sign-In tidak reliable di emulator
   - Pastikan Google Play Services tersedia

4. **Cek SHA Fingerprint**
   - Gunakan script `get_sha_fingerprint.bat` untuk verifikasi

## 📱 VERIFIKASI KONFIGURASI:

### **Checklist yang Harus Dipenuhi:**

- [ ] **Android Client ID** sudah dibuat dengan package name dan SHA-1 yang benar
- [ ] **Web Client ID** tipe "Web application" (bukan Android)
- [ ] **Redirect URIs** menggunakan domain aplikasi Anda (bukan oauthplayground)
- [ ] **SHA fingerprint** sudah terdaftar di Android Client ID
- [ ] **Google Sign-In API** sudah diaktifkan
- [ ] **OAuth consent screen** sudah dikonfigurasi

## 🔗 Referensi:

- [Google Sign-In Android Setup](https://developers.google.com/identity/sign-in/android/start)
- [OAuth 2.0 for Mobile & Desktop Apps](https://developers.google.com/identity/protocols/oauth2/native-app)
- [Google Cloud Console](https://console.cloud.google.com/)

## 📞 Support:

Jika masih error setelah mengikuti panduan ini:

1. Share screenshot Google Cloud Console Credentials
2. Share debug output lengkap
3. Pastikan semua checklist sudah dipenuhi
