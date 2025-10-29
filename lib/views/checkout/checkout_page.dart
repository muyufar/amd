import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/cart_model.dart';
import '../../utils/theme_utils.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/checkout_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';
import 'package:get_storage/get_storage.dart';

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
    final String? transactionId = Get.parameters['transaction_id'];
    final bool isExistingTransaction = Get.parameters['is_existing'] == 'true';

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

        return _buildDirectCheckoutContent(context, checkoutData, controller,
            kodeAfiliasi, transactionId, isExistingTransaction);
      }),
    );
  }

  Widget _buildDirectCheckoutContent(
      BuildContext context,
      Map<String, dynamic> checkoutData,
      CheckoutController controller,
      String? kodeAfiliasi,
      String? transactionId,
      bool isExistingTransaction) {
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
                if (checkoutData['subtotal']?['biaya_layanan'] != null &&
                    checkoutData['subtotal']['biaya_layanan'] > 0)
                  _buildSummaryRow('Biaya Layanan',
                      checkoutData['subtotal']['biaya_layanan'] ?? 0),
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
          _buildDirectPaymentSection(checkoutData, controller, kodeAfiliasi,
              transactionId, isExistingTransaction),
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

  Widget _buildDirectPaymentSection(
      Map<String, dynamic> checkoutData,
      CheckoutController controller,
      String? kodeAfiliasi,
      String? transactionId,
      bool isExistingTransaction) {
    // DEBUG: Print all checkout data
    print('🔍 [CHECKOUT DEBUG] ===========================================');
    print('🔍 [CHECKOUT DEBUG] Full checkoutData: $checkoutData');
    print(
        '🔍 [CHECKOUT DEBUG] checkoutData keys: ${checkoutData.keys.toList()}');
    print('🔍 [CHECKOUT DEBUG] isExistingTransaction: $isExistingTransaction');
    print('🔍 [CHECKOUT DEBUG] transactionId: $transactionId');

    // Check if this is an existing transaction (has payment URL or is from transaction history)
    final bool hasExistingPayment = checkoutData['midtrans'] != null &&
        checkoutData['midtrans']['redirect_url'] != null;

    // Check for payment_redirect in existing transaction data
    final bool hasPaymentRedirect = checkoutData['payment_redirect'] != null &&
        checkoutData['payment_redirect'].toString().isNotEmpty;

    final bool shouldShowCancelButton =
        isExistingTransaction || hasExistingPayment || hasPaymentRedirect;

    final bool hasPaymentUrl = hasPaymentRedirect || hasExistingPayment;

    // DEBUG: Print payment URL detection
    print('🔍 [CHECKOUT DEBUG] hasExistingPayment: $hasExistingPayment');
    print('🔍 [CHECKOUT DEBUG] hasPaymentRedirect: $hasPaymentRedirect');
    print(
        '🔍 [CHECKOUT DEBUG] shouldShowCancelButton: $shouldShowCancelButton');
    print('🔍 [CHECKOUT DEBUG] hasPaymentUrl: $hasPaymentUrl');

    // DEBUG: Print specific payment data
    if (checkoutData['midtrans'] != null) {
      print('🔍 [CHECKOUT DEBUG] midtrans data: ${checkoutData['midtrans']}');
      print(
          '🔍 [CHECKOUT DEBUG] midtrans keys: ${checkoutData['midtrans'].keys.toList()}');
      if (checkoutData['midtrans']['redirect_url'] != null) {
        print(
            '🔍 [CHECKOUT DEBUG] midtrans.redirect_url: ${checkoutData['midtrans']['redirect_url']}');
      }
    }

    if (checkoutData['payment_redirect'] != null) {
      print(
          '🔍 [CHECKOUT DEBUG] payment_redirect: ${checkoutData['payment_redirect']}');
    }

    // DEBUG: Print other relevant fields
    if (checkoutData['id_transaksi'] != null) {
      print(
          '🔍 [CHECKOUT DEBUG] id_transaksi: ${checkoutData['id_transaksi']}');
    }
    if (checkoutData['transaction_id'] != null) {
      print(
          '🔍 [CHECKOUT DEBUG] transaction_id: ${checkoutData['transaction_id']}');
    }
    if (checkoutData['status_transaksi'] != null) {
      print(
          '🔍 [CHECKOUT DEBUG] status_transaksi: ${checkoutData['status_transaksi']}');
    }
    if (checkoutData['tanggal_transaksi'] != null) {
      print(
          '🔍 [CHECKOUT DEBUG] tanggal_transaksi: ${checkoutData['tanggal_transaksi']}');
    }

    print('🔍 [CHECKOUT DEBUG] ===========================================');

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
        if (shouldShowCancelButton) ...[
          // For existing transactions - show payment and cancel buttons
          if (hasPaymentUrl) ...[
            // Show both payment and cancel buttons
            Row(
              children: [
                // Bayar Sekarang button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (hasPaymentRedirect) {
                          // Use payment_redirect from existing transaction
                          _handlePaymentRedirect(
                              checkoutData['payment_redirect']);
                        } else if (hasExistingPayment) {
                          // Use existing payment URL from midtrans
                          _handleExistingPayment(checkoutData['midtrans']);
                        }
                      },
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('Bayar Sekarang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Batal Bayar button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _handleCancelPayment(checkoutData, transactionId),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Batal Bayar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Show only cancel button if no payment URL
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'URL pembayaran tidak tersedia',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Batal Bayar button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _handleCancelPayment(checkoutData, transactionId),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Batal Bayar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ] else ...[
          // For new transactions - show create payment button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => _handleDirectMidtransPayment(
                          controller, kodeAfiliasi),
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
        ],
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
                      'Harga', checkoutData.subtotal['harga'] ?? 0),
                  if (checkoutData.subtotal['diskon'] != null) ...[
                    _buildSummaryRow('Diskon Barang',
                        -(checkoutData.subtotal['diskon']['barang'] ?? 0)),
                    if (checkoutData.subtotal['diskon']['affiliator'] != null)
                      _buildSummaryRow(
                          'Diskon Affiliate',
                          -(checkoutData.subtotal['diskon']['affiliator'] ??
                              0)),
                  ],
                  _buildSummaryRow(
                      'Subtotal', checkoutData.subtotal['subtotal'] ?? 0),
                  if (checkoutData.subtotal['biaya_layanan'] != null &&
                      checkoutData.subtotal['biaya_layanan'] > 0)
                    _buildSummaryRow('Biaya Layanan',
                        checkoutData.subtotal['biaya_layanan'] ?? 0),
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

            // Items List - Only show selected items
            Obx(() => _buildSection(
                  title:
                      'Item Pesanan (${cartController.selectedItemsCount} item)',
                  child: Column(
                    children: cartController.selectedCartItems
                        .map((item) => _buildItemCard(item))
                        .toList(),
                  ),
                )),
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

  void _handlePaymentRedirect(String paymentRedirect) {
    print('🔍 [PAYMENT DEBUG] ===========================================');
    print('🔍 [PAYMENT DEBUG] _handlePaymentRedirect called');
    print('🔍 [PAYMENT DEBUG] paymentRedirect: $paymentRedirect');
    print(
        '🔍 [PAYMENT DEBUG] paymentRedirect type: ${paymentRedirect.runtimeType}');
    print(
        '🔍 [PAYMENT DEBUG] paymentRedirect length: ${paymentRedirect.length}');
    print(
        '🔍 [PAYMENT DEBUG] paymentRedirect isEmpty: ${paymentRedirect.isEmpty}');
    print(
        '🔍 [PAYMENT DEBUG] paymentRedirect isNotEmpty: ${paymentRedirect.isNotEmpty}');

    if (paymentRedirect.isNotEmpty) {
      print('🟡 [CHECKOUT] Using payment_redirect: $paymentRedirect');
      // Navigate to Midtrans page with payment_redirect URL
      Get.toNamed('/midtrans', parameters: {'url': paymentRedirect});
    } else {
      print('🔴 [CHECKOUT] Payment redirect is empty');
      Get.snackbar(
        'Error',
        'URL pembayaran tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    print('🔍 [PAYMENT DEBUG] ===========================================');
  }

  void _handleExistingPayment(Map<String, dynamic> midtrans) {
    print('🔍 [MIDTRANS DEBUG] ===========================================');
    print('🔍 [MIDTRANS DEBUG] _handleExistingPayment called');
    print('🔍 [MIDTRANS DEBUG] midtrans data: $midtrans');
    print('🔍 [MIDTRANS DEBUG] midtrans keys: ${midtrans.keys.toList()}');

    final redirectUrl = midtrans['redirect_url'];
    print('🔍 [MIDTRANS DEBUG] redirectUrl: $redirectUrl');
    print('🔍 [MIDTRANS DEBUG] redirectUrl type: ${redirectUrl.runtimeType}');
    print('🔍 [MIDTRANS DEBUG] redirectUrl is null: ${redirectUrl == null}');
    if (redirectUrl != null) {
      print('🔍 [MIDTRANS DEBUG] redirectUrl length: ${redirectUrl.length}');
      print('🔍 [MIDTRANS DEBUG] redirectUrl isEmpty: ${redirectUrl.isEmpty}');
      print(
          '🔍 [MIDTRANS DEBUG] redirectUrl isNotEmpty: ${redirectUrl.isNotEmpty}');
    }

    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      print('🟡 [CHECKOUT] Using existing payment URL: $redirectUrl');
      // Navigate to Midtrans page with existing payment URL
      Get.toNamed('/midtrans', parameters: {'url': redirectUrl});
    } else {
      print('🔴 [CHECKOUT] Redirect URL not found in midtrans data');
      Get.snackbar(
        'Error',
        'URL pembayaran tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    print('🔍 [MIDTRANS DEBUG] ===========================================');
  }

  void _handleCancelPayment(
      Map<String, dynamic> checkoutData, String? transactionId) async {
    try {
      print('🔍 [CANCEL DEBUG] ===========================================');
      print('🔍 [CANCEL DEBUG] _handleCancelPayment called');
      print('🔍 [CANCEL DEBUG] checkoutData: $checkoutData');
      print('🔍 [CANCEL DEBUG] transactionId: $transactionId');
      print(
          '🔍 [CANCEL DEBUG] checkoutData keys: ${checkoutData.keys.toList()}');

      // Use transaction ID from parameter or checkout data
      final finalTransactionId = transactionId ??
          checkoutData['id_transaksi'] ??
          checkoutData['transaction_id'];

      print('🔍 [CANCEL DEBUG] finalTransactionId: $finalTransactionId');
      print(
          '🔍 [CANCEL DEBUG] finalTransactionId type: ${finalTransactionId.runtimeType}');
      print(
          '🔍 [CANCEL DEBUG] finalTransactionId is null: ${finalTransactionId == null}');
      if (finalTransactionId != null) {
        print(
            '🔍 [CANCEL DEBUG] finalTransactionId length: ${finalTransactionId.length}');
        print(
            '🔍 [CANCEL DEBUG] finalTransactionId isEmpty: ${finalTransactionId.isEmpty}');
        print(
            '🔍 [CANCEL DEBUG] finalTransactionId isNotEmpty: ${finalTransactionId.isNotEmpty}');
      }

      print('🟡 [CHECKOUT] Cancel payment for existing transaction');

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Batalkan Pembayaran'),
          content:
              const Text('Apakah Anda yakin ingin membatalkan pembayaran ini?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      if (finalTransactionId == null || finalTransactionId.toString().isEmpty) {
        Get.back(); // Close loading
        Get.snackbar(
          'Error',
          'ID transaksi tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Call cancel API
      final token = GetStorage().read('token');
      if (token == null) {
        Get.back(); // Close loading
        Get.snackbar(
          'Error',
          'Token tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final url = Uri.parse('${AppConfig.baseUrlApp}/transaction/cancel');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: {
          '_method': 'PUT',
          'invoice_id': finalTransactionId.toString(),
        },
      );

      Get.back(); // Close loading

      print(
          '🔍 [CANCEL API DEBUG] ===========================================');
      print(
          '🔍 [CANCEL API DEBUG] Cancel response status: ${response.statusCode}');
      print(
          '🔍 [CANCEL API DEBUG] Cancel response headers: ${response.headers}');
      print('🔍 [CANCEL API DEBUG] Cancel response body: ${response.body}');
      print(
          '🔍 [CANCEL API DEBUG] Cancel response body length: ${response.body.length}');
      print(
          '🔍 [CANCEL API DEBUG] ===========================================');

      print('🟡 [CHECKOUT] Cancel response: ${response.statusCode}');
      print('🟡 [CHECKOUT] Cancel body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print(
            '🔍 [CANCEL JSON DEBUG] ===========================================');
        print('🔍 [CANCEL JSON DEBUG] JSON result: $result');
        print(
            '🔍 [CANCEL JSON DEBUG] JSON result keys: ${result.keys.toList()}');
        print('🔍 [CANCEL JSON DEBUG] JSON result status: ${result['status']}');
        print(
            '🔍 [CANCEL JSON DEBUG] JSON result message: ${result['message']}');
        if (result['data'] != null) {
          print('🔍 [CANCEL JSON DEBUG] JSON result data: ${result['data']}');
          print(
              '🔍 [CANCEL JSON DEBUG] JSON result data keys: ${result['data'].keys.toList()}');
        }
        print(
            '🔍 [CANCEL JSON DEBUG] ===========================================');

        if (result['status'] == true) {
          Get.snackbar(
            'Berhasil',
            'Pembayaran berhasil dibatalkan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Navigate back to transaction history
          Get.offAllNamed('/home');
          Get.toNamed('/transaksi');
        } else {
          Get.snackbar(
            'Error',
            result['message'] ?? 'Gagal membatalkan pembayaran',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Gagal membatalkan pembayaran',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading if still open
      print(
          '🔍 [CANCEL ERROR DEBUG] ===========================================');
      print('🔍 [CANCEL ERROR DEBUG] Error type: ${e.runtimeType}');
      print('🔍 [CANCEL ERROR DEBUG] Error message: $e');
      print('🔍 [CANCEL ERROR DEBUG] Error toString: ${e.toString()}');
      print(
          '🔍 [CANCEL ERROR DEBUG] ===========================================');

      print('🔴 [CHECKOUT] Error in cancel payment: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
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
