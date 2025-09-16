# Firebase Setup Guide untuk Google Sign-In

## 🔥 Mengapa Menggunakan Firebase?

### Keuntungan Firebase Auth:
- ✅ **Lebih Mudah**: Tidak perlu konfigurasi Google Cloud Console yang rumit
- ✅ **Lebih Reliable**: Firebase menangani token management secara otomatis
- ✅ **Cross-Platform**: Bisa digunakan di Android, iOS, dan Web
- ✅ **Real-time**: Token refresh otomatis
- ✅ **Security**: Firebase menangani security best practices

## 📋 Langkah-langkah Setup Firebase:

### 1. **Buat Firebase Project**
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik **Create a project** atau **Add project**
3. Masukkan nama project: `andi-digital-app`
4. Pilih **Enable Google Analytics** (opsional)
5. Klik **Create project**

### 2. **Tambahkan Android App ke Firebase**
1. Di Firebase Console, klik **Android icon** (</>) 
2. Masukkan **Android package name**: `com.andi.digital.andi_digital`
3. Masukkan **App nickname**: `Andi Digital`
4. Klik **Register app**
5. Download file `google-services.json`
6. Letakkan file di folder `android/app/`

### 3. **Konfigurasi Android**
1. Buka `android/build.gradle`
2. Tambahkan di dependencies:
   ```gradle
   classpath 'com.google.gms:google-services:4.4.0'
   ```

3. Buka `android/app/build.gradle`
4. Tambahkan di bagian bawah:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### 4. **Aktifkan Google Sign-In di Firebase**
1. Di Firebase Console, buka **Authentication**
2. Klik **Sign-in method**
3. Klik **Google** provider
4. **Enable** Google Sign-In
5. Masukkan **Project support email**
6. Klik **Save**

### 5. **Download google-services.json**
1. Di Firebase Console, klik **Project Settings**
2. Di tab **General**, scroll ke bawah
3. Klik **Download google-services.json**
4. Letakkan file di `android/app/google-services.json`

## 🔧 Konfigurasi Flutter:

### 1. **Dependencies yang Sudah Ditambahkan**
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  google_sign_in: ^6.2.1
```

### 2. **Initialize Firebase di main.dart**
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### 3. **Kode Google Sign-In dengan Firebase**
```dart
// Google Sign-In instance
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'profile',
  ],
  serverClientId: AppConfig.googleWebClientId,
);

// Firebase Auth instance
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

// Sign in method
Future<void> loginWithGoogle() async {
  try {
    // Trigger Google Sign-In
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) return; // User cancelled
    
    // Get auth details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // Sign in to Firebase
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    
    // Get Firebase ID token
    final idToken = await userCredential.user!.getIdToken();
    
    // Call your backend
    final result = await _authService.googleLogin(idToken: idToken);
    
    // Handle success
    if (result['code'] == 200) {
      // Store user data and navigate
    }
  } catch (e) {
    // Handle error
  }
}
```

## 🧪 Testing:

### 1. **Build dan Test**
```bash
flutter clean
flutter pub get
flutter run --debug
```

### 2. **Expected Debug Output**
```
🟡 [AUTH CONTROLLER] Starting Firebase Google login...
🟡 [AUTH CONTROLLER] Starting Google Sign-In...
🟡 [AUTH CONTROLLER] Google account obtained: user@example.com
🟡 [AUTH CONTROLLER] Google authentication obtained
🟡 [AUTH CONTROLLER] ID Token: Available
🟡 [AUTH CONTROLLER] Access Token: Available
🟡 [AUTH CONTROLLER] Signing in to Firebase...
🟢 [AUTH CONTROLLER] Firebase sign in successful!
🟡 [AUTH CONTROLLER] Processing Firebase authentication...
🟡 [AUTH CONTROLLER] Firebase User ID: 123456789
🟡 [AUTH CONTROLLER] Firebase User Email: user@example.com
🟡 [AUTH CONTROLLER] Firebase ID Token obtained
🟢 [AUTH CONTROLLER] Firebase ID Token obtained, calling backend...
```

## 🚨 Troubleshooting:

### **Jika Error "google-services.json not found":**
1. Pastikan file `google-services.json` ada di `android/app/`
2. Pastikan package name di `google-services.json` sama dengan `applicationId`

### **Jika Error "Google Sign-In not enabled":**
1. Buka Firebase Console > Authentication > Sign-in method
2. Enable Google provider
3. Masukkan Project support email

### **Jika Error "SHA fingerprint not found":**
1. Firebase akan otomatis menggunakan SHA-1 dari debug keystore
2. Untuk release, tambahkan SHA-1 release keystore di Firebase Console

## 📱 Keuntungan Firebase vs Google Cloud Console:

| Aspek | Google Cloud Console | Firebase |
|-------|---------------------|----------|
| **Setup** | Rumit, perlu konfigurasi manual | Mudah, wizard setup |
| **Token Management** | Manual | Otomatis |
| **Cross-Platform** | Perlu setup terpisah | Satu konfigurasi |
| **Security** | Manual | Best practices otomatis |
| **Debugging** | Sulit | Firebase Console |
| **Analytics** | Tidak ada | Built-in |

## 🔗 Referensi:

- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Google Sign-In with Firebase](https://firebase.google.com/docs/auth/flutter/google-signin)
- [Firebase Console](https://console.firebase.google.com/)

## 📞 Support:

Jika masih error setelah setup Firebase:
1. Share screenshot Firebase Console Authentication
2. Share error message lengkap
3. Pastikan `google-services.json` sudah benar
