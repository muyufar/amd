import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/book_service.dart';
import '../services/wishlist_service.dart';
import '../models/book_model.dart';

class BookDetailController extends GetxController {
  final BookService _bookService = BookService();
  final WishlistService _wishlistService = WishlistService();
  var isLoading = false.obs;
  var error = ''.obs;
  var detail = Rxn<Map<String, dynamic>>();
  var bookModel = Rxn<BookModel>();
  var loadingWishlist = false.obs;
  var isWishlisted = false.obs;
  var loadingReview = false.obs;
  var loadingReviews = false.obs;
  var reviews = Rxn<Map<String, dynamic>>();
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
      if (res['status'] == true) {
        // Refresh reviews after submitting a new review
        await fetchReviews(idEbook);
        // Also refresh detail to update status
        if (_currentSlug != null) {
          await fetchDetail(_currentSlug!);
        }
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
      print('🔍 [BOOK DETAIL CONTROLLER] Data received from service: $data');
      print(
          '🔍 [BOOK DETAIL CONTROLLER] file_ebook_preview in controller: ${data?['file_ebook_preview']}');
      detail.value = data;

      // Parse dan simpan BookModel
      if (data != null) {
        try {
          final model = BookModel.fromJson(data);
          bookModel.value = model;
          print('🔍 [BOOK DETAIL CONTROLLER] BookModel created successfully');
          print(
              '🔍 [BOOK DETAIL CONTROLLER] BookModel fileEbookPreview: ${model.fileEbookPreview}');
        } catch (e) {
          print('🔴 [BOOK DETAIL CONTROLLER] Error creating BookModel: $e');
        }
      }

      // Fetch reviews separately using the new API
      if (data != null) {
        final idEbook = data['id_barang'] ?? data['id_ebook'] ?? '';
        if (idEbook.isNotEmpty) {
          await fetchReviews(idEbook);
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReviews(String idEbook) async {
    loadingReviews.value = true;
    try {
      final data = await _bookService.fetchReviewList(idEbook);
      reviews.value = data;
    } catch (e) {
      print('🔴 [BOOK DETAIL CONTROLLER] Error fetching reviews: $e');
      // Set empty reviews on error
      reviews.value = {'totals': '0.0', 'jumlah': 0, 'list': []};
    } finally {
      loadingReviews.value = false;
    }
  }

  Future<void> addOrToggleWishlist(String idEbook) async {
    loadingWishlist.value = true;
    try {
      final res = await _wishlistService.addToWishlist(idEbook);
      final msg = (res['message'] ?? '').toString().toLowerCase();

      // Check if the book is already in collection
      if (msg.contains('sudah ada di koleksi') ||
          msg.contains('sudah ada di koleksi buku') ||
          msg.contains('buku sudah ada di koleksi') ||
          msg.contains('sudah ada di bookshelf') ||
          msg.contains('sudah dibeli') ||
          msg.contains('already in collection') ||
          msg.contains('sudah dimiliki')) {
        // Show notification that book is already in collection
        Get.snackbar(
          'Info',
          'Buku sudah ada di koleksi, Silahkan dibaca',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
        return;
      }

      if (msg.contains('hapus')) {
        isWishlisted.value = false;
        Get.snackbar(
          'Berhasil',
          'Buku dihapus dari wishlist',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.favorite_border, color: Colors.white),
        );
      } else if (msg.contains('berhasil') || msg.contains('ditambahkan')) {
        isWishlisted.value = true;
        Get.snackbar(
          'Berhasil',
          'Buku ditambahkan ke wishlist',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.favorite, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengupdate wishlist: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      loadingWishlist.value = false;
    }
  }
}
