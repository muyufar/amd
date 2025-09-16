import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionController extends GetxController {
  final TransactionService _service = TransactionService();

  var isLoading = false.obs;
  var error = ''.obs;

  var belumDibayarList = <TransactionHistoryModel>[].obs;
  var selesaiList = <TransactionHistoryModel>[].obs;
  var dibatalkanList = <TransactionHistoryModel>[].obs;

  Future<void> fetchBelumDibayar() async {
    isLoading.value = true;
    error.value = '';
    try {
      belumDibayarList.value = await _service.fetchTransactionHistory(tag: 1);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSelesai() async {
    isLoading.value = true;
    error.value = '';
    try {
      selesaiList.value = await _service.fetchTransactionHistory(tag: 3);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDibatalkan() async {
    isLoading.value = true;
    error.value = '';
    try {
      dibatalkanList.value = await _service.fetchTransactionHistory(tag: 4);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchBelumDibayar();
    fetchSelesai();
    fetchDibatalkan();
  }
}
