# Debug Guide untuk Google Sign-In

## 🔍 **Debug Output yang Diharapkan (SUCCESS):**

### **1. Saat User Klik Tombol Google Sign-In:**

```
🟡 [AUTH CONTROLLER] Starting Google login...
🟡 [AUTH CONTROLLER] Web Client ID: 1053029938463-ob4b97o2mr6qgl58mpkciu94b6uot9hv.apps.googleusercontent.com
🟡 [AUTH CONTROLLER] Starting Google Sign-In...
```

### **2. Saat Google Sign-In Popup Muncul:**

```
🟡 [AUTH CONTROLLER] Google account obtained: user@example.com
🟡 [AUTH CONTROLLER] Display Name: User Name
🟡 [AUTH CONTROLLER] Photo URL: https://lh3.googleusercontent.com/a/...
🟡 [AUTH CONTROLLER] Google User ID: 123456789012345678901
```

### **3. Saat Mendapat Authentication:**

```
🟡 [AUTH CONTROLLER] Processing Google authentication...
🟡 [AUTH CONTROLLER] Google User Email: user@example.com
🟡 [AUTH CONTROLLER] Google User Display Name: User Name
🟡 [AUTH CONTROLLER] Google User Photo URL: https://lh3.googleusercontent.com/a/...
🟡 [AUTH CONTROLLER] Google User ID: 123456789012345678901
🟡 [AUTH CONTROLLER] Getting Google authentication...
🟡 [AUTH CONTROLLER] Google authentication obtained successfully!
```

### **4. Debug ID Token (SUCCESS):**

```
🟡 [AUTH CONTROLLER] === ID TOKEN DEBUG ===
🟡 [AUTH CONTROLLER] ID Token exists: true
🟡 [AUTH CONTROLLER] ID Token length: 1234 characters
🟡 [AUTH CONTROLLER] ID Token starts with: eyJhbGciOiJSUzI1NiIs...
🟡 [AUTH CONTROLLER] ID Token ends with: ...XVCJ9.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIn0
```

### **5. Debug Access Token:**

```
🟡 [AUTH CONTROLLER] === ACCESS TOKEN DEBUG ===
🟡 [AUTH CONTROLLER] Access Token exists: true
🟡 [AUTH CONTROLLER] Access Token length: 567 characters
🟡 [AUTH CONTROLLER] Access Token starts with: ya29.a0AfH6SMC...
```

### **6. Debug Server Auth Code:**

```
🟡 [AUTH CONTROLLER] === SERVER AUTH CODE DEBUG ===
🟡 [AUTH CONTROLLER] Server Auth Code exists: true
🟡 [AUTH CONTROLLER] Server Auth Code length: 89 characters
🟡 [AUTH CONTROLLER] Server Auth Code: 4/0AfJohXn...
```

### **7. ID Token Success:**

```
🟢 [AUTH CONTROLLER] ===== ID TOKEN SUCCESS =====
🟢 [AUTH CONTROLLER] Google ID Token obtained successfully!
🟢 [AUTH CONTROLLER] Token length: 1234 characters
🟢 [AUTH CONTROLLER] Token preview: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXVkIjoiMTA1MzAyOTkzODQ2My1vYjRiOTdvMm1yNnFnbDU4bXBrY2l1OTRiNnVvdGh2LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTIzNDU2Nzg5MDEyMzQ1Njc4OTAiLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6IkV4YW1wbGVIYXNoIiwiYXV0aF90aW1lIjoxNjM0NTY3ODkwLCJub25jZSI6IkV4YW1wbGVOb25jZSJ9...
🟢 [AUTH CONTROLLER] Calling backend with ID token...
```

### **8. Request ke Backend:**

```
🔵 [AUTH SERVICE] ===== GOOGLE LOGIN REQUEST =====
🔵 [AUTH SERVICE] URL: https://andidigital.andipublisher.com/api/auth/google-login
🔵 [AUTH SERVICE] Method: POST
🔵 [AUTH SERVICE] Headers: {"Content-Type": "application/json"}
🔵 [AUTH SERVICE] Body: {"id_token":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXVkIjoiMTA1MzAyOTkzODQ2My1vYjRiOTdvMm1yNnFnbDU4bXBrY2l1OTRiNnVvdGh2LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTIzNDU2Nzg5MDEyMzQ1Njc4OTAiLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6IkV4YW1wbGVIYXNoIiwiYXV0aF90aW1lIjoxNjM0NTY3ODkwLCJub25jZSI6IkV4YW1wbGVOb25jZSJ9..."}
🔵 [AUTH SERVICE] ID Token length: 1234 characters
🔵 [AUTH SERVICE] ID Token preview: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXVkIjoiMTA1MzAyOTkzODQ2My1vYjRiOTdvMm1yNnFnbDU4bXBrY2l1OTRiNnVvdGh2LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTIzNDU2Nzg5MDEyMzQ1Njc4OTAiLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6IkV4YW1wbGVIYXNoIiwiYXV0aF90aW1lIjoxNjM0NTY3ODkwLCJub25jZSI6IkV4YW1wbGVOb25jZSJ9...
🔵 [AUTH SERVICE] Sending request to backend...
```

### **9. Response dari Backend (SUCCESS):**

```
🔵 [AUTH SERVICE] ===== BACKEND RESPONSE =====
🔵 [AUTH SERVICE] Status Code: 200
🔵 [AUTH SERVICE] Response Headers: {content-type: application/json, ...}
🔵 [AUTH SERVICE] Response Body: {"code":200,"message":"Login successful","content":{"access_token":"your_app_jwt_token_here","user":{"id":123,"email":"user@example.com","name":"User Name"},"expires_at":"2024-01-01T12:00:00Z"}}
🟢 [AUTH SERVICE] Backend responded with 200 OK
🟢 [AUTH SERVICE] Parsed response: {code: 200, message: Login successful, content: {access_token: your_app_jwt_token_here, user: {id: 123, email: user@example.com, name: User Name}, expires_at: 2024-01-01T12:00:00Z}}
```

### **10. Final Success:**

```
🟢 [AUTH CONTROLLER] ===== BACKEND SUCCESS =====
🟢 [AUTH CONTROLLER] Backend login successful!
🟢 [AUTH CONTROLLER] Response code: 200
🟢 [AUTH CONTROLLER] Response message: Login successful
🟢 [AUTH CONTROLLER] User data received: {id: 123, email: user@example.com, name: User Name}
🟢 [AUTH CONTROLLER] User data stored successfully!
🟢 [AUTH CONTROLLER] Navigating to home page...
🟡 [AUTH CONTROLLER] Google login process completed
```

## 🔴 **Debug Output untuk Error:**

### **1. ID Token NULL Error:**

```
🔴 [AUTH CONTROLLER] ===== ID TOKEN ERROR =====
🔴 [AUTH CONTROLLER] Google ID Token is NULL!
🔴 [AUTH CONTROLLER] This usually means:
🔴 [AUTH CONTROLLER] 1. SHA fingerprint not registered in Google Cloud
🔴 [AUTH CONTROLLER] 2. Package name mismatch
🔴 [AUTH CONTROLLER] 3. Web Client ID is incorrect
🔴 [AUTH CONTROLLER] 4. Testing on emulator instead of physical device
```

### **2. Backend Error:**

```
🔴 [AUTH CONTROLLER] ===== BACKEND ERROR =====
🔴 [AUTH CONTROLLER] Backend login failed - Code: 400
🔴 [AUTH CONTROLLER] Error message: Invalid ID token
🔴 [AUTH CONTROLLER] Full response: {code: 400, message: Invalid ID token}
```

### **3. Network Error:**

```
🔴 [AUTH SERVICE] ===== NETWORK ERROR =====
🔴 [AUTH SERVICE] Network Error: SocketException: Failed host lookup: 'andidigital.andipublisher.com'
🔴 [AUTH SERVICE] Error type: SocketException
```

## 📋 **Checklist Debug:**

### **✅ Jika ID Token Berhasil:**

- [ ] `ID Token exists: true`
- [ ] `ID Token length: > 1000 characters`
- [ ] `ID Token starts with: eyJhbGciOiJSUzI1NiIs...`
- [ ] `Access Token exists: true`
- [ ] `Server Auth Code exists: true`

### **❌ Jika ID Token Gagal:**

- [ ] `ID Token exists: false`
- [ ] `ID Token is NULL!`
- [ ] Cek SHA fingerprint di Google Cloud
- [ ] Cek package name
- [ ] Cek Web Client ID
- [ ] Test di device fisik

## 🚨 **Troubleshooting:**

### **Jika ID Token NULL:**

1. **SHA Fingerprint**: Pastikan SHA-1 sudah terdaftar di Google Cloud Console
2. **Package Name**: Pastikan `com.andi.digital.andi_digital` sesuai
3. **Web Client ID**: Pastikan `AppConfig.googleWebClientId` benar
4. **Device**: Test di device fisik, bukan emulator

### **Jika Backend Error:**

1. **Format Request**: Pastikan `{"id_token": "token"}` benar
2. **URL**: Pastikan `https://andidigital.andipublisher.com/api/auth/google-login` benar
3. **Backend**: Pastikan endpoint sudah siap menerima request

### **Jika Network Error:**

1. **Internet**: Cek koneksi internet
2. **DNS**: Cek apakah domain bisa diakses
3. **Firewall**: Cek firewall settings

## 🎯 **Expected ID Token Format:**

ID Token yang berhasil biasanya:

- **Length**: 1000-2000 characters
- **Format**: JWT (JSON Web Token)
- **Structure**: `header.payload.signature`
- **Starts with**: `eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9`

## 📱 **Testing Steps:**

1. **Run aplikasi**: `flutter run --debug`
2. **Klik tombol Google Sign-In**
3. **Pilih akun Google**
4. **Monitor debug output**
5. **Cek apakah ID Token berhasil didapat**
6. **Cek apakah request ke backend berhasil**
7. **Cek apakah response dari backend success**

## 🔗 **Referensi:**

- [Google Sign-In Debug](https://developers.google.com/identity/sign-in/android/start)
- [JWT Token Format](https://jwt.io/)
- [Google Cloud Console](https://console.cloud.google.com/)
