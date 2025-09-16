import 'package:get/get.dart';
import '../views/auth/login_page.dart';
import '../views/home/home_page.dart';
import '../bindings/home_binding.dart';
import '../views/book_detail/book_detail_page.dart';
import '../views/wishlist/wishlist_page.dart';
import '../views/bookshelf/bookshelf_page.dart';
import '../views/transaction/transaction_page.dart';
import '../views/category/category_page.dart';
import '../views/publisher/publisher_page.dart';
import '../views/profile/profile_page.dart';
import '../views/checkout/checkout_page.dart';
import '../views/checkout/midtrans_page.dart';
import '../views/auth/register_page.dart';
import '../views/cart/cart_page.dart';
import '../bindings/cart_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(name: AppRoutes.login, page: () => LoginPage()),
    GetPage(
        name: AppRoutes.home,
        page: () => const HomePage(),
        binding: HomeBinding()),
    GetPage(name: AppRoutes.bookDetail, page: () => BookDetailPage()),
    GetPage(name: AppRoutes.wishlist, page: () => const WishlistPage()),
    GetPage(name: AppRoutes.bookshelf, page: () => const BookshelfPage()),
    GetPage(name: AppRoutes.transaction, page: () => const TransactionPage()),
    GetPage(name: AppRoutes.category, page: () => const CategoryPage()),
    GetPage(name: AppRoutes.publisher, page: () => const PublisherPage()),
    GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),
    GetPage(
        name: AppRoutes.cart,
        page: () => const CartPage(),
        binding: CartBinding()),
    GetPage(name: AppRoutes.checkout, page: () => const CheckoutPage()),
    GetPage(name: '/midtrans', page: () => const MidtransPage()),
    GetPage(
      name: '/register',
      page: () => const RegisterPage(),
    ),
  ];
}
