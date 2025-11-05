import 'package:get/get.dart';
import '../services/publisher_service.dart';

class ImprintBooksController extends GetxController {
  final PublisherService _service = PublisherService();

  var isLoading = false.obs;
  var error = ''.obs;
  var books = <Map<String, dynamic>>[].obs;
  
  // Pagination
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;
  final int limitPerPage = 20;

  // Fetch books for imprint
  Future<void> fetchBooks(String imprintId, {bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      hasMore.value = true;
      books.clear();
    }

    if (!hasMore.value && !reset) return;

    // Prevent multiple simultaneous calls
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final offset = (currentPage.value - 1) * limitPerPage;
      final result = await _service.getBooksByImprint(
        imprintId: imprintId,
        offset: offset,
        limit: limitPerPage,
      );

      final newBooks = List<Map<String, dynamic>>.from(result['value'] ?? []);

      books.value = newBooks;
      hasMore.value = newBooks.length >= limitPerPage;
    } catch (e) {
      error.value = e.toString();
      print('🔴 [IMPRINT BOOKS CONTROLLER] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more books
  Future<void> loadMoreBooks(String imprintId) async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) {
      return;
    }

    isLoadingMore.value = true;

    try {
      // Increment page BEFORE fetch to prevent duplicate calls
      currentPage.value++;
      final offset = (currentPage.value - 1) * limitPerPage;
      
      final result = await _service.getBooksByImprint(
        imprintId: imprintId,
        offset: offset,
        limit: limitPerPage,
      );

      final newBooks = List<Map<String, dynamic>>.from(result['value'] ?? []);
      
      // Check for duplicates before adding
      final existingSlugs = books.map((b) => b['slug_barang']).toSet();
      final uniqueNewBooks = newBooks.where((b) => 
        !existingSlugs.contains(b['slug_barang'])
      ).toList();
      
      books.addAll(uniqueNewBooks);
      hasMore.value = newBooks.length >= limitPerPage;
    } catch (e) {
      print('🔴 [IMPRINT BOOKS CONTROLLER] Error loading more books: $e');
      currentPage.value--; // Rollback on error
    } finally {
      isLoadingMore.value = false;
    }
  }
}

