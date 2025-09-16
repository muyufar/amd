import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:get_storage/get_storage.dart';

class WishlistService {
  final box = GetStorage();

  Future<List<Map<String, dynamic>>> fetchWishlist() async {
    final token = box.read('token');
    // Jika belum login, anggap wishlist kosong
    if (token == null || token.toString().isEmpty) {
      return [];
    }

    final url = Uri.parse('${AppConfig.baseUrlApp}/wishlist/');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Bentuk data bisa bervariasi: {data: {list: [...]}} atau {data: [...]}
      if (data is Map<String, dynamic>) {
        final rawData = data['data'];
        List<dynamic> list = const [];
        if (rawData is Map<String, dynamic> && rawData['list'] is List) {
          list = rawData['list'] as List;
        } else if (rawData is List) {
          list = rawData;
        } else if (rawData is Map<String, dynamic> &&
            rawData['value'] is List) {
          list = rawData['value'] as List;
        }
        // Kembalikan hanya item Map agar aman
        return list.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Token tidak valid/expired: treat as empty wishlist agar UI tetap tampil normal
      return [];
    } else {
      throw Exception('Failed to fetch wishlist: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addToWishlist(String idEbook) async {
    final token = box.read('token');
    final url = Uri.parse('${AppConfig.baseUrlApp}/wishlist/set');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id_ebook': idEbook}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add to wishlist');
    }
  }

  Future<Map<String, dynamic>> removeFromWishlist(String idEbook) async {
    final token = box.read('token');
    final url = Uri.parse('${AppConfig.baseUrlApp}/wishlist/delete');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id_ebook': idEbook}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to remove from wishlist');
    }
  }
}
