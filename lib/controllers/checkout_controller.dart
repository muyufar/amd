import 'package:get/get.dart';
import '../services/transaction_service.dart';

class CheckoutController extends GetxController {
  final TransactionService _service = TransactionService();
  var isLoading = false.obs;
  var error = ''.obs;
  var checkoutData = Rxn<Map<String, dynamic>>();
  var transaksiData = Rxn<Map<String, dynamic>>();

  Future<void> fetchCheckout(String idBarang) async {
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _service.checkout(idBarang);
      checkoutData.value = data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> transaksi(Map<String, dynamic> body) async {
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _service.transaksi(body);
      transaksiData.value = data;
      return data;
    } catch (e) {
      error.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
