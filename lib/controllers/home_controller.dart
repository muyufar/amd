import 'package:get/get.dart';
import '../services/book_service.dart';
import '../controllers/auth_controller.dart';

class HomeController extends GetxController {
  final BookService _bookService = BookService();
  var bukuTerbaru = [].obs;
  var bukuTerlaris = [].obs;
  var isLoadingTerbaru = false.obs;
  var isLoadingTerlaris = false.obs;
  var errorTerbaru = ''.obs;
  var errorTerlaris = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Clear error state terlebih dahulu
    errorTerbaru.value = '';
    errorTerlaris.value = '';

    // Mulai pengecekan token secara berkala (dengan error handling)
    try {
      final authController = AuthController.instance;
      authController.startTokenCheck();
    } catch (e) {
      print('🔴 [HOME CONTROLLER] Error ge  tting AuthController: $e');
    }

    fetchBukuTerbaru();
    fetchBukuTerlaris();
  }

  // Method untuk clear error state
  void clearErrors() {
    errorTerbaru.value = '';
    errorTerlaris.value = '';
  }

  void fetchBukuTerbaru() async {
    isLoadingTerbaru.value = true;
    errorTerbaru.value = '';
    try {
      print('🔵 [HOME CONTROLLER] Fetching buku terbaru...');
      final data = await _bookService.fetchBukuTerbaru();
      bukuTerbaru.value = data;
      print('🟢 [HOME CONTROLLER] Buku terbaru loaded: ${data.length} items');
    } catch (e) {
      print('🔴 [HOME CONTROLLER] Error fetching buku terbaru: $e');
      errorTerbaru.value = e.toString();
    } finally {
      isLoadingTerbaru.value = false;
    }
  }

  void fetchBukuTerlaris() async {
    isLoadingTerlaris.value = true;
    errorTerlaris.value = '';
    try {
      print('🔵 [HOME CONTROLLER] Fetching buku terlaris...');
      final data = await _bookService.fetchBukuTerlaris();
      bukuTerlaris.value = data;
      print('🟢 [HOME CONTROLLER] Buku terlaris loaded: ${data.length} items');
    } catch (e) {
      print('🔴 [HOME CONTROLLER] Error fetching buku terlaris: $e');
      errorTerlaris.value = e.toString();
    } finally {
      isLoadingTerlaris.value = false;
    }
  }

  // Method untuk refresh data setelah login ulang
  void refreshData() {
    print('🟡 [HOME CONTROLLER] Refreshing data after login...');
    fetchBukuTerbaru();
    fetchBukuTerlaris();
  }
}
