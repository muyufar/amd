import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class PublisherService {
  static const String _baseUrl = AppConfig.baseUrlApp;

  // Get list of publishers
  Future<Map<String, dynamic>> getPublishers({
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      print('🔍 [PUBLISHER SERVICE] Fetching publishers...');

      final url = Uri.parse('$_baseUrl/ebook/penerbit');
      print('🔍 [PUBLISHER SERVICE] API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 [PUBLISHER SERVICE] Response status: ${response.statusCode}');
      print('🔍 [PUBLISHER SERVICE] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == true && result['data'] != null) {
          print('✅ [PUBLISHER SERVICE] Publishers loaded successfully');
          final data = result['data'];
          
          // Handle new format: data is Map with list and total
          if (data is Map<String, dynamic>) {
            return data;
          } 
          // Handle old format: data is directly a List
          else if (data is List) {
            return {
              'list': data,
              'total': data.length,
            };
          }
          // Fallback: wrap in Map
          else {
            return {
              'list': [],
              'total': 0,
            };
          }
        } else {
          throw Exception(result['message'] ?? 'Gagal mengambil data penerbit');
        }
      } else {
        throw Exception('Failed to fetch publishers: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 [PUBLISHER SERVICE] Error: $e');
      rethrow;
    }
  }

  // Get imprints for a publisher
  Future<Map<String, dynamic>> getImprints(String publisherId) async {
    try {
      print(
          '🔍 [PUBLISHER SERVICE] Fetching imprints for publisher: $publisherId');

      final url = Uri.parse('$_baseUrl/ebook/imprint?idPublisher=$publisherId');
      print('🔍 [PUBLISHER SERVICE] API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 [PUBLISHER SERVICE] Response status: ${response.statusCode}');
      print('🔍 [PUBLISHER SERVICE] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == true && result['data'] != null) {
          print('✅ [PUBLISHER SERVICE] Imprints loaded successfully');
          final data = result['data'];
          
          // Handle new format: data is Map with list and total
          if (data is Map<String, dynamic>) {
            return data;
          } 
          // Handle old format: data is directly a List
          else if (data is List) {
            return {
              'list': data,
              'total': data.length,
            };
          }
          // Fallback: wrap in Map
          else {
            return {
              'list': [],
              'total': 0,
            };
          }
        } else {
          throw Exception(result['message'] ?? 'Gagal mengambil data imprint');
        }
      } else {
        throw Exception('Failed to fetch imprints: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 [PUBLISHER SERVICE] Error: $e');
      rethrow;
    }
  }

  // Get books by imprint
  Future<Map<String, dynamic>> getBooksByImprint({
    required String imprintId,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      print('🔍 [PUBLISHER SERVICE] Fetching books for imprint: $imprintId');

      final url = Uri.parse(
          '$_baseUrl/ebook/list?tag=imprint&idTag=$imprintId&offset=$offset&limit=$limit');
      print('🔍 [PUBLISHER SERVICE] API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 [PUBLISHER SERVICE] Response status: ${response.statusCode}');
      print('🔍 [PUBLISHER SERVICE] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == true && result['data'] != null) {
          print('✅ [PUBLISHER SERVICE] Books loaded successfully');
          return result['data'];
        } else {
          throw Exception(result['message'] ?? 'Gagal mengambil data buku');
        }
      } else {
        throw Exception('Failed to fetch books: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 [PUBLISHER SERVICE] Error: $e');
      rethrow;
    }
  }
}
