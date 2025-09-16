import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';

class BookService {
  final box = GetStorage();

  Future<List<Map<String, dynamic>>> fetchBukuTerbaru({
    int limit = 10,
    int offset = 0,
  }) async {
    final url = Uri.parse(
      '${AppConfig.baseUrlApp}/ebook/list?tag=terbaru&limit=$limit&offset=$offset',
    );

    print('🔵 [BOOK SERVICE] Fetching buku terbaru from: $url');

    try {
      // Public endpoint: jangan kirim Authorization agar tetap bisa diakses tanpa login
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      print('🔵 [BOOK SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [BOOK SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] != null && data['data']['value'] != null
            ? List<Map<String, dynamic>>.from(data['data']['value'])
            : [];
      } else {
        throw Exception(
            'Failed to fetch buku terbaru: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔴 [BOOK SERVICE] Error fetching buku terbaru: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchBukuTerlaris(
      {int limit = 10, int offset = 0}) async {
    final url = Uri.parse(
        '${AppConfig.baseUrlApp}/ebook/list?tag=terlaris&limit=$limit&offset=$offset');

    print('🔵 [BOOK SERVICE] Fetching buku terlaris from: $url');

    try {
      // Public endpoint: jangan kirim Authorization agar tetap bisa diakses tanpa login
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      print('🔵 [BOOK SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [BOOK SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] != null && data['data']['value'] != null
            ? List<Map<String, dynamic>>.from(data['data']['value'])
            : [];
      } else {
        throw Exception(
            'Failed to fetch buku terlaris: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔴 [BOOK SERVICE] Error fetching buku terlaris: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchDetailBuku(String slug) async {
    final token = box.read('token');
    final url = Uri.parse('${AppConfig.baseUrlApp}/ebook/$slug');

    // Debug: print URL dan token
    print('🔵 [BOOK SERVICE] Fetching detail buku from: $url');
    print(
        '🔵 [BOOK SERVICE] Token: ${token != null ? (token is String && token.length > 20 ? token.substring(0, 20) : token.toString()) : 'null'}');

    try {
      // Kirim Authorization hanya jika token tersedia
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null && token.toString().isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(url, headers: headers);

      // Debug: print response
      print('🔵 [BOOK SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [BOOK SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Data tidak ditemukan');
        }
      } else if (response.statusCode == 401) {
        // Token kadaluwarsa: trigger auto redirect dan jangan tampilkan error text
        AuthController.instance.checkTokenAndLogoutIfExpired();
        return null;
      } else {
        throw Exception(
            'Failed to fetch detail buku: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔴 [BOOK SERVICE] Error fetching detail buku: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchBukuOwned() async {
    final token = box.read('token');
    final url = Uri.parse('${AppConfig.baseUrlApp}/ebook/owned');

    print('🔵 [BOOK SERVICE] Fetching buku owned from: $url');
    print(
        '🔵 [BOOK SERVICE] Token: ${token != null ? (token is String && token.length > 20 ? token.substring(0, 20) : token.toString()) : 'null'}');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      print('🔵 [BOOK SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [BOOK SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          return [];
        }
      } else if (response.statusCode == 401) {
        // Token kadaluwarsa, redirect ke login dan kembalikan list kosong
        AuthController.instance.checkTokenAndLogoutIfExpired();
        return [];
      } else {
        throw Exception(
            'Failed to fetch buku owned: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔴 [BOOK SERVICE] Error fetching buku owned: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createReview({
    required String idEbook,
    required int rating,
    String? description,
    required int isHide,
  }) async {
    final token = GetStorage().read('token');
    final url = Uri.parse('${AppConfig.baseUrlApp}/review/create');
    final body = {
      'idEbook': idEbook,
      'rating': rating,
      'description': description,
      'isHide': isHide,
    };

    print('🔵 [BOOK SERVICE] Creating review at: $url');
    print('🔵 [BOOK SERVICE] Review body: ${jsonEncode(body)}');
    print(
        '🔵 [BOOK SERVICE] Token: ${token != null ? (token is String && token.length > 20 ? token.substring(0, 20) : token.toString()) : 'null'}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('🔵 [BOOK SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [BOOK SERVICE] Response Body: ${response.body}');

      // Selalu return hasil jsonDecode response.body, tanpa throw Exception
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {
          'status': false,
          'message': 'Gagal mengirim review',
          'data': null
        };
      }
    } catch (e) {
      print('🔴 [BOOK SERVICE] Error creating review: $e');
      return {
        'status': false,
        'message': 'Gagal mengirim review: $e',
        'data': null
      };
    }
  }

  // TODO: Implementasi fetch buku, detail buku, dsb
}
