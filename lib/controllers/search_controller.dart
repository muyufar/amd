import 'package:get/get.dart';
import '../services/search_service.dart';

class SearchController extends GetxController {
  final SearchService _searchService = SearchService();

  // Search state
  final RxString _keyword = ''.obs;
  final RxList<Map<String, dynamic>> _searchResults =
      <Map<String, dynamic>>[].obs;
  final RxInt _totalResults = 0.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Filter state
  final RxMap<String, dynamic> _filters = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> _kategoriOptions =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _penulisOptions =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _penerbitOptions =
      <Map<String, dynamic>>[].obs;
  final RxBool _isLoadingFilters = false.obs;

  // Pagination
  final RxInt _currentPage = 0.obs;
  final RxInt _limit = 20.obs;
  final RxBool _hasMoreData = true.obs;

  // Getters
  String get keyword => _keyword.value;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  int get totalResults => _totalResults.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  Map<String, dynamic> get filters => _filters;
  List<Map<String, dynamic>> get kategoriOptions => _kategoriOptions;
  List<Map<String, dynamic>> get penulisOptions => _penulisOptions;
  List<Map<String, dynamic>> get penerbitOptions => _penerbitOptions;
  bool get isLoadingFilters => _isLoadingFilters.value;
  int get currentPage => _currentPage.value;
  int get limit => _limit.value;
  bool get hasMoreData => _hasMoreData.value;

  // Set keyword and trigger search
  void setKeyword(String keyword) {
    _keyword.value = keyword;
    if (keyword.isNotEmpty) {
      _performSearch();
    } else {
      _clearResults();
    }
  }

  // Set filter
  void setFilter(String key, dynamic value) {
    _filters[key] = value;
    _performSearch();
  }

  // Remove filter
  void removeFilter(String key) {
    _filters.remove(key);
    _performSearch();
  }

  // Clear all filters
  void clearAllFilters() {
    _filters.clear();
    _performSearch();
  }

  // Perform search
  Future<void> _performSearch() async {
    if (_keyword.value.isEmpty) return;

    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      _currentPage.value = 0;
      _hasMoreData.value = true;

      final response = await _searchService.searchBooks(
        keyword: _keyword.value,
        limit: _limit.value,
        offset: 0,
        sortBy: _filters['sortBy'],
        kategori: _filters['kategori'],
        penulis: _filters['penulis'] != null
            ? List<String>.from(_filters['penulis'])
            : null,
        penerbit: _filters['penerbit'],
        hargaMin: _filters['hargaMin'],
      );

      if (response['status'] == true) {
        _searchResults.value =
            List<Map<String, dynamic>>.from(response['data']['list'] ?? []);
        _totalResults.value = response['data']['total'] ?? 0;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Gagal melakukan pencarian';
        _searchResults.clear();
        _totalResults.value = 0;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      _searchResults.clear();
      _totalResults.value = 0;
    } finally {
      _isLoading.value = false;
    }
  }

  // Load more results
  Future<void> loadMoreResults() async {
    if (!_hasMoreData.value || _isLoading.value || _keyword.value.isEmpty)
      return;

    try {
      _isLoading.value = true;
      _currentPage.value++;

      final response = await _searchService.searchBooks(
        keyword: _keyword.value,
        limit: _limit.value,
        offset: _currentPage.value * _limit.value,
        sortBy: _filters['sortBy'],
        kategori: _filters['kategori'],
        penulis: _filters['penulis'] != null
            ? List<String>.from(_filters['penulis'])
            : null,
        penerbit: _filters['penerbit'],
        hargaMin: _filters['hargaMin'],
      );

      if (response['status'] == true) {
        final newResults =
            List<Map<String, dynamic>>.from(response['data']['list'] ?? []);
        if (newResults.isEmpty) {
          _hasMoreData.value = false;
        } else {
          _searchResults.addAll(newResults);
        }
      } else {
        _hasMoreData.value = false;
      }
    } catch (e) {
      _hasMoreData.value = false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Load filters
  Future<void> loadFilters() async {
    if (_keyword.value.isEmpty) return;

    try {
      _isLoadingFilters.value = true;

      final response = await _searchService.getSearchFilters(
        keyword: _keyword.value,
        limit: _limit.value,
        offset: 0,
        sortBy: _filters['sortBy'],
        kategori: _filters['kategori'],
        penulis: _filters['penulis'] != null
            ? List<String>.from(_filters['penulis'])
            : null,
        penerbit: _filters['penerbit'],
        hargaMin: _filters['hargaMin'],
      );

      if (response['status'] == true) {
        _kategoriOptions.value =
            List<Map<String, dynamic>>.from(response['data']['kategori'] ?? []);
        _penulisOptions.value =
            List<Map<String, dynamic>>.from(response['data']['penulis'] ?? []);
        _penerbitOptions.value =
            List<Map<String, dynamic>>.from(response['data']['penerbit'] ?? []);
      }
    } catch (e) {
      print('Error loading filters: $e');
    } finally {
      _isLoadingFilters.value = false;
    }
  }

  // Clear results
  void _clearResults() {
    _searchResults.clear();
    _totalResults.value = 0;
    _errorMessage.value = '';
    _currentPage.value = 0;
    _hasMoreData.value = true;
  }

  // Reset search
  void resetSearch() {
    _keyword.value = '';
    _clearResults();
    _filters.clear();
    _kategoriOptions.clear();
    _penulisOptions.clear();
    _penerbitOptions.clear();
  }
}
