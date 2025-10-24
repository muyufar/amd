import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionController extends GetxController {
  final TransactionService _service = TransactionService();

  // Global loading state
  var isLoading = false.obs;
  var error = ''.obs;

  // Individual loading states for each tab
  var isLoadingBelumDibayar = false.obs;
  var isLoadingSelesai = false.obs;
  var isLoadingKadaluwarsa = false.obs;
  var isLoadingDibatalkan = false.obs;

  // Individual error states
  var errorBelumDibayar = ''.obs;
  var errorSelesai = ''.obs;
  var errorKadaluwarsa = ''.obs;
  var errorDibatalkan = ''.obs;

  var belumDibayarList = <TransactionHistoryModel>[].obs;
  var selesaiList = <TransactionHistoryModel>[].obs;
  var kadaluwarsaList = <TransactionHistoryModel>[].obs;
  var dibatalkanList = <TransactionHistoryModel>[].obs;

  // Retry mechanism
  var retryCount = 0.obs;
  final int maxRetries = 3;

  Future<void> fetchBelumDibayar({bool isRetry = false}) async {
    if (!isRetry) {
      isLoadingBelumDibayar.value = true;
      errorBelumDibayar.value = '';
    }

    try {
      print('🔄 [TRANSACTION CONTROLLER] Fetching belum dibayar...');
      final result = await _service.fetchTransactionHistory(tag: 1);
      belumDibayarList.value = result;
      errorBelumDibayar.value = '';
      retryCount.value = 0; // Reset retry count on success
      print(
          '✅ [TRANSACTION CONTROLLER] Belum dibayar loaded: ${result.length} items');
    } catch (e) {
      print('🔴 [TRANSACTION CONTROLLER] Error fetching belum dibayar: $e');
      errorBelumDibayar.value = e.toString();

      // Retry mechanism
      if (retryCount.value < maxRetries) {
        retryCount.value++;
        print(
            '🔄 [TRANSACTION CONTROLLER] Retrying... (${retryCount.value}/$maxRetries)');
        await Future.delayed(
            Duration(seconds: retryCount.value * 2)); // Exponential backoff
        await fetchBelumDibayar(isRetry: true);
      }
    } finally {
      isLoadingBelumDibayar.value = false;
    }
  }

  Future<void> fetchSelesai({bool isRetry = false}) async {
    if (!isRetry) {
      isLoadingSelesai.value = true;
      errorSelesai.value = '';
    }

    try {
      print('🔄 [TRANSACTION CONTROLLER] Fetching selesai...');
      final result = await _service.fetchTransactionHistory(tag: 3);
      selesaiList.value = result;
      errorSelesai.value = '';
      print(
          '✅ [TRANSACTION CONTROLLER] Selesai loaded: ${result.length} items');
    } catch (e) {
      print('🔴 [TRANSACTION CONTROLLER] Error fetching selesai: $e');
      errorSelesai.value = e.toString();

      // Retry mechanism
      if (retryCount.value < maxRetries) {
        retryCount.value++;
        print(
            '🔄 [TRANSACTION CONTROLLER] Retrying selesai... (${retryCount.value}/$maxRetries)');
        await Future.delayed(Duration(seconds: retryCount.value * 2));
        await fetchSelesai(isRetry: true);
      }
    } finally {
      isLoadingSelesai.value = false;
    }
  }

  Future<void> fetchKadaluwarsa({bool isRetry = false}) async {
    if (!isRetry) {
      isLoadingKadaluwarsa.value = true;
      errorKadaluwarsa.value = '';
    }

    try {
      print('🔄 [TRANSACTION CONTROLLER] Fetching kadaluwarsa...');
      final result = await _service.fetchTransactionHistory(tag: 4);
      kadaluwarsaList.value = result;
      errorKadaluwarsa.value = '';
      print(
          '✅ [TRANSACTION CONTROLLER] Kadaluwarsa loaded: ${result.length} items');
    } catch (e) {
      print('🔴 [TRANSACTION CONTROLLER] Error fetching kadaluwarsa: $e');
      errorKadaluwarsa.value = e.toString();

      // Retry mechanism
      if (retryCount.value < maxRetries) {
        retryCount.value++;
        print(
            '🔄 [TRANSACTION CONTROLLER] Retrying kadaluwarsa... (${retryCount.value}/$maxRetries)');
        await Future.delayed(Duration(seconds: retryCount.value * 2));
        await fetchKadaluwarsa(isRetry: true);
      }
    } finally {
      isLoadingKadaluwarsa.value = false;
    }
  }

  Future<void> fetchDibatalkan({bool isRetry = false}) async {
    if (!isRetry) {
      isLoadingDibatalkan.value = true;
      errorDibatalkan.value = '';
    }

    try {
      print('🔄 [TRANSACTION CONTROLLER] Fetching dibatalkan...');
      final result = await _service.fetchTransactionHistory(tag: 5);
      dibatalkanList.value = result;
      errorDibatalkan.value = '';
      print(
          '✅ [TRANSACTION CONTROLLER] Dibatalkan loaded: ${result.length} items');
    } catch (e) {
      print('🔴 [TRANSACTION CONTROLLER] Error fetching dibatalkan: $e');
      errorDibatalkan.value = e.toString();

      // Retry mechanism
      if (retryCount.value < maxRetries) {
        retryCount.value++;
        print(
            '🔄 [TRANSACTION CONTROLLER] Retrying dibatalkan... (${retryCount.value}/$maxRetries)');
        await Future.delayed(Duration(seconds: retryCount.value * 2));
        await fetchDibatalkan(isRetry: true);
      }
    } finally {
      isLoadingDibatalkan.value = false;
    }
  }

  Future<void> fetchTransactions() async {
    print('🔄 [TRANSACTION CONTROLLER] Fetching all transactions...');
    isLoading.value = true;
    error.value = '';

    try {
      await Future.wait([
        fetchBelumDibayar(),
        fetchSelesai(),
        fetchKadaluwarsa(),
        fetchDibatalkan(),
      ]);
      print('✅ [TRANSACTION CONTROLLER] All transactions loaded successfully');
    } catch (e) {
      print('🔴 [TRANSACTION CONTROLLER] Error fetching transactions: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Manual refresh method
  Future<void> refreshTransactions() async {
    print('🔄 [TRANSACTION CONTROLLER] Manual refresh triggered');
    retryCount.value = 0; // Reset retry count
    await fetchTransactions();
  }

  // Individual refresh methods
  Future<void> refreshBelumDibayar() async {
    print('🔄 [TRANSACTION CONTROLLER] Refreshing belum dibayar...');
    retryCount.value = 0;
    await fetchBelumDibayar();
  }

  Future<void> refreshSelesai() async {
    print('🔄 [TRANSACTION CONTROLLER] Refreshing selesai...');
    retryCount.value = 0;
    await fetchSelesai();
  }

  Future<void> refreshKadaluwarsa() async {
    print('🔄 [TRANSACTION CONTROLLER] Refreshing kadaluwarsa...');
    retryCount.value = 0;
    await fetchKadaluwarsa();
  }

  Future<void> refreshDibatalkan() async {
    print('🔄 [TRANSACTION CONTROLLER] Refreshing dibatalkan...');
    retryCount.value = 0;
    await fetchDibatalkan();
  }

  @override
  void onInit() {
    super.onInit();
    print('🔄 [TRANSACTION CONTROLLER] Initializing...');
    fetchTransactions();
  }
}
