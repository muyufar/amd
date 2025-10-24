import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';
import 'package:get_storage/get_storage.dart';
import '../../widgets/loading_animations.dart';
import '../../controllers/transaction_controller.dart';

class TransactionDetailPage extends StatelessWidget {
  final String invoiceId;

  const TransactionDetailPage({
    super.key,
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchTransactionDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingAnimations.buildTransactionLoading();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final data = snapshot.data!;
          return _buildTransactionDetail(data);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchTransactionDetail() async {
    try {
      print(
          '🔍 [TRANSACTION DETAIL] Fetching transaction detail for invoice: $invoiceId');

      final token = GetStorage().read('token');
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final url =
          Uri.parse('${AppConfig.baseUrlApp}/transaction/detail/$invoiceId');
      print('🔍 [TRANSACTION DETAIL] API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('🔍 [TRANSACTION DETAIL] Response status: ${response.statusCode}');
      print('🔍 [TRANSACTION DETAIL] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == true && result['data'] != null) {
          print(
              '🔍 [TRANSACTION DETAIL] Successfully fetched transaction detail');
          return result['data'];
        } else {
          throw Exception(
              result['message'] ?? 'Gagal mengambil detail transaksi');
        }
      } else {
        throw Exception(
            'Failed to fetch transaction detail: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 [TRANSACTION DETAIL] Error: $e');
      rethrow;
    }
  }

  Widget _buildTransactionDetail(Map<String, dynamic> data) {
    final transaksi = data['transaksi'] as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    final rincianHarga = data['rincian_harga_total'] as Map<String, dynamic>;

    print('🔍 [TRANSACTION DETAIL] Building UI with data:');
    print('🔍 [TRANSACTION DETAIL] transaksi: $transaksi');
    print('🔍 [TRANSACTION DETAIL] items: $items');
    print('🔍 [TRANSACTION DETAIL] rincian_harga: $rincianHarga');
    print(
        '🔍 [TRANSACTION DETAIL] payment_redirect: ${transaksi['payment_redirect']}');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Info
          _buildTransactionInfo(transaksi),
          const SizedBox(height: 16),

          // Items List
          _buildItemsList(items),
          const SizedBox(height: 16),

          // Price Summary
          _buildPriceSummary(rincianHarga),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(transaksi),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo(Map<String, dynamic> transaksi) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Transaksi',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // _buildInfoRow('ID Transaksi', transaksi['id_transaksi'] ?? 'N/A'),
            _buildInfoRow('Invoice', transaksi['id_invoice'] ?? 'N/A'),
            _buildInfoRow(
                'Status', _getStatusText(transaksi['status_transaksi'])),
            _buildInfoRow(
                'Tanggal', _formatDate(transaksi['tanggal_transaksi'])),
            if (transaksi['tanggal_dibayar'] != null)
              _buildInfoRow(
                  'Tanggal Dibayar', _formatDate(transaksi['tanggal_dibayar'])),
            if (transaksi['metode_pembayaran'] != null &&
                transaksi['metode_pembayaran'].isNotEmpty)
              _buildInfoRow(
                  'Metode Pembayaran', transaksi['metode_pembayaran']),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(List<dynamic> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Transaksi',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildItemCard(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Book cover placeholder
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item['gambar1'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['gambar1'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.book, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.book, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['judul'] ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item['harga_normal'] != null)
                  Text(
                    'Harga Normal: ${_formatCurrency(item['harga_normal'])}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                if (item['harga_diskon_buku'] != null)
                  Text(
                    'Harga Diskon: ${_formatCurrency(item['harga_diskon_buku'])}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (item['affiliator_discount'] != null &&
                    item['affiliator_discount'] > 0)
                  Text(
                    'Diskon Affiliator: ${_formatCurrency(item['affiliator_discount'])}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Subtotal: ${_formatCurrency(item['sub_total'])}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(Map<String, dynamic> rincianHarga) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rincian Harga',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPriceRow('Harga Gross', rincianHarga['harga_gross']),
            if (rincianHarga['diskon'] != null) ...[
              if (rincianHarga['diskon']['ebook'] != null &&
                  rincianHarga['diskon']['ebook'] > 0)
                _buildPriceRow('Diskon Ebook', -rincianHarga['diskon']['ebook'],
                    isDiscount: true),
              if (rincianHarga['diskon']['affiliator'] != null &&
                  rincianHarga['diskon']['affiliator'] > 0)
                _buildPriceRow(
                    'Diskon Affiliator', -rincianHarga['diskon']['affiliator'],
                    isDiscount: true),
            ],
            _buildPriceRow('PPN', rincianHarga['PPN']),
            const Divider(),
            _buildPriceRow('Total Harga', rincianHarga['final_price'],
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> transaksi) {
    final paymentRedirect = transaksi['payment_redirect'];
    final statusTransaksi = transaksi['status_transaksi'];

    print('🔍 [TRANSACTION DETAIL] Building action buttons:');
    print('🔍 [TRANSACTION DETAIL] paymentRedirect: $paymentRedirect');
    print('🔍 [TRANSACTION DETAIL] statusTransaksi: $statusTransaksi');

    return Column(
      children: [
        if (statusTransaksi == '1' &&
            paymentRedirect != null &&
            paymentRedirect.isNotEmpty) ...[
          // Bayar Sekarang button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _handlePayment(paymentRedirect),
              icon: const Icon(Icons.payment, size: 20),
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
          const SizedBox(height: 12),
          // Batal Bayar button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _handleCancelPayment(transaksi['id_invoice']),
              icon: const Icon(Icons.cancel, size: 20),
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
        ] else if (statusTransaksi == '1') ...[
          // No payment URL available
          Container(
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
          const SizedBox(height: 12),
          // Batal Bayar button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _handleCancelPayment(transaksi['id_transaksi']),
              icon: const Icon(Icons.cancel, size: 20),
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
        ] else ...[
          // Transaction already paid or cancelled
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Transaksi sudah ${_getStatusText(statusTransaksi).toLowerCase()}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, dynamic amount,
      {bool isDiscount = false, bool isTotal = false}) {
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
              color: isDiscount ? Colors.red : null,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.orange : (isDiscount ? Colors.red : null),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePayment(String paymentRedirect) {
    print('🔍 [TRANSACTION DETAIL] _handlePayment called');
    print('🔍 [TRANSACTION DETAIL] paymentRedirect: $paymentRedirect');

    if (paymentRedirect.isNotEmpty) {
      print('🟡 [TRANSACTION DETAIL] Navigating to Midtrans: $paymentRedirect');
      Get.toNamed('/midtrans', parameters: {'url': paymentRedirect});
    } else {
      print('🔴 [TRANSACTION DETAIL] Payment redirect is empty');
      Get.snackbar(
        'Error',
        'URL pembayaran tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handleCancelPayment(String idTransaksi) async {
    try {
      print('🔍 [TRANSACTION DETAIL] _handleCancelPayment called');
      print('🔍 [TRANSACTION DETAIL] idTransaksi: $idTransaksi');

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

      // Show loading with better design
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated cancel icon
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.withOpacity(0.3),
                              Colors.red.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cancel,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Loading text
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Text(
                        'Membatalkan Transaksi...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Progress indicator
                SizedBox(
                  width: 200,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 3),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.red[100],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        minHeight: 4,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Animated dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 600 + (index * 200)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Transform.scale(
                            scale: 0.5 + (0.5 * value),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    Colors.red.withOpacity(0.3 + (0.7 * value)),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

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
          'invoice_id': idTransaksi,
        },
      );

      Get.back(); // Close loading

      print('🔍 [TRANSACTION DETAIL] Cancel response: ${response.statusCode}');
      print('🔍 [TRANSACTION DETAIL] Cancel body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == true) {
          // Close loading dialog
          Get.back();

          // Show success dialog
          Get.dialog(
            Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success icon
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.withOpacity(0.3),
                                  Colors.green.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Success text
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            'Pembatalan Transaksi Berhasil',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Transaksi telah berhasil dibatalkan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // OK button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back(); // Close dialog
                          Get.back(); // Back to transaction history
                          // Refresh transaction history
                          Get.find<TransactionController>()
                              .refreshTransactions();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );
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
      print('🔴 [TRANSACTION DETAIL] Error in cancel payment: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case '1':
        return 'Belum Dibayar';
      case '2':
        return 'Sudah Dibayar';
      case '3':
        return 'Selesai';
      case '4':
        return 'Dibatalkan';
      case '5':
        return 'Kadaluwarsa';
      default:
        return 'Tidak Diketahui';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr);
      return DateFormat('dd-MM-yyyy HH:mm').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
