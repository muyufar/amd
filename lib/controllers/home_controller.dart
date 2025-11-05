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
  final int limitPerPage = 20;
  
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
      final offset = (currentPageTerbaru.value - 1) * limitPerPage;
      print('🔵 [HOME CONTROLLER] Fetching buku terbaru... page: ${currentPageTerbaru.value}, offset: $offset');
      final data = await _bookService.fetchBukuTerbaru(
        limit: limitPerPage,
        offset: offset,
      );
      
      if (reset) {
        bukuTerbaru.value = data;
      } else {
        bukuTerbaru.addAll(data);
      }
      
      hasMoreTerbaru.value = data.length >= limitPerPage;
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
      final offset = (currentPageTerlaris.value - 1) * limitPerPage;
      print('🔵 [HOME CONTROLLER] Fetching buku terlaris... page: ${currentPageTerlaris.value}, offset: $offset');
      final data = await _bookService.fetchBukuTerlaris(
        limit: limitPerPage,
        offset: offset,
      );
      
      if (reset) {
        bukuTerlaris.value = List<Map<String, dynamic>>.from(data);
      } else {
        bukuTerlaris.addAll(List<Map<String, dynamic>>.from(data));
      }
      
      hasMoreTerlaris.value = data.length >= limitPerPage;
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
      final offset = (currentPageTerbaru.value - 1) * limitPerPage;
      print('🔵 [HOME CONTROLLER] Loading more buku terbaru... page: ${currentPageTerbaru.value}, offset: $offset');
      final data = await _bookService.fetchBukuTerbaru(
        limit: limitPerPage,
        offset: offset,
      );
      
      bukuTerbaru.addAll(data);
      hasMoreTerbaru.value = data.length >= limitPerPage;
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
      final offset = (currentPageTerlaris.value - 1) * limitPerPage;
      print('🔵 [HOME CONTROLLER] Loading more buku terlaris... page: ${currentPageTerlaris.value}, offset: $offset');
      final data = await _bookService.fetchBukuTerlaris(
        limit: limitPerPage,
        offset: offset,
      );
      
      bukuTerlaris.addAll(List<Map<String, dynamic>>.from(data));
      hasMoreTerlaris.value = data.length >= limitPerPage;
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
