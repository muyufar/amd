import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthService {
  // TODO: Implementasi login, logout, register

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${AppConfig.baseUrl}/auth/login');
    final body = {'email': email, 'password': password};

    print('🔵 [AUTH SERVICE] Login URL: $url');
    print('🔵 [AUTH SERVICE] Login Body: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('🔵 [AUTH SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [AUTH SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('🔵 [AUTH SERVICE] Login Success: $result');
        return result;
      } else {
        print(
            '🔴 [AUTH SERVICE] Login Failed - Status: ${response.statusCode}');
        print('🔴 [AUTH SERVICE] Login Failed - Body: ${response.body}');

        // Try to parse error response
        try {
          final errorResponse = jsonDecode(response.body);
          return errorResponse;
        } catch (e) {
          print('🔴 [AUTH SERVICE] Failed to parse error response: $e');
          throw Exception(
              'Failed to login: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('🔴 [AUTH SERVICE] Network Error: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String namaUser,
    String? usernameUser,
    required String emailUser,
    required String teleponUser,
    required String passwordUser,
    required String confirmPasswordUser,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/auth/register');
    final body = {
      'nama_user': namaUser,
      'email_user': emailUser,
      'telepon_user': teleponUser,
      'password_user': passwordUser,
      'confirm_password_user': confirmPasswordUser,
    };
    if (usernameUser != null) {
      body['username_user'] = usernameUser;
    }

    print('🔵 [AUTH SERVICE] Register URL: $url');
    print('🔵 [AUTH SERVICE] Register Body: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('🔵 [AUTH SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [AUTH SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        print('🔵 [AUTH SERVICE] Register Success: $result');
        return result;
      } else {
        print(
            '🔴 [AUTH SERVICE] Register Failed - Status: ${response.statusCode}');
        print('🔴 [AUTH SERVICE] Register Failed - Body: ${response.body}');

        // Try to parse error response
        try {
          final errorResponse = jsonDecode(response.body);
          return errorResponse;
        } catch (e) {
          print('🔴 [AUTH SERVICE] Failed to parse error response: $e');
          throw Exception(
              'Failed to register: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('🔴 [AUTH SERVICE] Network Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Google SSO login
  Future<Map<String, dynamic>> googleLogin({required String idToken}) async {
    final url = Uri.parse('${AppConfig.baseUrl}/auth/google-login');
    final body = {'id_token': idToken};

    print('🔵 [AUTH SERVICE] ===== GOOGLE LOGIN REQUEST =====');
    print('🔵 [AUTH SERVICE] URL: $url');
    print('🔵 [AUTH SERVICE] Method: POST');
    print('🔵 [AUTH SERVICE] Headers: {"Content-Type": "application/json"}');
    print('🔵 [AUTH SERVICE] Body: ${jsonEncode(body)}');
    print('🔵 [AUTH SERVICE] ID Token length: ${idToken.length} characters');
    print('🔵 [AUTH SERVICE] ID Token preview: ${idToken.substring(0, 50)}...');

    try {
      print('🔵 [AUTH SERVICE] Sending request to backend...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('🔵 [AUTH SERVICE] ===== BACKEND RESPONSE =====');
      print('🔵 [AUTH SERVICE] Status Code: ${response.statusCode}');
      print('🔵 [AUTH SERVICE] Response Headers: ${response.headers}');
      print('🔵 [AUTH SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('🟢 [AUTH SERVICE] Backend responded with 200 OK');
        final result = jsonDecode(response.body);
        print('🟢 [AUTH SERVICE] Parsed response: $result');
        return result;
      } else {
        print(
            '🔴 [AUTH SERVICE] Backend responded with error status: ${response.statusCode}');
        try {
          final errorResult = jsonDecode(response.body);
          print('🔴 [AUTH SERVICE] Error response: $errorResult');
          return errorResult;
        } catch (e) {
          print('🔴 [AUTH SERVICE] Failed to parse error response: $e');
          throw Exception(
              'Failed to google login: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('🔴 [AUTH SERVICE] ===== NETWORK ERROR =====');
      print('🔴 [AUTH SERVICE] Network Error: $e');
      print('🔴 [AUTH SERVICE] Error type: ${e.runtimeType}');
      throw Exception('Network error: $e');
    }
  }

  // Logout API
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
      print('🔵 [AUTH SERVICE] Response Headers: ${response.headers}');
      print('🔵 [AUTH SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('🟢 [AUTH SERVICE] Logout successful');
        final result = jsonDecode(response.body);
        print('🟢 [AUTH SERVICE] Parsed response: $result');
        return result;
      } else {
        print(
            '🔴 [AUTH SERVICE] Logout failed - Status: ${response.statusCode}');
        try {
          final errorResult = jsonDecode(response.body);
          print('🔴 [AUTH SERVICE] Error response: $errorResult');
          return errorResult;
        } catch (e) {
          print('🔴 [AUTH SERVICE] Failed to parse error response: $e');
          throw Exception(
              'Failed to logout: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('🔴 [AUTH SERVICE] ===== LOGOUT NETWORK ERROR =====');
      print('🔴 [AUTH SERVICE] Network Error: $e');
      print('🔴 [AUTH SERVICE] Error type: ${e.runtimeType}');
      throw Exception('Network error: $e');
    }
  }
}
