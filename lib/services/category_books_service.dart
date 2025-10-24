import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CategoryBooksService {
  Future<Map<String, dynamic>> getBooksByCategory({
    required String idKategori,
    int offset = 0,
    int limit = 20,
  }) async {
    final url = Uri.parse(
        '${AppConfig.baseUrlApp}/ebook/list?tag=kategori&idTag=$idKategori&offset=$offset&limit=$limit');

    print('🔵 [CATEGORY BOOKS SERVICE] Fetching books from: $url');

    final response = await http.get(url);

    print(
        '🔵 [CATEGORY BOOKS SERVICE] Response Status: ${response.statusCode}');
    print('🔵 [CATEGORY BOOKS SERVICE] Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load books for category');
    }
  }
}
