import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../controllers/auth_controller.dart';

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  // Search books with filters
  Future<Map<String, dynamic>> searchBooks({
    required String keyword,
    int limit = 20,
    int offset = 0,
    String? sortBy,
    String? kategori,
    List<String>? penulis,
    String? penerbit,
    int? hargaMin,
  }) async {
    try {
      final authController = AuthController.instance;
      final url = Uri.parse('${AppConfig.baseUrl}/dev/ebook/search');
      final headers = {
        'Content-Type': 'application/json',
      };

      final body = {
        'keyword': keyword,
        'limit': limit,
        'offset': offset,
        if (sortBy != null) 'sortBy': sortBy,
        if (kategori != null) 'kategori': kategori,
        if (penulis != null && penulis.isNotEmpty) 'penulis': penulis,
        if (penerbit != null) 'penerbit': penerbit,
        if (hargaMin != null) 'hargaMin': hargaMin,
      };

      print('🔵 [SEARCH SERVICE] Search Request: $url');
      print('🔵 [SEARCH SERVICE] Body: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('🔵 [SEARCH SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [SEARCH SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 401) {
        print('🔴 [SEARCH SERVICE] Token expired (401), auto logout');
        authController.checkTokenAndLogoutIfExpired();
        throw Exception('Token telah habis, silakan login kembali');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Ensure we return a Map<String, dynamic>
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        } else {
          print('🔴 [SEARCH SERVICE] Unexpected response type: ${decoded.runtimeType}');
          return {'status': false, 'message': 'Invalid response format'};
        }
      } else {
        throw Exception('Gagal melakukan pencarian: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 [SEARCH SERVICE] Search Error: $e');
      rethrow;
    }
  }

  // Get search filters
  Future<Map<String, dynamic>> getSearchFilters({
    required String keyword,
    int limit = 20,
    int offset = 0,
    String? sortBy,
    String? kategori,
    List<String>? penulis,
    String? penerbit,
    int? hargaMin,
  }) async {
    try {
      final authController = AuthController.instance;
      final url = Uri.parse('${AppConfig.baseUrl}/dev/ebook/search/filters');
      final headers = {
        'Content-Type': 'application/json',
      };

      final body = {
        'keyword': keyword,
        'limit': limit,
        'offset': offset,
        if (sortBy != null) 'sortBy': sortBy,
        if (kategori != null) 'kategori': kategori,
        if (penulis != null && penulis.isNotEmpty) 'penulis': penulis,
        if (penerbit != null) 'penerbit': penerbit,
        if (hargaMin != null) 'hargaMin': hargaMin,
      };

      print('🔵 [SEARCH SERVICE] Filters Request: $url');
      print('🔵 [SEARCH SERVICE] Body: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print(
          '🔵 [SEARCH SERVICE] Filters Response Status: ${response.statusCode}');
      print('🔵 [SEARCH SERVICE] Filters Response Body: ${response.body}');

      if (response.statusCode == 401) {
        print('🔴 [SEARCH SERVICE] Token expired (401), auto logout');
        authController.checkTokenAndLogoutIfExpired();
        throw Exception('Token telah habis, silakan login kembali');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Ensure we return a Map<String, dynamic>
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        } else {
          print('🔴 [SEARCH SERVICE] Unexpected filters response type: ${decoded.runtimeType}');
          return {'status': false, 'message': 'Invalid response format'};
        }
      } else {
        throw Exception(
            'Gagal mengambil filter pencarian: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 [SEARCH SERVICE] Filters Error: $e');
      rethrow;
    }
  }
}
