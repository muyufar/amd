import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';
import '../models/book_model.dart';

class BookService {
  final box = GetStorage();

  Future<Map<String, dynamic>> fetchBukuTerbaru({
    int page = 1,
  }) async {
    final url = Uri.parse(
      '${AppConfig.baseUrlApp}/ebook/list?tag=terbaru&page=$page',
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
        if (data['status'] == true && data['data'] != null) {
          // New API format: data is directly an array
          final bookList = data['data'];
          
          // Check if data is an array (new format) or object with pagination (old format)
          if (bookList is List) {
            // New format: data is directly an array
            final books = List<Map<String, dynamic>>.from(bookList);
            // Assume no more pages if returned list is empty or less than expected
            // You can adjust this logic based on your API's behavior
            final hasMore = books.isNotEmpty && books.length >= 20; // Adjust threshold as needed
            
            return {
              'data': books,
              'current_page': page,
              'last_page': hasMore ? page + 1 : page,
              'next_page_url': hasMore ? 'page=${page + 1}' : null,
              'has_more': hasMore,
            };
          } else if (bookList is Map<String, dynamic>) {
            // Old format: data contains pagination info
            final paginationData = bookList;
            return {
              'data': List<Map<String, dynamic>>.from(paginationData['data'] ?? []),
              'current_page': paginationData['current_page'] ?? page,
              'last_page': paginationData['last_page'] ?? page,
              'next_page_url': paginationData['next_page_url'],
              'has_more': paginationData['next_page_url'] != null,
            };
          } else {
            return {
              'data': [],
              'current_page': page,
              'last_page': page,
              'next_page_url': null,
              'has_more': false,
            };
          }
        } else {
          return {
            'data': [],
            'current_page': page,
            'last_page': page,
            'next_page_url': null,
            'has_more': false,
          };
        }
      } else {
        throw Exception(
            'Failed to fetch buku terbaru: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔴 [BOOK SERVICE] Error fetching buku terbaru: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchBukuTerlaris({
    int page = 1,
  }) async {
    final url = Uri.parse(
        '${AppConfig.baseUrlApp}/ebook/list?tag=terlaris&page=$page');

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
        if (data['status'] == true && data['data'] != null) {
          // New API format: data is directly an array
          final bookList = data['data'];
          
          // Check if data is an array (new format) or object with pagination (old format)
          if (bookList is List) {
            // New format: data is directly an array
            final books = List<Map<String, dynamic>>.from(bookList);
            // Assume no more pages if returned list is empty or less than expected
            // You can adjust this logic based on your API's behavior
            final hasMore = books.isNotEmpty && books.length >= 20; // Adjust threshold as needed
            
            return {
              'data': books,
              'current_page': page,
              'last_page': hasMore ? page + 1 : page,
              'next_page_url': hasMore ? 'page=${page + 1}' : null,
              'has_more': hasMore,
            };
          } else if (bookList is Map<String, dynamic>) {
            // Old format: data contains pagination info
            final paginationData = bookList;
            return {
              'data': List<Map<String, dynamic>>.from(paginationData['data'] ?? []),
              'current_page': paginationData['current_page'] ?? page,
              'last_page': paginationData['last_page'] ?? page,
              'next_page_url': paginationData['next_page_url'],
              'has_more': paginationData['next_page_url'] != null,
            };
          } else {
            return {
              'data': [],
              'current_page': page,
              'last_page': page,
              'next_page_url': null,
              'has_more': false,
            };
          }
        } else {
          return {
            'data': [],
            'current_page': page,
            'last_page': page,
            'next_page_url': null,
            'has_more': false,
          };
        }
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
          final result = data['data'] as Map<String, dynamic>;
          // Debug: Print preview data
          print(
              '🔍 [BOOK SERVICE] file_ebook_preview in API response: ${result['file_ebook_preview']}');
          print(
              '🔍 [BOOK SERVICE] file_ebook_preview type: ${result['file_ebook_preview'].runtimeType}');
          print(
              '🔍 [BOOK SERVICE] file_ebook_preview isEmpty: ${result['file_ebook_preview']?.toString().isEmpty}');

          // Parse menggunakan BookModel untuk validasi
          try {
            final bookModel = BookModel.fromJson(result);
            print('🔍 [BOOK SERVICE] BookModel parsed successfully');
            print(
                '🔍 [BOOK SERVICE] BookModel fileEbookPreview: ${bookModel.fileEbookPreview}');
            return result; // Tetap return raw data untuk kompatibilitas
          } catch (e) {
            print('🔴 [BOOK SERVICE] Error parsing BookModel: $e');
            return result; // Tetap return raw data jika parsing gagal
          }
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

  Future<Map<String, dynamic>> fetchReviewList(String idEbook) async {
    final url =
        Uri.parse('${AppConfig.baseUrlApp}/review/list?idEbook=$idEbook');

    print('🔵 [BOOK SERVICE] Fetching review list from: $url');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      print('🔵 [BOOK SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [BOOK SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          return {'totals': '0.0', 'jumlah': 0, 'list': []};
        }
      } else {
        throw Exception(
            'Failed to fetch review list: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔴 [BOOK SERVICE] Error fetching review list: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchBonusBooks() async {
    final token = box.read('token');
    final url = Uri.parse('${AppConfig.baseUrlApp}/ebook/bonus');

    print('🔵 [BOOK SERVICE] Fetching bonus books from: $url');

    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      if (token != null && token.toString().isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);

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
        AuthController.instance.checkTokenAndLogoutIfExpired();
        return [];
      } else {
        throw Exception(
            'Failed to fetch bonus books: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔴 [BOOK SERVICE] Error fetching bonus books: $e');
      rethrow;
    }
  }
}
