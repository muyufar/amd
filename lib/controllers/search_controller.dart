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

      print('🔍 [SEARCH] Starting search for: ${_keyword.value}');
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

      print('🔍 [SEARCH] Response status: ${response['status']} (type: ${response['status'].runtimeType})');
      print('🔍 [SEARCH] Response data type: ${response['data']?.runtimeType}');
      
      // Check status flexibly - could be true, "true", 1, "success", etc.
      final status = response['status'];
      final isSuccess = status == true || 
                        status == 'true' || 
                        status == 1 || 
                        status == '1' ||
                        status == 'success';
      print('🔍 [SEARCH] Is success: $isSuccess');
      
      if (isSuccess && response['data'] != null) {
        final data = response['data'];
        print('🔍 [SEARCH] Data type: ${data.runtimeType}');
        
        final List<Map<String, dynamic>> fetched = [];
        int total = 0;
        
        // Handle different response formats
        if (data is Map<String, dynamic>) {
          // Format: { data: { list: [...], total: N } }
          final listData = data['list'] ?? data['items'] ?? data['books'] ?? data['results'];
          print('🔍 [SEARCH] List data from map: ${listData?.runtimeType}');
          
          if (listData is List) {
            print('🔍 [SEARCH] List length: ${listData.length}');
            for (var item in listData) {
              if (item is Map) {
                fetched.add(Map<String, dynamic>.from(item));
              }
            }
          }
          total = _parseInt(data['total'] ?? data['count'] ?? listData?.length ?? 0);
        } else if (data is List) {
          // Format: { data: [...] } - data is directly a list
          print('🔍 [SEARCH] Data is directly a List with ${data.length} items');
          for (var item in data) {
            if (item is Map) {
              fetched.add(Map<String, dynamic>.from(item));
            }
          }
          total = fetched.length;
        }
        
        _searchResults.value = _dedupeList(fetched, existingKeys: {});
        _totalResults.value = total;
        print('🔍 [SEARCH] Fetched ${fetched.length} results, total: $_totalResults');
      } else {
        print('🔴 [SEARCH] Status not success or data is null');
        print('🔴 [SEARCH] Response: $response');
        _errorMessage.value =
            response['message']?.toString() ?? 'Gagal melakukan pencarian';
        _searchResults.clear();
        _totalResults.value = 0;
      }
    } catch (e, stackTrace) {
      print('🔴 [SEARCH] Error: $e');
      print('🔴 [SEARCH] Stack trace: $stackTrace');
      _errorMessage.value = e.toString();
      _searchResults.clear();
      _totalResults.value = 0;
    } finally {
      _isLoading.value = false;
      // Load filters automatically after search completes
      // This ensures filters are always available when search results are shown
      if (_keyword.value.isNotEmpty) {
        loadFilters();
      }
    }
  }

  // Load more results
  Future<void> loadMoreResults() async {
    if (!_hasMoreData.value || _isLoading.value || _keyword.value.isEmpty) {
      return;
    }

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

      final status = response['status'];
      final isSuccess = status == true || status == 'true' || status == 1 || status == '1' || status == 'success';
      
      if (isSuccess && response['data'] != null) {
        final data = response['data'];
        final List<Map<String, dynamic>> newResults = [];
        
        if (data is Map<String, dynamic>) {
          final listData = data['list'] ?? data['items'] ?? data['books'] ?? data['results'];
          if (listData is List) {
            for (var item in listData) {
              if (item is Map) {
                newResults.add(Map<String, dynamic>.from(item));
              }
            }
          }
        } else if (data is List) {
          for (var item in data) {
            if (item is Map) {
              newResults.add(Map<String, dynamic>.from(item));
            }
          }
        }
        
        if (newResults.isEmpty) {
          _hasMoreData.value = false;
        } else {
          // Build existing keys set to avoid duplicates when appending
          final Set<String> existingKeys = _buildKeySet(_searchResults);
          final List<Map<String, dynamic>> uniqueNew =
              _dedupeList(newResults, existingKeys: existingKeys);
          if (uniqueNew.isEmpty && newResults.isNotEmpty) {
            // All results are duplicates; allow further loads but don't add duplicates
            // Do not change _hasMoreData here; next page may have new items
          } else {
            _searchResults.addAll(uniqueNew);
          }
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

      final status = response['status'];
      final isSuccess = status == true || status == 'true' || status == 1 || status == '1' || status == 'success';
      
      if (isSuccess && response['data'] != null) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          _kategoriOptions.value = _parseListOfMaps(data['kategori']);
          _penulisOptions.value = _parseListOfMaps(data['penulis']);
          _penerbitOptions.value = _parseListOfMaps(data['penerbit']);
        }
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

  // Helper: parse int from dynamic (String, int, etc)
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final cleaned = value.replaceAll('.', '').replaceAll(',', '').trim();
      return int.tryParse(cleaned) ?? 0;
    }
    return int.tryParse(value.toString()) ?? 0;
  }

  // Helper: safely parse List of Maps
  List<Map<String, dynamic>> _parseListOfMaps(dynamic data) {
    final List<Map<String, dynamic>> result = [];
    if (data is List) {
      for (var item in data) {
        if (item is Map) {
          result.add(Map<String, dynamic>.from(item));
        }
      }
    }
    return result;
  }

  // Helpers: build unique keys and dedupe lists by a stable key
  Set<String> _buildKeySet(List<Map<String, dynamic>> list) {
    return list
        .map((e) =>
            (e['slug_barang'] ?? e['id'] ?? e['slug'] ?? e['judul'] ?? '')
                .toString())
        .toSet();
  }

  List<Map<String, dynamic>> _dedupeList(List<Map<String, dynamic>> list,
      {required Set<String> existingKeys}) {
    final List<Map<String, dynamic>> result = [];
    final Set<String> keys = {...existingKeys};
    for (final item in list) {
      final String key = (item['slug_barang'] ??
              item['id'] ??
              item['slug'] ??
              item['judul'] ??
              '')
          .toString();
      if (key.isEmpty) {
        // If no stable key, accept the item to avoid dropping data unexpectedly
        result.add(item);
        continue;
      }
      if (!keys.contains(key)) {
        keys.add(key);
        result.add(item);
      }
    }
    return result;
  }
}
