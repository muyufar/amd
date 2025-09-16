# Logout API Implementation

## 🔄 **API Endpoint:**
```
POST https://andidigital.andipublisher.com/api/auth/logout
```

## 📋 **Request Details:**

### **Headers:**
```
Content-Type: application/json
```

### **Body:**
```
{} // Empty body, no parameters required
```

## 📤 **Response Format:**

### **Success Response (200):**
```json
{
  "code": 200,
  "message": "Logout successful",
  "errors": null,
  "content": null
}
```

### **Error Response (401/500):**
```json
{
  "code": 401,
  "message": "Unauthorized",
  "errors": "Invalid token",
  "content": null
}
```

## 🔧 **Implementation Details:**

### **1. AuthService.logout()**
```dart
Future<Map<String, dynamic>> logout() async {
  final url = Uri.parse('${AppConfig.baseUrl}/auth/logout');
  
  print('🔵 [AUTH SERVICE] ===== LOGOUT REQUEST =====');
  print('🔵 [AUTH SERVICE] URL: $url');
  print('🔵 [AUTH SERVICE] Method: POST');
  print('🔵 [AUTH SERVICE] Headers: {"Content-Type": "application/json"}');

  try {
    print('🔵 [AUTH SERVICE] Sending logout request to backend...');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print('🔵 [AUTH SERVICE] ===== LOGOUT RESPONSE =====');
    print('🔵 [AUTH SERVICE] Status Code: ${response.statusCode}');
    print('🔵 [AUTH SERVICE] Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('🟢 [AUTH SERVICE] Logout successful');
      final result = jsonDecode(response.body);
      return result;
    } else {
      print('🔴 [AUTH SERVICE] Logout failed - Status: ${response.statusCode}');
      final errorResult = jsonDecode(response.body);
      return errorResult;
    }
  } catch (e) {
    print('🔴 [AUTH SERVICE] ===== LOGOUT NETWORK ERROR =====');
    print('🔴 [AUTH SERVICE] Network Error: $e');
    throw Exception('Network error: $e');
  }
}
```

### **2. AuthController.logout()**
```dart
Future<void> logout() async {
  print('🟡 [AUTH CONTROLLER] Starting logout process...');
  
  try {
    // Call logout API
    final result = await _authService.logout();
    
    print('🟡 [AUTH CONTROLLER] Logout API response: $result');
    
    if (result['code'] == 200) {
      print('🟢 [AUTH CONTROLLER] Logout API successful');
    } else {
      print('🔴 [AUTH CONTROLLER] Logout API failed - Code: ${result['code']}');
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
```

### **3. ProfilePage Logout Button**
```dart
ListTile(
  leading: const Icon(Icons.logout),
  title: const Text('Logout'),
  onTap: () async {
    // Show loading dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    
    try {
      // Call logout API
      await authController.logout();
      
      // Close loading dialog
      Get.back();
      
      // Navigate to login page
      Get.offAllNamed('/login');
      
      // Show success message
      Get.snackbar(
        'Logout Berhasil',
        'Anda telah berhasil logout',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Close loading dialog
      Get.back();
      
      // Show error message
      Get.snackbar(
        'Logout Gagal',
        'Terjadi kesalahan saat logout: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  },
),
```

## 🔍 **Debug Output:**

### **Successful Logout:**
```
🟡 [AUTH CONTROLLER] Starting logout process...
🔵 [AUTH SERVICE] ===== LOGOUT REQUEST =====
🔵 [AUTH SERVICE] URL: https://andidigital.andipublisher.com/api/auth/logout
🔵 [AUTH SERVICE] Method: POST
🔵 [AUTH SERVICE] Headers: {"Content-Type": "application/json"}
🔵 [AUTH SERVICE] Sending logout request to backend...
🔵 [AUTH SERVICE] ===== LOGOUT RESPONSE =====
🔵 [AUTH SERVICE] Status Code: 200
🔵 [AUTH SERVICE] Response Body: {"code":200,"message":"Logout successful","errors":null,"content":null}
🟢 [AUTH SERVICE] Logout successful
🟡 [AUTH CONTROLLER] Logout API response: {code: 200, message: Logout successful, errors: null, content: null}
🟢 [AUTH CONTROLLER] Logout API successful
🟡 [AUTH CONTROLLER] Google Sign-Out successful
🟡 [AUTH CONTROLLER] Logout completed, all data cleared
```

### **Failed Logout:**
```
🟡 [AUTH CONTROLLER] Starting logout process...
🔵 [AUTH SERVICE] ===== LOGOUT REQUEST =====
🔵 [AUTH SERVICE] URL: https://andidigital.andipublisher.com/api/auth/logout
🔵 [AUTH SERVICE] Method: POST
🔵 [AUTH SERVICE] Headers: {"Content-Type": "application/json"}
🔵 [AUTH SERVICE] Sending logout request to backend...
🔵 [AUTH SERVICE] ===== LOGOUT RESPONSE =====
🔵 [AUTH SERVICE] Status Code: 401
🔵 [AUTH SERVICE] Response Body: {"code":401,"message":"Unauthorized","errors":"Invalid token","content":null}
🔴 [AUTH SERVICE] Logout failed - Status: 401
🟡 [AUTH CONTROLLER] Logout API response: {code: 401, message: Unauthorized, errors: Invalid token, content: null}
🔴 [AUTH CONTROLLER] Logout API failed - Code: 401
🔴 [AUTH CONTROLLER] Error message: Unauthorized
🟡 [AUTH CONTROLLER] Logout completed, all data cleared
```

## 🚨 **Error Handling:**

### **1. Network Error:**
- Jika API tidak bisa diakses, tetap lanjut dengan local logout
- Clear semua data lokal
- Sign out dari Google
- Tampilkan error message ke user

### **2. API Error (401/500):**
- Jika API mengembalikan error, tetap lanjut dengan local logout
- Clear semua data lokal
- Sign out dari Google
- Log error untuk debugging

### **3. Google Sign-Out Error:**
- Jika Google Sign-Out gagal, tetap lanjut dengan logout
- Clear semua data lokal
- Log error untuk debugging

## ✅ **What Gets Cleared:**

### **Local Storage:**
- `token` - JWT token
- `user` - User data
- `expires_at` - Token expiry
- `google_user` - Google user info

### **Google Sign-In:**
- Sign out dari Google account
- Revoke access jika perlu

### **Navigation:**
- Redirect ke login page
- Clear navigation stack

## 🎯 **User Experience:**

### **1. Loading State:**
- Tampilkan loading dialog saat proses logout
- User tidak bisa interaksi selama proses

### **2. Success State:**
- Tutup loading dialog
- Redirect ke login page
- Tampilkan success snackbar

### **3. Error State:**
- Tutup loading dialog
- Tampilkan error snackbar
- Tetap redirect ke login page

## 📱 **Testing:**

### **Test Cases:**
1. **Normal Logout**: User klik logout button
2. **Network Error**: Matikan internet, lalu logout
3. **API Error**: Backend return error
4. **Google Sign-Out Error**: Google service unavailable
5. **Token Expired**: Auto logout saat token habis

### **Expected Behavior:**
- Semua data lokal ter-clear
- User diarahkan ke login page
- Google account ter-sign out
- Loading dan feedback yang jelas
