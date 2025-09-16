import 'package:get/get.dart';
import '../controllers/publisher_controller.dart';

class PublisherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PublisherController>(() => PublisherController());
  }
}
