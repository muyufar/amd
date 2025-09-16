import 'package:get/get.dart';
import '../services/book_service.dart';

class BookshelfController extends GetxController {
  final BookService _bookService = BookService();
  var isLoading = false.obs;
  var error = ''.obs;
  var bukuOwned = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBukuOwned();
  }

  void fetchBukuOwned() async {
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _bookService.fetchBukuOwned();
      bukuOwned.value = data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
