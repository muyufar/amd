import 'package:get/get.dart';
import '../services/category_books_service.dart';

class CategoryBooksController extends GetxController {
  final CategoryBooksService _categoryBooksService = CategoryBooksService();

  // State variables
  var isLoading = false.obs;
  var error = ''.obs;
  var books = <Map<String, dynamic>>[].obs;
  var hasMoreData = true.obs;
  var currentOffset = 0.obs;
  var categoryName = ''.obs;
  var categoryId = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  // Fetch books by category
  Future<void> fetchBooksByCategory({
    required String idKategori,
    required String namaKategori,
    bool refresh = false,
  }) async {
    if (refresh) {
      currentOffset.value = 0;
      hasMoreData.value = true;
      books.clear();
      categoryId.value = idKategori;
      categoryName.value = namaKategori;
    }

    if (!hasMoreData.value && !refresh) return;

    isLoading.value = true;
    error.value = '';

    try {
      final response = await _categoryBooksService.getBooksByCategory(
        idKategori: idKategori,
        offset: currentOffset.value,
        limit: 20,
      );

      if (response['status'] == true && response['data'] != null) {
        final newBooks =
            List<Map<String, dynamic>>.from(response['data']['value'] ?? []);

        print(
            '🔄 [CATEGORY BOOKS CONTROLLER] New books received: ${newBooks.length}');
        print(
            '🔄 [CATEGORY BOOKS CONTROLLER] Current offset: ${currentOffset.value}');

        if (refresh) {
          books.value = newBooks;
        } else {
          books.addAll(newBooks);
        }

        // Check if there are more data
        hasMoreData.value = newBooks.length >= 20;

        print('🔄 [CATEGORY BOOKS CONTROLLER] Total books: ${books.length}');
        print(
            '🔄 [CATEGORY BOOKS CONTROLLER] Has more data: ${hasMoreData.value}');

        currentOffset.value += 1;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch books');
      }
    } catch (e) {
      error.value = e.toString();
      print('🔴 [CATEGORY BOOKS CONTROLLER] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more books
  Future<void> loadMoreBooks() async {
    if (!isLoading.value && hasMoreData.value && categoryId.value.isNotEmpty) {
      await fetchBooksByCategory(
        idKategori: categoryId.value,
        namaKategori: categoryName.value,
      );
    }
  }

  // Reset controller
  void reset() {
    books.clear();
    hasMoreData.value = true;
    currentOffset.value = 0;
    categoryId.value = '';
    categoryName.value = '';
    error.value = '';
    isLoading.value = false;
  }
}
