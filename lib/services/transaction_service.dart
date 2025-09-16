import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:get_storage/get_storage.dart';
import '../models/transaction_model.dart';
import '../controllers/auth_controller.dart';

class TransactionService {
  final box = GetStorage();

  Future<Map<String, dynamic>> checkout(String idBarang) async {
    final token = box.read('token');
    final url = Uri.parse('${AppConfig.baseUrlApp}/transaction/checkout');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id': idBarang}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true && data['data'] != null) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Checkout gagal');
      }
    } else {
      throw Exception('Failed to checkout: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> transaksi(Map<String, dynamic> body) async {
    final token = box.read('token');
    final url = Uri.parse('${AppConfig.baseUrlApp}/transaction/ebook');
    print('🔵 [TRANSACTION SERVICE] POST $url');
    print(
        '🔵 [TRANSACTION SERVICE] Headers: {Authorization: Bearer $token, Accept: application/json, Content-Type: application/json}');
    print('🔵 [TRANSACTION SERVICE] Body: $body');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('🔵 [TRANSACTION SERVICE] Status: ${response.statusCode}');
    print('🔵 [TRANSACTION SERVICE] Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true && data['data'] != null) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Transaksi gagal');
      }
    } else {
      throw Exception('Failed to transaksi: ${response.statusCode}');
    }
  }

  Future<List<TransactionHistoryModel>> fetchTransactionHistory(
      {int offset = 0, int limit = 10, required int tag}) async {
    final token = box.read('token');
    final url = Uri.parse(
        '${AppConfig.baseUrlApp}/transaction/history/ebook?offset=$offset&limit=$limit&tag=$tag');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => TransactionHistoryModel.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } else if (response.statusCode == 401) {
      // Token expired → trigger handler, return empty list to avoid error text
      AuthController.instance.checkTokenAndLogoutIfExpired();
      return [];
    } else {
      throw Exception(
          'Failed to fetch transaction history: ${response.statusCode}');
    }
  }
}
