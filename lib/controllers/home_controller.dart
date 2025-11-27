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
  
  // Pagination state untuk buku terbaru
  var currentPageTerbaru = 1.obs;
  var hasMoreTerbaru = true.obs;
  var isLoadingMoreTerbaru = false.obs;
  
  // Pagination state untuk buku terlaris
  var currentPageTerlaris = 1.obs;
  var hasMoreTerlaris = true.obs;
  var isLoadingMoreTerlaris = false.obs;

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

    fetchBukuTerbaru(reset: true);
    fetchBukuTerlaris(reset: true);
  }

  // Method untuk clear error state
  void clearErrors() {
    errorTerbaru.value = '';
    errorTerlaris.value = '';
  }

  void fetchBukuTerbaru({bool reset = false}) async {
    if (reset) {
      currentPageTerbaru.value = 1;
      hasMoreTerbaru.value = true;
      bukuTerbaru.clear();
    }
    
    isLoadingTerbaru.value = true;
    errorTerbaru.value = '';
    try {
      print('🔵 [HOME CONTROLLER] Fetching buku terbaru... page: ${currentPageTerbaru.value}');
      final response = await _bookService.fetchBukuTerbaru(
        page: currentPageTerbaru.value,
      );
      
      final List<Map<String, dynamic>> books = List<Map<String, dynamic>>.from(response['data'] ?? []);
      
      if (reset) {
        bukuTerbaru.value = books;
      } else {
        bukuTerbaru.addAll(books);
      }
      
      hasMoreTerbaru.value = response['has_more'] ?? false;
      print('🟢 [HOME CONTROLLER] Buku terbaru loaded: ${bukuTerbaru.length} items total, hasMore: ${hasMoreTerbaru.value}');
    } catch (e) {
      print('🔴 [HOME CONTROLLER] Error fetching buku terbaru: $e');
      errorTerbaru.value = e.toString();
    } finally {
      isLoadingTerbaru.value = false;
    }
  }

  void fetchBukuTerlaris({bool reset = false}) async {
    if (reset) {
      currentPageTerlaris.value = 1;
      hasMoreTerlaris.value = true;
      bukuTerlaris.clear();
    }
    
    isLoadingTerlaris.value = true;
    errorTerlaris.value = '';
    try {
      print('🔵 [HOME CONTROLLER] Fetching buku terlaris... page: ${currentPageTerlaris.value}');
      final response = await _bookService.fetchBukuTerlaris(
        page: currentPageTerlaris.value,
      );
      
      final List<Map<String, dynamic>> books = List<Map<String, dynamic>>.from(response['data'] ?? []);
      
      if (reset) {
        bukuTerlaris.value = books;
      } else {
        bukuTerlaris.addAll(books);
      }
      
      hasMoreTerlaris.value = response['has_more'] ?? false;
      print('🟢 [HOME CONTROLLER] Buku terlaris loaded: ${bukuTerlaris.length} items total, hasMore: ${hasMoreTerlaris.value}');
    } catch (e) {
      print('🔴 [HOME CONTROLLER] Error fetching buku terlaris: $e');
      errorTerlaris.value = e.toString();
    } finally {
      isLoadingTerlaris.value = false;
    }
  }

  Future<void> loadMoreBukuTerbaru() async {
    if (isLoadingMoreTerbaru.value || !hasMoreTerbaru.value) return;
    
    isLoadingMoreTerbaru.value = true;
    try {
      currentPageTerbaru.value++;
      print('🔵 [HOME CONTROLLER] Loading more buku terbaru... page: ${currentPageTerbaru.value}');
      final response = await _bookService.fetchBukuTerbaru(
        page: currentPageTerbaru.value,
      );
      
      final List<Map<String, dynamic>> books = List<Map<String, dynamic>>.from(response['data'] ?? []);
      bukuTerbaru.addAll(books);
      hasMoreTerbaru.value = response['has_more'] ?? false;
      print('🟢 [HOME CONTROLLER] More buku terbaru loaded: ${bukuTerbaru.length} items total, hasMore: ${hasMoreTerbaru.value}');
    } catch (e) {
      print('🔴 [HOME CONTROLLER] Error loading more buku terbaru: $e');
      currentPageTerbaru.value--; // Rollback page on error
    } finally {
      isLoadingMoreTerbaru.value = false;
    }
  }

  Future<void> loadMoreBukuTerlaris() async {
    if (isLoadingMoreTerlaris.value || !hasMoreTerlaris.value) return;
    
    isLoadingMoreTerlaris.value = true;
    try {
      currentPageTerlaris.value++;
      print('🔵 [HOME CONTROLLER] Loading more buku terlaris... page: ${currentPageTerlaris.value}');
      final response = await _bookService.fetchBukuTerlaris(
        page: currentPageTerlaris.value,
      );
      
      final List<Map<String, dynamic>> books = List<Map<String, dynamic>>.from(response['data'] ?? []);
      bukuTerlaris.addAll(books);
      hasMoreTerlaris.value = response['has_more'] ?? false;
      print('🟢 [HOME CONTROLLER] More buku terlaris loaded: ${bukuTerlaris.length} items total, hasMore: ${hasMoreTerlaris.value}');
    } catch (e) {
      print('🔴 [HOME CONTROLLER] Error loading more buku terlaris: $e');
      currentPageTerlaris.value--; // Rollback page on error
    } finally {
      isLoadingMoreTerlaris.value = false;
    }
  }

  // Method untuk refresh data setelah login ulang
  void refreshData() {
    print('🟡 [HOME CONTROLLER] Refreshing data after login...');
    fetchBukuTerbaru(reset: true);
    fetchBukuTerlaris(reset: true);
  }
}
