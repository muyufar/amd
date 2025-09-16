import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../controllers/auth_controller.dart';
import '../models/cart_model.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // Method untuk membuat HTTP request dengan token untuk dev endpoints
  Future<http.Response> _request(String method, String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final authController = AuthController.instance;
    final token = authController.getValidToken();

    if (token == null) {
      throw Exception('Token tidak valid atau telah habis');
    }

    final url = Uri.parse('${AppConfig.baseUrlApp}$endpoint');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };

    print('🔵 [CART SERVICE] $method Request: $url');
    if (body != null) {
      print('🔵 [CART SERVICE] Body: ${jsonEncode(body)}');
    }
    print('🔵 [CART SERVICE] Headers: $requestHeaders');

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('🔵 [CART SERVICE] Response Status: ${response.statusCode}');
      print('🔵 [CART SERVICE] Response Body: ${response.body}');

      // Cek jika response adalah 401 (Unauthorized), berarti token expired
      if (response.statusCode == 401) {
        print('🔴 [CART SERVICE] Token expired (401), auto logout');
        authController.checkTokenAndLogoutIfExpired();
        throw Exception('Token telah habis, silakan login kembali');
      }

      return response;
    } catch (e) {
      print('🔴 [CART SERVICE] Network Error: $e');
      rethrow;
    }
  }

  // Add item to cart
  Future<Map<String, dynamic>?> addToCart({
    required String idEbook,
    String? ref,
  }) async {
    try {
      final body = {
        'id_ebook': idEbook,
        if (ref != null) 'ref': ref,
      };

      final response = await _request('POST', '/Cart/add', body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to add item to cart');
      }
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  // Get cart items
  Future<List<CartBook>> getCartItems() async {
    try {
      final response = await _request('GET', '/Cart');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔵 [CART SERVICE] Full response: $data');

        if (data['status'] == true && data['data'] != null) {
          // Check if data is a Map or List
          if (data['data'] is Map<String, dynamic>) {
            // If it's a Map, look for a list inside it
            final Map<String, dynamic> dataMap = data['data'];
            print('🔵 [CART SERVICE] Data map keys: ${dataMap.keys.toList()}');

            if (dataMap.containsKey('barang') && dataMap['barang'] is List) {
              final List<dynamic> barangList = dataMap['barang'];
              print(
                  '🔵 [CART SERVICE] Found barang list with ${barangList.length} items');

              // Handle nested array structure
              List<dynamic> items = [];
              for (var item in barangList) {
                if (item is List) {
                  items.addAll(item);
                } else {
                  items.add(item);
                }
              }

              print('🔵 [CART SERVICE] Flattened items count: ${items.length}');
              try {
                return items.map((item) {
                  print('🔵 [CART SERVICE] Parsing item: $item');
                  // Fix image URL if it's relative
                  if (item['gambar1'] != null &&
                      !item['gambar1'].toString().startsWith('http')) {
                    item['gambar1'] =
                        'https://andidigital.andipublisher.com/storage/${item['gambar1']}';
                  }
                  return CartBook.fromJson(item);
                }).toList();
              } catch (e) {
                print('🔴 [CART SERVICE] Error parsing barang: $e');
                return [];
              }
            } else if (dataMap.containsKey('items') &&
                dataMap['items'] is List) {
              final List<dynamic> items = dataMap['items'];
              print(
                  '🔵 [CART SERVICE] Found items list with ${items.length} items');
              try {
                return items.map((item) {
                  print('🔵 [CART SERVICE] Parsing item: $item');
                  return CartBook.fromJson(item);
                }).toList();
              } catch (e) {
                print('🔴 [CART SERVICE] Error parsing items: $e');
                return [];
              }
            } else if (dataMap.containsKey('data_checkout') &&
                dataMap['data_checkout'] is List) {
              final List<dynamic> items = dataMap['data_checkout'];
              print(
                  '🔵 [CART SERVICE] Found data_checkout list with ${items.length} items');
              try {
                return items.map((item) {
                  print('🔵 [CART SERVICE] Parsing item: $item');
                  return CartBook.fromJson(item);
                }).toList();
              } catch (e) {
                print('🔴 [CART SERVICE] Error parsing data_checkout: $e');
                return [];
              }
            } else {
              // If no list found in the map, return empty list
              print(
                  '🔴 [CART SERVICE] No items list found in response data. Available keys: ${dataMap.keys.toList()}');
              return [];
            }
          } else if (data['data'] is List) {
            // If it's already a List, use it directly
            final List<dynamic> items = data['data'];
            print(
                '🔵 [CART SERVICE] Data is already a list with ${items.length} items');
            try {
              return items.map((item) {
                print('🔵 [CART SERVICE] Parsing item: $item');
                return CartBook.fromJson(item);
              }).toList();
            } catch (e) {
              print('🔴 [CART SERVICE] Error parsing list items: $e');
              return [];
            }
          } else {
            print(
                '🔴 [CART SERVICE] Unexpected data type: ${data['data'].runtimeType}');
            return [];
          }
        }
        return [];
      } else {
        throw Exception('Failed to get cart items');
      }
    } catch (e) {
      print('Error getting cart items: $e');
      rethrow;
    }
  }

  // Remove item from cart
  Future<Map<String, dynamic>?> removeFromCart(String idBarang) async {
    try {
      print('🔵 [CART SERVICE] Removing cart item with ID: $idBarang');
      final response = await _request('DELETE', '/Cart/delete/$idBarang');

      print('🔵 [CART SERVICE] Delete response status: ${response.statusCode}');
      print('🔵 [CART SERVICE] Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        print('🔴 [CART SERVICE] Delete error: $errorData');
        throw Exception(
            'Failed to remove item from cart: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error removing from cart: $e');
      rethrow;
    }
  }

  // Checkout cart
  Future<CartCheckout?> checkoutCart(List<String> ebookIds) async {
    try {
      final body = {
        'id': ebookIds,
      };

      print('🔵 [CART SERVICE] Checkout cart with body: $body');
      final response =
          await _request('POST', '/transaction/checkout/cart', body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return CartCheckout.fromJson(data['data']);
        }
        throw Exception(data['message'] ?? 'Checkout failed');
      } else {
        throw Exception('Failed to checkout cart');
      }
    } catch (e) {
      print('Error checking out cart: $e');
      rethrow;
    }
  }

  // Pay with Midtrans
  Future<Map<String, dynamic>?> payWithMidtrans(List<String> ebookIds,
      {bool usePoinUser = false, String? voucherCode}) async {
    try {
      final body = {
        'user': {
          'usePoinUser': usePoinUser,
        },
        'dataCheckout': [
          {
            'products': ebookIds
                .map((id) => {
                      'idProduct': id,
                      'isBuy': true,
                    })
                .toList(),
          }
        ],
      };

      // Add voucher code if provided
      if (voucherCode != null && voucherCode.isNotEmpty) {
        body['voucherCode'] = voucherCode;
      }

      print('🔵 [CART SERVICE] Pay with Midtrans with body: $body');
      final response =
          await _request('POST', '/transaction/ebook/cart', body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return data['data'];
        }
        throw Exception(data['message'] ?? 'Payment failed');
      } else {
        throw Exception('Failed to process payment');
      }
    } catch (e) {
      print('Error processing payment: $e');
      rethrow;
    }
  }
}
