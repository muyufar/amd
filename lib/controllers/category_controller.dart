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

  // Pagination for parent categories
  var currentPageParent = 1.obs;
  var hasMoreData = true.obs;
  var totalParentCategories = 0.obs;
  final int limitPerPageParent = 10;
  
  // Pagination for books
  var currentPageBooks = 1.obs;
  var totalChildCategories = 0.obs;
  final int limitPerPageBooks = 20;

  @override
  void onInit() {
    super.onInit();
    fetchParentCategories(reset: true);
  }

  // Fetch Parent Categories
  Future<void> fetchParentCategories({bool reset = false}) async {
    if (reset) {
      currentPageParent.value = 1;
      hasMoreData.value = true;
      parentCategories.clear();
    }

    if (!hasMoreData.value && !reset) {
      print('🔄 [CATEGORY CONTROLLER] fetchParentCategories skipped - no more data');
      return;
    }

    // Set loading flag IMMEDIATELY to prevent multiple calls
    if (isLoading.value) {
      print('🔄 [CATEGORY CONTROLLER] fetchParentCategories skipped - already loading');
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final offset = (currentPageParent.value - 1) * limitPerPageParent;
      print(
          '🔄 [CATEGORY CONTROLLER] Fetching page: ${currentPageParent.value}, offset: $offset');
      
      final response = await _categoryService.getParentCategories(
        offset: offset,
        limit: limitPerPageParent,
      );

      if (response['status'] == true && response['data'] != null) {
        // Handle new format: data.list and data.total
        final data = response['data'];
        List<Map<String, dynamic>> newCategories = [];
        
        if (data is Map<String, dynamic>) {
          // New format: data.list contains the array
          if (data['list'] != null && data['list'] is List) {
            newCategories = List<Map<String, dynamic>>.from(data['list']);
          }
        } else if (data is List) {
          // Fallback: data is directly a list (old format)
          newCategories = List<Map<String, dynamic>>.from(data);
        }

        print(
            '🔄 [CATEGORY CONTROLLER] New categories received: ${newCategories.length}');
        print(
            '🔄 [CATEGORY CONTROLLER] API total: ${data is Map ? (data['total'] ?? 0) : newCategories.length}');
        print(
            '🔄 [CATEGORY CONTROLLER] Current list length before: ${parentCategories.length}');

        if (reset) {
          parentCategories.value = newCategories;
        } else {
          // Check for duplicates before adding
          final existingIds = parentCategories.map((c) => c['id_kategori']).toSet();
          final uniqueNewCategories = newCategories.where((c) => 
            !existingIds.contains(c['id_kategori'])
          ).toList();
          parentCategories.addAll(uniqueNewCategories);
          print(
              '🔄 [CATEGORY CONTROLLER] Added ${uniqueNewCategories.length} unique categories (${newCategories.length - uniqueNewCategories.length} duplicates skipped)');
        }

        // Get total from data.total (new format) or use list length as fallback
        if (data is Map<String, dynamic> && data['total'] != null) {
          totalParentCategories.value = data['total'] is int 
              ? data['total'] 
              : int.tryParse(data['total'].toString()) ?? newCategories.length;
        } else {
          totalParentCategories.value = newCategories.length;
        }

        // Check if there are more data
        hasMoreData.value = newCategories.length >= limitPerPageParent;

        print(
            '🔄 [CATEGORY CONTROLLER] Total categories: ${totalParentCategories.value}');
        print(
            '🔄 [CATEGORY CONTROLLER] Current categories: ${parentCategories.length}');
        print('🔄 [CATEGORY CONTROLLER] Has more data: ${hasMoreData.value}');
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      error.value = e.toString();
      print('🔴 [CATEGORY CONTROLLER] Error: $e');
      // Rollback page increment on error (only if not reset)
      if (!reset && currentPageParent.value > 1) {
        currentPageParent.value--;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch Child Categories and Books
  Future<void> fetchChildCategories(String parentId, String parentName, {bool reset = false}) async {
    if (reset) {
      currentPageBooks.value = 1;
      hasMoreBooks.value = true;
    }
    
    selectedParentId.value = parentId;
    selectedParentName.value = parentName;

    isLoading.value = true;
    error.value = '';
    
    if (reset) {
      childCategories.clear();
      categoryBooks.clear();
    }

    try {
      final offset = (currentPageBooks.value - 1) * limitPerPageBooks;
      
      // Fetch child categories and books simultaneously
      final futures = await Future.wait([
        _categoryService.getChildCategories(
            idParent: parentId, offset: 0, limit: 10),
        _categoryBooksService.getBooksByCategory(
            idKategori: parentId, offset: offset, limit: limitPerPageBooks),
      ]);

      final childResponse = futures[0];
      final booksResponse = futures[1];

      // Handle child categories (only fetch once, not paginated)
      if (reset && childResponse['code'] == 200 && childResponse['content'] != null) {
        childCategories.value = List<Map<String, dynamic>>.from(
            childResponse['content']['list'] ?? []);
        totalChildCategories.value = childResponse['content']['total'] ?? 0;
      }

      // Handle books
      if (booksResponse['status'] == true && booksResponse['data'] != null) {
        final newBooks = List<Map<String, dynamic>>.from(
            booksResponse['data']['value'] ?? []);
        
        if (reset) {
          categoryBooks.value = newBooks;
        } else {
          // Check for duplicates before adding
          final existingSlugs = categoryBooks.map((b) => b['slug_barang']).toSet();
          final uniqueNewBooks = newBooks.where((b) => 
            !existingSlugs.contains(b['slug_barang'])
          ).toList();
          categoryBooks.addAll(uniqueNewBooks);
          print(
              '🔄 [CATEGORY CONTROLLER] Added ${uniqueNewBooks.length} unique books (${newBooks.length - uniqueNewBooks.length} duplicates skipped)');
        }
        hasMoreBooks.value = newBooks.length >= limitPerPageBooks;
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

  // Load more parent categories (for infinite scroll)
  Future<void> loadMoreParentCategories() async {
    // Prevent multiple simultaneous calls
    if (isLoading.value || !hasMoreData.value) {
      print('🔄 [CATEGORY CONTROLLER] loadMoreParentCategories skipped - isLoading: ${isLoading.value}, hasMoreData: ${hasMoreData.value}');
      return;
    }

    // Increment page BEFORE fetch to prevent duplicate calls
    currentPageParent.value++;
    print('🔄 [CATEGORY CONTROLLER] loadMoreParentCategories - page incremented to: ${currentPageParent.value}');
    await fetchParentCategories();
  }

  // Load more books (for infinite scroll)
  Future<void> loadMoreBooks() async {
    if (isLoadingBooks.value || !hasMoreBooks.value || selectedParentId.value.isEmpty) {
      return;
    }

    isLoadingBooks.value = true;

    try {
      currentPageBooks.value++;
      final offset = (currentPageBooks.value - 1) * limitPerPageBooks;
      
      final response = await _categoryBooksService.getBooksByCategory(
        idKategori: selectedParentId.value,
        offset: offset,
        limit: limitPerPageBooks,
      );

      if (response['status'] == true && response['data'] != null) {
        final newBooks =
            List<Map<String, dynamic>>.from(response['data']['value'] ?? []);
        
        // Check for duplicates before adding
        final existingSlugs = categoryBooks.map((b) => b['slug_barang']).toSet();
        final uniqueNewBooks = newBooks.where((b) => 
          !existingSlugs.contains(b['slug_barang'])
        ).toList();
        
        categoryBooks.addAll(uniqueNewBooks);
        hasMoreBooks.value = newBooks.length >= limitPerPageBooks;
        
        print(
            '🔄 [CATEGORY CONTROLLER] Added ${uniqueNewBooks.length} unique books (${newBooks.length - uniqueNewBooks.length} duplicates skipped)');
      }
    } catch (e) {
      print('🔴 [CATEGORY CONTROLLER] Error loading more books: $e');
      currentPageBooks.value--; // Rollback on error
    } finally {
      isLoadingBooks.value = false;
    }
  }

  void resetToParentCategories() {
    selectedParentId.value = '';
    selectedParentName.value = '';
    childCategories.clear();
    categoryBooks.clear();
    hasMoreBooks.value = true;
    currentPageBooks.value = 1;
  }

  // Check if currently showing child categories
  bool get isShowingChildCategories => selectedParentId.value.isNotEmpty;
}
