import 'package:andi_digital/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final AuthService _authService = AuthService();
  final box = GetStorage();
  var isPasswordVisible = false.obs;

  // Method untuk mengecek apakah token masih valid
  bool isTokenValid() {
    final expiresAt = box.read('expires_at');
    if (expiresAt == null) return false;

    try {
      final expiryDate = DateTime.parse(expiresAt.toString());
      final now = DateTime.now();
      return now.isBefore(expiryDate);
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] Error parsing expiry date: $e');
      return false;
    }
  }

  // Method untuk logout dan clear data
  Future<void> logout() async {
    print('🟡 [AUTH CONTROLLER] Starting logout process...');

    try {
      // Call logout API
      final result = await _authService.logout();

      print('🟡 [AUTH CONTROLLER] Logout API response: $result');

      if (result['code'] == 200) {
        print('🟢 [AUTH CONTROLLER] Logout API successful');
      } else {
        print(
            '🔴 [AUTH CONTROLLER] Logout API failed - Code: ${result['code']}');
        print('🔴 [AUTH CONTROLLER] Error message: ${result['message']}');
      }
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] Logout API error: $e');
      // Continue with local logout even if API fails
    }

    // Always clear local data regardless of API response
    box.remove('token');
    box.remove('user');
    box.remove('expires_at');
    box.remove('google_user');

    // Sign out from Google if signed in
    if (isSignedIn) {
      try {
        await signOutGoogle();
        print('🟡 [AUTH CONTROLLER] Google Sign-Out successful');
      } catch (e) {
        print('🔴 [AUTH CONTROLLER] Google Sign-Out failed: $e');
      }
    }

    print('🟡 [AUTH CONTROLLER] Logout completed, all data cleared');
  }

  // Method untuk auto logout ketika token habis
  Future<void> checkTokenAndLogoutIfExpired() async {
    final token = box.read('token');
    // Jika belum pernah login (token null/empty), JANGAN tampilkan popup apapun
    if (token == null || token.toString().isEmpty) {
      return;
    }
    if (!isTokenValid()) {
      print('🔴 [AUTH CONTROLLER] Token expired, auto logout');
      await logout();

      // Tampilkan popup hanya jika user sedang di halaman yang memerlukan login
      if (Get.currentRoute != '/login' && Get.currentRoute != '/register') {
        Get.defaultDialog(
          title: 'Sesi Berakhir',
          middleText: 'Maaf sesi login telah habis, silahkan login kembali',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          barrierDismissible: false,
          onConfirm: () {
            Get.back();
            Get.offAllNamed('/login');
          },
        );
      }
    }
  }

  // Method untuk mendapatkan token (dengan pengecekan expiry)
  String? getValidToken() {
    final token = box.read('token');
    // Jika belum pernah login, kembalikan null tanpa memicu popup
    if (token == null || token.toString().isEmpty) {
      return null;
    }
    if (isTokenValid()) {
      return token;
    }
    // Jika ada token tapi sudah expired, jalankan handler
    checkTokenAndLogoutIfExpired();
    return null;
  }

  // Static method untuk memastikan AuthController tersedia
  static AuthController get instance {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    return Get.find<AuthController>();
  }

  // Method untuk hot restart aplikasi
  Future<void> hotRestart() async {
    print('🟡 [AUTH CONTROLLER] Starting hot restart...');
    try {
      // Clear semua controller yang tidak permanent
      // Get.reset() akan menghapus semua controller kecuali yang permanent
      Get.reset();

      // Restart aplikasi dengan delay kecil untuk memastikan reset selesai
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate ke home dengan fresh state
      Get.offAllNamed('/home');

      print('🟢 [AUTH CONTROLLER] Hot restart completed');
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] Hot restart failed: $e');
      // Fallback: navigate ke home tanpa restart
      Get.offAllNamed('/home');
    }
  }

  // Method untuk soft restart (tidak menghapus permanent controllers)
  Future<void> softRestart() async {
    print('🟡 [AUTH CONTROLLER] Starting soft restart...');
    try {
      // Navigate ke home dengan fresh state tanpa reset controller
      // Ini akan memicu HomeBinding untuk re-initialize controllers
      Get.offAllNamed('/home');

      // Delay kecil untuk memastikan navigation selesai
      await Future.delayed(const Duration(milliseconds: 300));

      print('🟢 [AUTH CONTROLLER] Soft restart completed');
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] Soft restart failed: $e');
      // Fallback: navigate ke home tanpa restart
      Get.offAllNamed('/home');
    }
  }

  // Method untuk mengecek token secara berkala (bisa dipanggil dari halaman yang memerlukan auth)
  void startTokenCheck() {
    // Cek token setiap 30 detik
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      final token = box.read('token');
      if (token == null || token.toString().isEmpty) {
        // Belum login, hentikan pengecekan periodik
        timer.cancel();
        return;
      }
      if (!isTokenValid()) {
        timer.cancel();
        await checkTokenAndLogoutIfExpired();
      }
    });
  }

  Future<void> login() async {
    isLoading.value = true;

    print('🟡 [AUTH CONTROLLER] Starting login...');
    print('🟡 [AUTH CONTROLLER] Email: ${emailController.text}');
    print(
        '🟡 [AUTH CONTROLLER] Password: ${passwordController.text.length} chars');

    try {
      final result = await _authService.login(
        emailController.text,
        passwordController.text,
      );

      print('🟡 [AUTH CONTROLLER] Response received: $result');
      print('🟡 [AUTH CONTROLLER] Response code: ${result['code']}');
      if (result['code'] == 200) {
        print('🟢 [AUTH CONTROLLER] Login successful!');
        box.write('token', result['content']['access_token']);
        box.write('user', result['content']['user']);
        box.write('expires_at', result['content']['expires_at']);

        // Soft restart untuk memastikan aplikasi dalam state bersih
        await softRestart();
      } else {
        print('🔴 [AUTH CONTROLLER] Login failed - Code: ${result['code']}');
        print('🔴 [AUTH CONTROLLER] Error message: ${result['message']}');
        Get.defaultDialog(
          title: 'Login Gagal',
          middleText: result['message'] ?? 'Terjadi kesalahan saat login',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(),
        );
      }
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] Exception caught: $e');
      print('🔴 [AUTH CONTROLLER] Exception type: ${e.runtimeType}');
      Get.defaultDialog(
        title: 'Error',
        middleText: e.toString(),
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
      print('🟡 [AUTH CONTROLLER] Login process completed');
    }
  }

  // Google Sign-In instance - sederhana
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
    ],
    // Gunakan serverClientId untuk Android (Web Client ID)
    serverClientId: AppConfig.googleWebClientId,
  );

  // Check if user is already signed in
  bool get isSignedIn => _googleSignIn.currentUser != null;

  // Get current user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  // Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      print('🟡 [AUTH CONTROLLER] Google Sign-Out successful');
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] Sign-Out failed: $e');
    }
  }

  // Disconnect from Google (revoke access)
  Future<void> disconnectGoogle() async {
    try {
      await _googleSignIn.disconnect();
      print('🟡 [AUTH CONTROLLER] Google Disconnect successful');
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] Google Disconnect failed: $e');
    }
  }

  // Check if Google Play Services is available
  Future<bool> isGooglePlayServicesAvailable() async {
    try {
      // This will throw an exception if Google Play Services is not available
      await _googleSignIn.signInSilently();
      return true;
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] Google Play Services not available: $e');
      return false;
    }
  }

  // Sign in silently (without user interaction) - sesuai versi 6.2.1
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      print('🟡 [AUTH CONTROLLER] Attempting silent sign in...');
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        print(
            '🟢 [AUTH CONTROLLER] Silent sign in successful: ${account.email}');
      } else {
        print('🟡 [AUTH CONTROLLER] Silent sign in returned null');
      }
      return account;
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] Silent sign in failed: $e');
      return null;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    print('🟡 [AUTH CONTROLLER] Starting Google login...');
    print('🟡 [AUTH CONTROLLER] Web Client ID: ${AppConfig.googleWebClientId}');

    try {
      // Check if user is already signed in
      if (isSignedIn) {
        print('🟡 [AUTH CONTROLLER] User already signed in...');
        final account = currentUser;
        if (account != null) {
          print('🟡 [AUTH CONTROLLER] Current user: ${account.email}');
          await _processGoogleAuthentication(account);
          return;
        }
      }

      // Sign in with Google
      print('🟡 [AUTH CONTROLLER] Starting Google Sign-In...');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        print('🟡 [AUTH CONTROLLER] Google Sign-In cancelled by user');
        isLoading.value = false;
        return; // dibatalkan user
      }

      print('🟡 [AUTH CONTROLLER] Google account obtained: ${account.email}');
      print('🟡 [AUTH CONTROLLER] Display Name: ${account.displayName}');
      print('🟡 [AUTH CONTROLLER] Photo URL: ${account.photoUrl}');

      // Process the authentication
      await _processGoogleAuthentication(account);
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] Exception caught during Google login: $e');
      print('🔴 [AUTH CONTROLLER] Exception type: ${e.runtimeType}');

      String errorMessage = 'Terjadi kesalahan saat login dengan Google';

      if (e.toString().contains('sign_in_failed')) {
        errorMessage =
            'Google Sign-In gagal. Pastikan:\n\n1. SHA fingerprint sudah terdaftar di Google Cloud\n2. Package name sesuai\n3. Web Client ID benar\n4. Test di device fisik, bukan emulator';
      } else if (e.toString().contains('network_error')) {
        errorMessage = 'Error jaringan. Pastikan koneksi internet stabil';
      } else if (e.toString().contains('play_services_not_available')) {
        errorMessage = 'Google Play Services tidak tersedia';
      }

      Get.defaultDialog(
        title: 'Google Sign-In Error',
        middleText: errorMessage,
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
      print('🟡 [AUTH CONTROLLER] Google login process completed');
    }
  }

  // Process Google authentication and call backend
  Future<void> _processGoogleAuthentication(GoogleSignInAccount account) async {
    try {
      print('🟡 [AUTH CONTROLLER] Processing Google authentication...');
      print('🟡 [AUTH CONTROLLER] Google User Email: ${account.email}');
      print(
          '🟡 [AUTH CONTROLLER] Google User Display Name: ${account.displayName}');
      print('🟡 [AUTH CONTROLLER] Google User Photo URL: ${account.photoUrl}');
      print('🟡 [AUTH CONTROLLER] Google User ID: ${account.id}');

      // Get Google authentication
      print('🟡 [AUTH CONTROLLER] Getting Google authentication...');
      final GoogleSignInAuthentication auth = await account.authentication;
      print(
          '🟡 [AUTH CONTROLLER] Google authentication obtained successfully!');

      // Debug ID Token
      print('🟡 [AUTH CONTROLLER] === ID TOKEN DEBUG ===');
      print('🟡 [AUTH CONTROLLER] ID Token exists: ${auth.idToken != null}');
      if (auth.idToken != null) {
        print(
            '🟡 [AUTH CONTROLLER] ID Token length: ${auth.idToken!.length} characters');
        print(
            '🟡 [AUTH CONTROLLER] ID Token starts with: ${auth.idToken!.substring(0, 20)}...');
        print(
            '🟡 [AUTH CONTROLLER] ID Token ends with: ...${auth.idToken!.substring(auth.idToken!.length - 20)}');
      } else {
        print('🔴 [AUTH CONTROLLER] ID Token is NULL!');
      }

      // Debug Access Token
      print('🟡 [AUTH CONTROLLER] === ACCESS TOKEN DEBUG ===');
      print(
          '🟡 [AUTH CONTROLLER] Access Token exists: ${auth.accessToken != null}');
      if (auth.accessToken != null) {
        print(
            '🟡 [AUTH CONTROLLER] Access Token length: ${auth.accessToken!.length} characters');
        print(
            '🟡 [AUTH CONTROLLER] Access Token starts with: ${auth.accessToken!.substring(0, 20)}...');
      } else {
        print('🔴 [AUTH CONTROLLER] Access Token is NULL!');
      }

      // Debug Server Auth Code
      print('🟡 [AUTH CONTROLLER] === SERVER AUTH CODE DEBUG ===');
      print(
          '🟡 [AUTH CONTROLLER] Server Auth Code exists: ${auth.serverAuthCode != null}');
      if (auth.serverAuthCode != null) {
        print(
            '🟡 [AUTH CONTROLLER] Server Auth Code length: ${auth.serverAuthCode!.length} characters');
        print('🟡 [AUTH CONTROLLER] Server Auth Code: ${auth.serverAuthCode}');
      } else {
        print('🔴 [AUTH CONTROLLER] Server Auth Code is NULL!');
      }

      // Get ID token
      final idToken = auth.idToken;
      if (idToken == null) {
        print('🔴 [AUTH CONTROLLER] ===== ID TOKEN ERROR =====');
        print('🔴 [AUTH CONTROLLER] Google ID Token is NULL!');
        print('🔴 [AUTH CONTROLLER] This usually means:');
        print(
            '🔴 [AUTH CONTROLLER] 1. SHA fingerprint not registered in Google Cloud');
        print('🔴 [AUTH CONTROLLER] 2. Package name mismatch');
        print('🔴 [AUTH CONTROLLER] 3. Web Client ID is incorrect');
        print(
            '🔴 [AUTH CONTROLLER] 4. Testing on emulator instead of physical device');

        Get.defaultDialog(
          title: 'Google Authentication Error',
          middleText:
              'Google ID Token tidak tersedia. Pastikan:\n\n1. SHA fingerprint sudah terdaftar di Google Cloud\n2. Package name sesuai\n3. Web Client ID benar\n4. Test di device fisik, bukan emulator',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(),
        );
        return;
      }

      print('🟢 [AUTH CONTROLLER] ===== ID TOKEN SUCCESS =====');
      print('🟢 [AUTH CONTROLLER] Google ID Token obtained successfully!');
      print('🟢 [AUTH CONTROLLER] Token length: ${idToken.length} characters');
      print(
          '🟢 [AUTH CONTROLLER] Token preview: ${idToken.substring(0, 50)}...');
      print('🟢 [AUTH CONTROLLER] Calling backend with ID token...');

      // Call backend with Google ID token
      final result = await _authService.googleLogin(idToken: idToken);

      if (result['code'] == 200) {
        print('🟢 [AUTH CONTROLLER] ===== BACKEND SUCCESS =====');
        print('🟢 [AUTH CONTROLLER] Backend login successful!');
        print('🟢 [AUTH CONTROLLER] Response code: ${result['code']}');
        print('🟢 [AUTH CONTROLLER] Response message: ${result['message']}');
        print(
            '🟢 [AUTH CONTROLLER] User data received: ${result['content']['user']}');

        // Store user data
        box.write('token', result['content']['access_token']);
        box.write('user', result['content']['user']);
        box.write('expires_at', result['content']['expires_at']);

        // Store Google user info for future use
        box.write('google_user', {
          'email': account.email,
          'displayName': account.displayName,
          'photoUrl': account.photoUrl,
          'idToken': idToken,
        });

        print('🟢 [AUTH CONTROLLER] User data stored successfully!');
        print('🟢 [AUTH CONTROLLER] Starting soft restart...');

        // Soft restart untuk memastikan aplikasi dalam state bersih
        await softRestart();
      } else {
        print('🔴 [AUTH CONTROLLER] ===== BACKEND ERROR =====');
        print(
            '🔴 [AUTH CONTROLLER] Backend login failed - Code: ${result['code']}');
        print('🔴 [AUTH CONTROLLER] Error message: ${result['message']}');
        print('🔴 [AUTH CONTROLLER] Full response: $result');

        Get.defaultDialog(
          title: 'Login Gagal',
          middleText: result['message'] ?? 'Gagal login dengan Google',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(),
        );
      }
    } catch (e) {
      print('🔴 [AUTH CONTROLLER] ===== EXCEPTION ERROR =====');
      print('🔴 [AUTH CONTROLLER] Error processing Google authentication: $e');
      print('🔴 [AUTH CONTROLLER] Exception type: ${e.runtimeType}');
      throw e;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
