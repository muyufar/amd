import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/cart_model.dart';
import '../../utils/theme_utils.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/checkout_controller.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if this is a direct purchase or cart checkout
    final String? directId = Get.parameters['id'];
    final CartCheckout? cartCheckoutData = Get.arguments as CartCheckout?;

    // If direct purchase, use CheckoutController
    if (directId != null) {
      return _buildDirectCheckoutPage(context, directId);
    }

    // If cart checkout, use existing cart logic
    if (cartCheckoutData != null) {
      return _buildCartCheckoutPage(context, cartCheckoutData);
    }

    // No valid data
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: const Center(
        child: Text('Data checkout tidak ditemukan'),
      ),
    );
  }

  Widget _buildDirectCheckoutPage(BuildContext context, String idBarang) {
    final CheckoutController controller = Get.put(CheckoutController());
    final String? kodeAfiliasi = Get.parameters['afiliasi'];

    // Fetch checkout data for direct purchase
    controller.fetchCheckout(idBarang);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${controller.error.value}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchCheckout(idBarang),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final checkoutData = controller.checkoutData.value;
        if (checkoutData == null) {
          return const Center(child: Text('Data checkout tidak ditemukan'));
        }

        return _buildDirectCheckoutContent(
            context, checkoutData, controller, kodeAfiliasi);
      }),
    );
  }

  Widget _buildDirectCheckoutContent(
      BuildContext context,
      Map<String, dynamic> checkoutData,
      CheckoutController controller,
      String? kodeAfiliasi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary
          _buildSection(
            title: 'Ringkasan Pesanan',
            child: Column(
              children: [
                _buildSummaryRow(
                    'Harga', checkoutData['subtotal']?['harga'] ?? 0),
                if (checkoutData['subtotal']?['diskon']?['barang'] != null &&
                    checkoutData['subtotal']['diskon']['barang'] > 0)
                  _buildSummaryRow('Diskon Barang',
                      -(checkoutData['subtotal']['diskon']['barang'] ?? 0)),
                _buildSummaryRow(
                    'Subtotal', checkoutData['subtotal']?['subtotal'] ?? 0),
                _buildSummaryRow('PPN', checkoutData['subtotal']?['ppn'] ?? 0),
                const Divider(),
                _buildSummaryRow(
                  'Total',
                  checkoutData['subtotal']?['total'] ?? 0,
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // User Points
          if (checkoutData['data_user']?['poin_user'] != null)
            _buildSection(
              title: 'Poin User',
              child: Text(
                  'Poin tersedia: ${checkoutData['data_user']['poin_user']}'),
            ),
          const SizedBox(height: 16),

          // Items List
          _buildSection(
            title: 'Item Pesanan',
            child: Column(
              children: (checkoutData['data_checkout'] as List<dynamic>?)
                      ?.expand((checkoutGroup) =>
                          (checkoutGroup['items'] as List<dynamic>?) ?? [])
                      .map((item) => _buildDirectItemCard(item))
                      .toList() ??
                  [],
            ),
          ),
          const SizedBox(height: 24),

          // Payment Section
          _buildDirectPaymentSection(checkoutData, controller, kodeAfiliasi),
        ],
      ),
    );
  }

  Widget _buildDirectItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['gambar1'] ?? '',
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['judul'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${NumberFormat('#,###').format(item['harga'] ?? 0)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (item['harga_promo'] != null &&
                      item['harga_promo'] != item['harga'])
                    Text(
                      'Rp ${NumberFormat('#,###').format(item['harga_promo'] ?? 0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectPaymentSection(Map<String, dynamic> checkoutData,
      CheckoutController controller, String? kodeAfiliasi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pembayaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Midtrans Payment Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () =>
                        _handleDirectMidtransPayment(controller, kodeAfiliasi),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Bayar Sekarang'),
              )),
        ),

        const SizedBox(height: 12),

        // Original Payment Button (if midtrans data exists)
        if (checkoutData['midtrans'] != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _handlePayment(checkoutData['midtrans']),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Lanjutkan Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCartCheckoutPage(
      BuildContext context, CartCheckout checkoutData) {
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            _buildSection(
              title: 'Ringkasan Pesanan',
              child: Column(
                children: [
                  _buildSummaryRow(
                      'Subtotal', checkoutData.subtotal['subtotal'] ?? 0),
                  if (checkoutData.subtotal['diskon'] != null) ...[
                    _buildSummaryRow('Diskon Barang',
                        -(checkoutData.subtotal['diskon']['barang'] ?? 0)),
                    if (checkoutData.subtotal['diskon']['affiliator'] != null)
                      _buildSummaryRow(
                          'Diskon Affiliate',
                          -(checkoutData.subtotal['diskon']['affiliator'] ??
                              0)),
                  ],
                  _buildSummaryRow('PPN', checkoutData.subtotal['ppn'] ?? 0),
                  const Divider(),
                  _buildSummaryRow(
                    'Total',
                    checkoutData.subtotal['total'] ?? 0,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // User Points
            if (checkoutData.dataUser['poin_user'] != null)
              _buildSection(
                title: 'Poin Anda',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.stars, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        '${checkoutData.dataUser['poin_user']} Poin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Items List
            _buildSection(
              title: 'Item Pesanan',
              child: Column(
                children: checkoutData.dataCheckout
                    .map((item) => _buildItemCard(item))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Buttons
            _buildPaymentSection(checkoutData, cartController),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildSummaryRow(String label, int amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? colorPrimary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(CartBook item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.gambar1,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.diskon > 0) ...[
                    Text(
                      _formatCurrency(item.harga),
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    _formatCurrency(item.subtotal),
                    style: TextStyle(
                      color: colorPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(
      CartCheckout checkoutData, CartController cartController) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Midtrans Payment Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: Obx(() => ElevatedButton(
                onPressed: cartController.isCheckingOut.value
                    ? null
                    : () => _handleMidtransPayment(cartController),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: cartController.isCheckingOut.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Bayar Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )),
        ),

        const SizedBox(height: 12),

        // Original Payment Button (if midtrans data exists)
        if (checkoutData.midtrans != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _handlePayment(checkoutData.midtrans!),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Lanjutkan Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleDirectMidtransPayment(
      CheckoutController controller, String? kodeAfiliasi) async {
    try {
      final checkoutData = controller.checkoutData.value;
      if (checkoutData == null) {
        Get.snackbar(
          'Error',
          'Data checkout tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // For direct purchase, we need to call transaction/ebook API to get Midtrans URL
      // Get the book ID from checkout data
      final String? idBarang = Get.parameters['id'];
      if (idBarang == null || idBarang.isEmpty) {
        Get.snackbar(
          'Error',
          'ID barang tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Prepare transaction body for direct purchase
      final body = {
        'user': {
          'usePoinUser': false,
        },
        'dataCheckout': [
          {
            'products': [
              {
                'idProduct': idBarang,
                'isBuy': true,
              }
            ]
          }
        ],
      };

      // Add affiliate code if provided
      if (kodeAfiliasi != null && kodeAfiliasi.isNotEmpty) {
        body['voucherCode'] = kodeAfiliasi;
      }

      print('🔵 [DIRECT CHECKOUT] Pay with Midtrans with body: $body');

      final result = await controller.transaksi(body);

      if (result != null) {
        final redirectUrl = result['url'];
        if (redirectUrl != null && redirectUrl.isNotEmpty) {
          // Navigate to Midtrans WebView page
          Get.toNamed('/midtrans', parameters: {
            'url': redirectUrl,
            'type': 'direct',
          });

          Get.snackbar(
            'Pembayaran',
            'Redirecting to Midtrans payment gateway...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Payment URL not found in transaction response',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          controller.error.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handleMidtransPayment(CartController cartController) async {
    try {
      // Check if cart is empty and try to refresh
      if (cartController.cartItems.isEmpty) {
        Get.snackbar(
          'Info',
          'Mengambil data keranjang terbaru...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );

        await cartController.fetchCartItems();

        if (cartController.cartItems.isEmpty) {
          Get.snackbar(
            'Error',
            'Keranjang kosong, tidak dapat melakukan pembayaran',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      final result = await cartController.payWithMidtrans();

      if (result != null) {
        final redirectUrl = result['url'];
        if (redirectUrl != null) {
          // Navigate to Midtrans WebView page
          Get.toNamed('/midtrans', parameters: {
            'url': redirectUrl,
            'type': 'cart',
          });

          Get.snackbar(
            'Pembayaran',
            'Redirecting to Midtrans payment gateway...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Payment URL not found',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          cartController.error.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handlePayment(Map<String, dynamic> midtrans) {
    final redirectUrl = midtrans['redirect_url'];
    if (redirectUrl != null) {
      // You can use url_launcher to open the payment URL
      Get.snackbar(
        'Pembayaran',
        'Redirecting to payment gateway...',
        snackPosition: SnackPosition.BOTTOM,
      );
      // TODO: Implement url_launcher to open the payment URL
      // launchUrl(Uri.parse(redirectUrl));
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}
