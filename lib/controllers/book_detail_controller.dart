import 'package:get/get.dart';
import '../services/book_service.dart';
import '../services/wishlist_service.dart';

class BookDetailController extends GetxController {
  final BookService _bookService = BookService();
  final WishlistService _wishlistService = WishlistService();
  var isLoading = false.obs;
  var error = ''.obs;
  var detail = Rxn<Map<String, dynamic>>();
  var loadingWishlist = false.obs;
  var isWishlisted = false.obs;
  var loadingReview = false.obs;
  String? _currentSlug;

  Future<Map<String, dynamic>?> submitReview({
    required String idEbook,
    required int rating,
    String? description,
    required int isHide,
  }) async {
    loadingReview.value = true;
    try {
      final res = await _bookService.createReview(
        idEbook: idEbook,
        rating: rating,
        description: description,
        isHide: isHide,
      );
      if (res['status'] == true && _currentSlug != null) {
        await fetchDetail(_currentSlug!);
      }
      return res;
    } catch (e) {
      return {'status': false, 'message': e.toString()};
    } finally {
      loadingReview.value = false;
    }
  }

  Future<void> fetchDetail(
    String slug, {
    bool byId = false,
  }) async {
    _currentSlug = slug;
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _bookService.fetchDetailBuku(slug);
      detail.value = data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addOrToggleWishlist(String idEbook) async {
    loadingWishlist.value = true;
    try {
      final res = await _wishlistService.addToWishlist(idEbook);
      final msg = (res['message'] ?? '').toString().toLowerCase();
      if (msg.contains('hapus')) {
        isWishlisted.value = false;
      } else if (msg.contains('berhasil') || msg.contains('ditambahkan')) {
        isWishlisted.value = true;
      }
      // Bisa tambahkan snackbar/toast di UI
    } catch (e) {
      // Bisa tambahkan error handling di UI
    } finally {
      loadingWishlist.value = false;
    }
  }
}
