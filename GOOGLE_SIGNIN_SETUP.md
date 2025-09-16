         # Google Sign-In Setup Guide

         ## Error yang terjadi:

         ```
         PlatformException(sign_in_failed, n0.b:10:, null, null)
         ```

         ## Informasi Aplikasi:

         - **Package Name**: `com.andi.digital.andi_digital`
         - **Debug SHA-1**: `52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B`
         - **Debug SHA-256**: `52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B`
         - **Web Client ID**: `1053029938463-n1f640ku3r92hrtsrmj0si1k5f6b06iq.apps.googleusercontent.com`
         - **Client Secret**: `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`

         ## Langkah-langkah Konfigurasi:

         ### 1. Google Cloud Console Setup

         1. Buka [Google Cloud Console](https://console.cloud.google.com/)
         2. Pilih project Anda
         3. Buka **APIs & Services** > **Credentials**
         4. Pastikan ada **OAuth 2.0 Client IDs** dengan tipe **Android**

         ### 2. Android OAuth Client Configuration

         1. Di **Credentials**, klik **OAuth 2.0 Client IDs**
         2. Cari client dengan tipe **Android** atau buat yang baru
         3. Isi konfigurasi:
            - **Package name**: `com.andi.digital.andi_digital`
            - **SHA-1 certificate fingerprint**: `52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B`

         ### 3. Web OAuth Client Configuration

         1. Pastikan ada **OAuth 2.0 Client IDs** dengan tipe **Web application**
         2. Client ID yang digunakan di `AppConfig.googleWebClientId` harus dari **Web application**, bukan Android
         3. Di **Authorized JavaScript origins**, tambahkan:
            - `https://andidigital.andipublisher.com`
            - `http://localhost:8080` (untuk development)

         ### 4. Firebase Configuration (Opsional tapi Direkomendasikan)

         1. Buka [Firebase Console](https://console.firebase.google.com/)
         2. Pilih project Anda
         3. Buka **Project Settings** > **Your apps**
         4. Pilih aplikasi Android atau buat yang baru
         5. Di **SHA certificate fingerprints**, tambahkan:
            - SHA-1: `52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B`
            - SHA-256: `52:26:45:A1:DC:38:53:CB:6A:1F:06:77:0E:9A:2E:AE:BC:75:DB:3A:A3:CC:76:D9:53:38:7A:C4:32:B`

         ### 5. Verifikasi Konfigurasi

         1. Pastikan **Google Sign-In API** sudah diaktifkan di **APIs & Services** > **Library**
         2. Pastikan **Google+ API** sudah diaktifkan (jika masih ada)
         3. Pastikan scope `email` diizinkan

         ## Troubleshooting:

         ### Jika masih error "sign_in_failed":

         1. **Cek SHA Fingerprint**: Pastikan SHA-1 dan SHA-256 sudah benar
         2. **Cek Package Name**: Pastikan `applicationId` di `build.gradle` sama dengan yang di Google Cloud
         3. **Cek Web Client ID**: Pastikan menggunakan Web Client ID, bukan Android Client ID
         4. **Test di Device Fisik**: Google Sign-In mungkin tidak bekerja di emulator
         5. **Cek Google Play Services**: Pastikan device memiliki Google Play Services

         ### Debug Steps:

         1. Jalankan aplikasi dengan debug logging yang sudah ditambahkan
         2. Lihat console output untuk melihat di mana error terjadi
         3. Pastikan `auth.idToken` tidak null

         ## Testing:

         1. Uninstall aplikasi dari device
         2. Build ulang dengan `flutter clean && flutter pub get`
         3. Install dan test Google Sign-In
         4. Lihat debug output di console

         ## Catatan Penting:

         - **Web Client ID** diperlukan untuk mendapatkan `idToken` di Android
         - **Android Client ID** diperlukan untuk autentikasi Google
         - Kedua client ID harus dikonfigurasi dengan benar
         - SHA fingerprint harus sesuai dengan keystore yang digunakan (debug/release)
