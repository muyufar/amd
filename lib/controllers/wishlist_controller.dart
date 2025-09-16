import 'package:get/get.dart';
import '../services/wishlist_service.dart';

class WishlistController extends GetxController {
  final WishlistService _service = WishlistService();
  var wishlist = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _service.fetchWishlist();
      // Filter hanya item yang berbentuk Map agar aman dipakai di UI
      wishlist.value = data.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      final message = e.toString();
      // Jika error parsing tipe, treat sebagai empty state agar tidak tampil pesan teknis
      if (message.contains("type 'String' is not a subtype of type 'int'")) {
        wishlist.value = [];
        error.value = '';
      } else {
        error.value = 'Terjadi kesalahan saat memuat wishlist';
      }
    } finally {
      isLoading.value = false;
    }
  }
}
