import 'package:get/get.dart';
import '../services/publisher_service.dart';

class PublisherController extends GetxController {
  final PublisherService _service = PublisherService();

  // Observable variables
  var isLoading = false.obs;
  var error = ''.obs;
  var publishers = <Map<String, dynamic>>[].obs;
  var imprints = <Map<String, dynamic>>[].obs;
  var imprintBooks = <Map<String, dynamic>>[].obs;

  // Pagination
  var currentOffset = 0.obs;
  var hasMoreData = false.obs;
  var totalPublishers = 0.obs;

  // Imprint books pagination
  var currentBookOffset = 0.obs;
  var hasMoreBooks = false.obs;
  var isLoadingBooks = false.obs;

  // Navigation state
  var selectedPublisherId = ''.obs;
  var selectedPublisherName = ''.obs;
  var selectedImprintId = ''.obs;
  var selectedImprintName = ''.obs;
  var isShowingImprints = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPublishers();
  }

  // Fetch publishers
  Future<void> fetchPublishers() async {
    try {
      print('🔄 [PUBLISHER CONTROLLER] Fetching publishers...');
      isLoading.value = true;
      error.value = '';
      currentOffset.value = 0;

      final result = await _service.getPublishers();
      publishers.value = List<Map<String, dynamic>>.from(result['list'] ?? []);
      totalPublishers.value = result['total'] ?? 0;
      hasMoreData.value = publishers.length < totalPublishers.value;

      print(
          '✅ [PUBLISHER CONTROLLER] Publishers loaded: ${publishers.length} items');
    } catch (e) {
      print('🔴 [PUBLISHER CONTROLLER] Error fetching publishers: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Load more publishers
  Future<void> loadMorePublishers() async {
    if (isLoading.value || !hasMoreData.value) return;

    try {
      print('🔄 [PUBLISHER CONTROLLER] Loading more publishers...');
      currentOffset.value += 10;

      final result = await _service.getPublishers(
        offset: currentOffset.value,
        limit: 10,
      );

      final newPublishers =
          List<Map<String, dynamic>>.from(result['list'] ?? []);
      publishers.addAll(newPublishers);
      hasMoreData.value = newPublishers.length >= 10;

      print(
          '✅ [PUBLISHER CONTROLLER] More publishers loaded: ${newPublishers.length} items');
    } catch (e) {
      print('🔴 [PUBLISHER CONTROLLER] Error loading more publishers: $e');
      error.value = e.toString();
    }
  }

  // Fetch imprints for a publisher
  Future<void> fetchImprints(String publisherId, String publisherName) async {
    try {
      print(
          '🔄 [PUBLISHER CONTROLLER] Fetching imprints for publisher: $publisherId');
      isLoading.value = true;
      error.value = '';

      // Clear previous data
      imprints.clear();
      imprintBooks.clear();
      hasMoreBooks.value = false;
      currentBookOffset.value = 0;

      final result = await _service.getImprints(publisherId);
      imprints.value = List<Map<String, dynamic>>.from(result['list'] ?? []);

      // Set selected publisher
      selectedPublisherId.value = publisherId;
      selectedPublisherName.value = publisherName;
      isShowingImprints.value = true;

      print(
          '✅ [PUBLISHER CONTROLLER] Imprints loaded: ${imprints.length} items');
    } catch (e) {
      print('🔴 [PUBLISHER CONTROLLER] Error fetching imprints: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch books for an imprint
  Future<void> fetchImprintBooks(String imprintId, String imprintName) async {
    try {
      print('🔄 [PUBLISHER CONTROLLER] Fetching books for imprint: $imprintId');
      isLoadingBooks.value = true;
      currentBookOffset.value = 0;

      final result = await _service.getBooksByImprint(
        imprintId: imprintId,
        offset: 0,
        limit: 20,
      );

      imprintBooks.value =
          List<Map<String, dynamic>>.from(result['value'] ?? []);
      hasMoreBooks.value = imprintBooks.length >= 20;
      currentBookOffset.value = 20;

      // Set selected imprint
      selectedImprintId.value = imprintId;
      selectedImprintName.value = imprintName;

      print(
          '✅ [PUBLISHER CONTROLLER] Imprint books loaded: ${imprintBooks.length} items');
    } catch (e) {
      print('🔴 [PUBLISHER CONTROLLER] Error fetching imprint books: $e');
      error.value = e.toString();
    } finally {
      isLoadingBooks.value = false;
    }
  }

  // Load more books for imprint
  Future<void> loadMoreImprintBooks() async {
    if (isLoadingBooks.value || !hasMoreBooks.value) return;

    try {
      print('🔄 [PUBLISHER CONTROLLER] Loading more imprint books...');
      isLoadingBooks.value = true;

      final result = await _service.getBooksByImprint(
        imprintId: selectedImprintId.value,
        offset: currentBookOffset.value,
        limit: 20,
      );

      final newBooks = List<Map<String, dynamic>>.from(result['value'] ?? []);
      imprintBooks.addAll(newBooks);
      hasMoreBooks.value = newBooks.length >= 20;
      currentBookOffset.value += 20;

      print(
          '✅ [PUBLISHER CONTROLLER] More imprint books loaded: ${newBooks.length} items');
    } catch (e) {
      print('🔴 [PUBLISHER CONTROLLER] Error loading more imprint books: $e');
      error.value = e.toString();
    } finally {
      isLoadingBooks.value = false;
    }
  }

  // Reset to publishers list
  void resetToPublishers() {
    selectedPublisherId.value = '';
    selectedPublisherName.value = '';
    selectedImprintId.value = '';
    selectedImprintName.value = '';
    isShowingImprints.value = false;
    imprints.clear();
    imprintBooks.clear();
    hasMoreBooks.value = false;
    currentBookOffset.value = 0;
    error.value = '';
  }

  // Refresh publishers
  Future<void> refreshPublishers() async {
    await fetchPublishers();
  }

  // Refresh imprints
  Future<void> refreshImprints() async {
    if (selectedPublisherId.value.isNotEmpty) {
      await fetchImprints(
          selectedPublisherId.value, selectedPublisherName.value);
    }
  }
}
