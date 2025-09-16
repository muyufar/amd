import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../controllers/auth_controller.dart';
import 'package:get/get.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Method untuk membuat HTTP request dengan token
  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    final authController = AuthController.instance;
    final token = authController.getValidToken();

    if (token == null) {
      throw Exception('Token tidak valid atau telah habis');
    }

    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };

    print('🔵 [API SERVICE] GET Request: $url');
    print('🔵 [API SERVICE] Headers: $requestHeaders');

    try {
      final response = await http.get(url, headers: requestHeaders);

      print('🔵 [API SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [API SERVICE] Response Body: ${response.body}');

      // Cek jika response adalah 401 (Unauthorized), berarti token expired
      if (response.statusCode == 401) {
        print('🔴 [API SERVICE] Token expired (401), auto logout');
        authController.checkTokenAndLogoutIfExpired();
        throw Exception('Token telah habis, silakan login kembali');
      }

      return response;
    } catch (e) {
      print('🔴 [API SERVICE] Network Error: $e');
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final authController = AuthController.instance;
    final token = authController.getValidToken();

    if (token == null) {
      throw Exception('Token tidak valid atau telah habis');
    }

    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };

    print('🔵 [API SERVICE] POST Request: $url');
    print('🔵 [API SERVICE] Body: ${jsonEncode(body)}');
    print('🔵 [API SERVICE] Headers: $requestHeaders');

    try {
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );

      print('🔵 [API SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [API SERVICE] Response Body: ${response.body}');

      // Cek jika response adalah 401 (Unauthorized), berarti token expired
      if (response.statusCode == 401) {
        print('🔴 [API SERVICE] Token expired (401), auto logout');
        authController.checkTokenAndLogoutIfExpired();
        throw Exception('Token telah habis, silakan login kembali');
      }

      return response;
    } catch (e) {
      print('🔴 [API SERVICE] Network Error: $e');
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final authController = AuthController.instance;
    final token = authController.getValidToken();

    if (token == null) {
      throw Exception('Token tidak valid atau telah habis');
    }

    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };

    print('🔵 [API SERVICE] PUT Request: $url');
    print('🔵 [API SERVICE] Body: ${jsonEncode(body)}');
    print('🔵 [API SERVICE] Headers: $requestHeaders');

    try {
      final response = await http.put(
        url,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );

      print('🔵 [API SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [API SERVICE] Response Body: ${response.body}');

      // Cek jika response adalah 401 (Unauthorized), berarti token expired
      if (response.statusCode == 401) {
        print('🔴 [API SERVICE] Token expired (401), auto logout');
        authController.checkTokenAndLogoutIfExpired();
        throw Exception('Token telah habis, silakan login kembali');
      }

      return response;
    } catch (e) {
      print('🔴 [API SERVICE] Network Error: $e');
      rethrow;
    }
  }

  Future<http.Response> delete(String endpoint,
      {Map<String, String>? headers}) async {
    final authController = AuthController.instance;
    final token = authController.getValidToken();

    if (token == null) {
      throw Exception('Token tidak valid atau telah habis');
    }

    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };

    print('🔵 [API SERVICE] DELETE Request: $url');
    print('🔵 [API SERVICE] Headers: $requestHeaders');

    try {
      final response = await http.delete(url, headers: requestHeaders);

      print('🔵 [API SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [API SERVICE] Response Body: ${response.body}');

      // Cek jika response adalah 401 (Unauthorized), berarti token expired
      if (response.statusCode == 401) {
        print('🔴 [API SERVICE] Token expired (401), auto logout');
        authController.checkTokenAndLogoutIfExpired();
        throw Exception('Token telah habis, silakan login kembali');
      }

      return response;
    } catch (e) {
      print('🔴 [API SERVICE] Network Error: $e');
      rethrow;
    }
  }
}
