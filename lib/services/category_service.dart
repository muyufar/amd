import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CategoryService {
  // Get Parent Categories
  Future<Map<String, dynamic>> getParentCategories({
    int offset = 0,
    int limit = 10,
  }) async {
    final url = Uri.parse(
      '${AppConfig.baseUrlApp}/ebook/category?offset=$offset&limit=$limit',
    );

    print('🔵 [CATEGORY SERVICE] Fetching parent categories from: $url');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      print('🔵 [CATEGORY SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [CATEGORY SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
            'Failed to fetch parent categories: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔴 [CATEGORY SERVICE] Error fetching parent categories: $e');
      rethrow;
    }
  }

  // Get Child Categories
  Future<Map<String, dynamic>> getChildCategories({
    required String idParent,
    int offset = 0,
    int limit = 10,
  }) async {
    final url = Uri.parse(
      '${AppConfig.baseUrlApp}/ebook/category/child?idParent=$idParent&offset=$offset&limit=$limit',
    );

    print('🔵 [CATEGORY SERVICE] Fetching child categories from: $url');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      print('🔵 [CATEGORY SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [CATEGORY SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
            'Failed to fetch child categories: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔴 [CATEGORY SERVICE] Error fetching child categories: $e');
      rethrow;
    }
  }
}
