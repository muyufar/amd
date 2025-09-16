import 'package:get/get.dart';
import '../controllers/bookshelf_controller.dart';

class BookshelfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookshelfController>(() => BookshelfController());
  }
}
