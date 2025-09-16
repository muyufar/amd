import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/cart_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
  }
}
