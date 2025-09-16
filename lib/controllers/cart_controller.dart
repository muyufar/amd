import 'package:get/get.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find<CartController>();

  final CartService _cartService = CartService();

  // Observable variables
  final RxList<CartBook> cartItems = <CartBook>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAddingToCart = false.obs;
  final RxBool isRemovingFromCart = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxString error = ''.obs;

  // Cart count
  int get cartCount => cartItems.length;

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
  }

  // Fetch cart items
  Future<void> fetchCartItems() async {
    try {
      isLoading.value = true;
      error.value = '';

      print('🟡 [CART CONTROLLER] Fetching cart items...');
      final items = await _cartService.getCartItems();
      print('🟡 [CART CONTROLLER] Received ${items.length} items');
      cartItems.assignAll(items);
      print('🟡 [CART CONTROLLER] Cart items updated: ${cartItems.length}');
    } catch (e) {
      error.value = e.toString();
      print('🔴 [CART CONTROLLER] Error fetching cart items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add item to cart
  Future<bool> addToCart({
    required String idEbook,
    String? ref,
  }) async {
    try {
      isAddingToCart.value = true;
      error.value = '';

      final result = await _cartService.addToCart(
        idEbook: idEbook,
        ref: ref,
      );

      if (result != null && result['status'] == true) {
        // Refresh cart items after adding
        await fetchCartItems();
        return true;
      } else {
        error.value = result?['message'] ?? 'Failed to add to cart';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      print('Error adding to cart: $e');
      return false;
    } finally {
      isAddingToCart.value = false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String idBarang) async {
    try {
      isRemovingFromCart.value = true;
      error.value = '';

      print('🟡 [CART CONTROLLER] Removing item with idBarang: $idBarang');
      final result = await _cartService.removeFromCart(idBarang);

      if (result != null && result['status'] == true) {
        // Remove item from local list
        cartItems.removeWhere((item) => item.idBarang == idBarang);
        return true;
      } else {
        error.value = result?['message'] ?? 'Failed to remove from cart';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      print('Error removing from cart: $e');
      return false;
    } finally {
      isRemovingFromCart.value = false;
    }
  }

  // Checkout cart
  Future<CartCheckout?> checkoutCart() async {
    try {
      isCheckingOut.value = true;
      error.value = '';

      // Get all ebook IDs from cart items
      final ebookIds = cartItems.map((item) => item.idBarang).toList();
      print('🟡 [CART CONTROLLER] Checkout with ebook IDs: $ebookIds');

      final result = await _cartService.checkoutCart(ebookIds);

      if (result != null) {
        // Don't clear cart after checkout - only clear after successful payment
        return result;
      } else {
        error.value = 'Checkout failed';
        return null;
      }
    } catch (e) {
      error.value = e.toString();
      print('Error checking out cart: $e');
      return null;
    } finally {
      isCheckingOut.value = false;
    }
  }

  // Pay with Midtrans
  Future<Map<String, dynamic>?> payWithMidtrans(
      {bool usePoinUser = false, String? voucherCode}) async {
    try {
      isCheckingOut.value = true;
      error.value = '';

      // Check if cart is empty
      if (cartItems.isEmpty) {
        error.value = 'Keranjang kosong, tidak dapat melakukan pembayaran';
        return null;
      }

      // Get all ebook IDs from cart items
      final ebookIds = cartItems.map((item) => item.idBarang).toList();
      print('🟡 [CART CONTROLLER] Pay with Midtrans with ebook IDs: $ebookIds');
      print('🟡 [CART CONTROLLER] Cart items count: ${cartItems.length}');

      if (ebookIds.isEmpty) {
        error.value = 'Tidak ada item yang dapat dibayar';
        return null;
      }

      final result = await _cartService.payWithMidtrans(ebookIds,
          usePoinUser: usePoinUser, voucherCode: voucherCode);

      if (result != null) {
        // Clear cart after successful payment
        cartItems.clear();
        return result;
      } else {
        error.value = 'Payment failed';
        return null;
      }
    } catch (e) {
      error.value = e.toString();
      print('Error processing payment: $e');
      return null;
    } finally {
      isCheckingOut.value = false;
    }
  }

  // Calculate total price
  int get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  // Check if item is in cart
  bool isInCart(String idEbook) {
    return cartItems.any((item) => item.idBarang == idEbook);
  }

  // Clear error
  void clearError() {
    error.value = '';
  }
}
