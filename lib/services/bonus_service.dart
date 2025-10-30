import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';

class BonusService {
  static const String _baseUrl = AppConfig.baseUrlApp;

  // Claim bonus with code
  static Future<Map<String, dynamic>?> claimBonus(String code) async {
    try {
      // Read token from local storage
      final box = GetStorage();
      final String? token = box.read('token');

      if (token == null || token.isEmpty) {
        return {
          'status': false,
          'message': 'Silakan login terlebih dahulu untuk klaim bonus.',
          'data': null,
        };
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/bonus/claim'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'codes': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print(
            '🔴 [BONUS SERVICE] Failed to claim bonus: ${response.statusCode}');
        return {
          'status': false,
          'message': response.statusCode == 401
              ? 'Sesi berakhir. Silakan login ulang.'
              : 'Gagal mengklaim bonus. Silakan coba lagi.',
          'data': null
        };
      }
    } catch (e) {
      print('🔴 [BONUS SERVICE] Error claiming bonus: $e');
      return {
        'status': false,
        'message': 'Terjadi kesalahan. Periksa koneksi internet Anda.',
        'data': null
      };
    }
  }
}
