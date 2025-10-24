import 'package:get/get.dart';
import '../services/category_service.dart';
import '../services/category_books_service.dart';

class CategoryController extends GetxController {
  final CategoryService _categoryService = CategoryService();
  final CategoryBooksService _categoryBooksService = CategoryBooksService();

  // Observable variables
  var isLoading = false.obs;
  var error = ''.obs;
  var parentCategories = <Map<String, dynamic>>[].obs;
  var childCategories = <Map<String, dynamic>>[].obs;
  var categoryBooks = <Map<String, dynamic>>[].obs;
  var selectedParentId = ''.obs;
  var selectedParentName = ''.obs;
  var isLoadingBooks = false.obs;
  var hasMoreBooks = true.obs;
  var currentBookOffset = 0.obs;

  // Pagination
  var currentOffset = 0.obs;
  var hasMoreData = true.obs;
  var totalParentCategories = 0.obs;
  var totalChildCategories = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchParentCategories();
  }

  // Fetch Parent Categories
  Future<void> fetchParentCategories({bool refresh = false}) async {
    if (refresh) {
      currentOffset.value = 0;
      hasMoreData.value = true;
      parentCategories.clear();
    }

    if (!hasMoreData.value && !refresh) return;

    isLoading.value = true;
    error.value = '';

    try {
      final response = await _categoryService.getParentCategories(
        offset: currentOffset.value,
        limit: 10,
      );

      if (response['status'] == true && response['data'] != null) {
        final newCategories =
            List<Map<String, dynamic>>.from(response['data']['list'] ?? []);

        print(
            '🔄 [CATEGORY CONTROLLER] New categories received: ${newCategories.length}');
        print(
            '🔄 [CATEGORY CONTROLLER] API total: ${response['data']['total']}');
        print(
            '🔄 [CATEGORY CONTROLLER] Current offset: ${currentOffset.value}');

        if (refresh) {
          parentCategories.value = newCategories;
        } else {
          parentCategories.addAll(newCategories);
        }

        totalParentCategories.value = response['data']['total'] ?? 0;

        // Check if there are more data
        // If we received fewer items than requested, we've reached the end
        hasMoreData.value = newCategories.length >= 10;

        print(
            '🔄 [CATEGORY CONTROLLER] Total categories: ${totalParentCategories.value}');
        print(
            '🔄 [CATEGORY CONTROLLER] Current categories: ${parentCategories.length}');
        print('🔄 [CATEGORY CONTROLLER] Has more data: ${hasMoreData.value}');

        currentOffset.value += 1;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      error.value = e.toString();
      print('🔴 [CATEGORY CONTROLLER] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch Child Categories and Books
  Future<void> fetchChildCategories(String parentId, String parentName) async {
    selectedParentId.value = parentId;
    selectedParentName.value = parentName;

    isLoading.value = true;
    error.value = '';
    childCategories.clear();
    categoryBooks.clear();

    try {
      // Fetch child categories and books simultaneously
      final futures = await Future.wait([
        _categoryService.getChildCategories(
            idParent: parentId, offset: 0, limit: 10),
        _categoryBooksService.getBooksByCategory(
            idKategori: parentId, offset: 0, limit: 20),
      ]);

      final childResponse = futures[0];
      final booksResponse = futures[1];

      // Handle child categories
      if (childResponse['code'] == 200 && childResponse['content'] != null) {
        childCategories.value = List<Map<String, dynamic>>.from(
            childResponse['content']['list'] ?? []);
        totalChildCategories.value = childResponse['content']['total'] ?? 0;
      }

      // Handle books
      if (booksResponse['status'] == true && booksResponse['data'] != null) {
        categoryBooks.value = List<Map<String, dynamic>>.from(
            booksResponse['data']['value'] ?? []);
        hasMoreBooks.value =
            (booksResponse['data']['value']?.length ?? 0) >= 20;
        currentBookOffset.value = 1;
      }

      print(
          '🔄 [CATEGORY CONTROLLER] Child categories: ${childCategories.length}');
      print('🔄 [CATEGORY CONTROLLER] Books: ${categoryBooks.length}');
    } catch (e) {
      error.value = e.toString();
      print('🔴 [CATEGORY CONTROLLER] Error fetching child categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more parent categories
  Future<void> loadMoreParentCategories() async {
    print('🔄 [CATEGORY CONTROLLER] loadMoreParentCategories called');
    print('🔄 [CATEGORY CONTROLLER] isLoading: ${isLoading.value}');
    print('🔄 [CATEGORY CONTROLLER] hasMoreData: ${hasMoreData.value}');
    print('🔄 [CATEGORY CONTROLLER] currentOffset: ${currentOffset.value}');

    if (!isLoading.value && hasMoreData.value) {
      print('🔄 [CATEGORY CONTROLLER] Calling fetchParentCategories...');
      await fetchParentCategories();
    } else {
      print('🔄 [CATEGORY CONTROLLER] Skipping load more - conditions not met');
    }
  }

  // Reset to parent categories
  // Load more books
  Future<void> loadMoreBooks() async {
    if (!isLoadingBooks.value &&
        hasMoreBooks.value &&
        selectedParentId.value.isNotEmpty) {
      isLoadingBooks.value = true;

      try {
        final response = await _categoryBooksService.getBooksByCategory(
          idKategori: selectedParentId.value,
          offset: currentBookOffset.value,
          limit: 20,
        );

        if (response['status'] == true && response['data'] != null) {
          final newBooks =
              List<Map<String, dynamic>>.from(response['data']['value'] ?? []);
          categoryBooks.addAll(newBooks);
          hasMoreBooks.value = newBooks.length >= 20;
          currentBookOffset.value += 1;
        }
      } catch (e) {
        print('🔴 [CATEGORY CONTROLLER] Error loading more books: $e');
      } finally {
        isLoadingBooks.value = false;
      }
    }
  }

  void resetToParentCategories() {
    selectedParentId.value = '';
    selectedParentName.value = '';
    childCategories.clear();
    categoryBooks.clear();
    hasMoreBooks.value = true;
    currentBookOffset.value = 0;
  }

  // Check if currently showing child categories
  bool get isShowingChildCategories => selectedParentId.value.isNotEmpty;
}
