import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'transaction_detail_page.dart';
import '../../widgets/loading_animations.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(
      init: TransactionController(),
      builder: (controller) {
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Riwayat Transaksi'),
              bottom: const TabBar(
                isScrollable: true,
                labelPadding: EdgeInsets.symmetric(horizontal: 16),
                tabs: [
                  Tab(text: 'Belum Dibayar'),
                  Tab(text: 'Selesai'),
                  Tab(text: 'Kadaluwarsa'),
                  Tab(text: 'Dibatalkan'),
                ],
              ),
              automaticallyImplyLeading: false,
            ),
            body: Obx(() {
              return TabBarView(
                children: [
                  _TransactionList(
                    controller.belumDibayarList,
                    enableTapToCheckout: true,
                    isLoading: controller.isLoadingBelumDibayar.value,
                    error: controller.errorBelumDibayar.value,
                    onRefresh: controller.refreshBelumDibayar,
                  ),
                  _TransactionList(
                    controller.selesaiList,
                    enableTapToCheckout: true,
                    isLoading: controller.isLoadingSelesai.value,
                    error: controller.errorSelesai.value,
                    onRefresh: controller.refreshSelesai,
                  ),
                  _TransactionList(
                    controller.kadaluwarsaList,
                    enableTapToCheckout: true,
                    isLoading: controller.isLoadingKadaluwarsa.value,
                    error: controller.errorKadaluwarsa.value,
                    onRefresh: controller.refreshKadaluwarsa,
                  ),
                  _TransactionList(
                    controller.dibatalkanList,
                    enableTapToCheckout: true,
                    isLoading: controller.isLoadingDibatalkan.value,
                    error: controller.errorDibatalkan.value,
                    onRefresh: controller.refreshDibatalkan,
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<TransactionHistoryModel> transactions;
  final bool enableTapToCheckout;
  final bool isLoading;
  final String error;
  final VoidCallback? onRefresh;

  const _TransactionList(
    this.transactions, {
    this.enableTapToCheckout = false,
    this.isLoading = false,
    this.error = '',
    this.onRefresh,
  });

  Widget _buildSingleItemView(TransactionItemModel item,
      bool enableTapToCheckout, TransactionHistoryModel transaction) {
    return InkWell(
      onTap: enableTapToCheckout
          ? () {
              print('🔍 [TRANSACTION PAGE] Navigating to transaction detail');
              print(
                  '🔍 [TRANSACTION PAGE] transaction.idTransaksi: ${transaction.idTransaksi}');
              // Navigate to transaction detail page
              Get.to(() => TransactionDetailPage(
                    invoiceId: transaction.idInvoice.isNotEmpty
                        ? transaction.idInvoice
                        : transaction.idTransaksi,
                  ));
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.gambar1,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 60,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
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
                        fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: ${_formatCurrency(item.subTotal)}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (enableTapToCheckout)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleItemsView(List<TransactionItemModel> items,
      bool enableTapToCheckout, TransactionHistoryModel transaction) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          // Header untuk multiple items
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${items.length} Item dalam Keranjang',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // List items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Container(
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom:
                            BorderSide(color: Colors.orange[200]!, width: 1),
                      ),
              ),
              child: InkWell(
                onTap: enableTapToCheckout
                    ? () {
                        print(
                            '🔍 [TRANSACTION PAGE] Navigating to transaction detail (multiple items)');
                        print(
                            '🔍 [TRANSACTION PAGE] transaction.idTransaksi: ${transaction.idTransaksi}');
                        // Navigate to transaction detail page
                        Get.to(() => TransactionDetailPage(
                              invoiceId: transaction.idInvoice.isNotEmpty
                                  ? transaction.idInvoice
                                  : transaction.idTransaksi,
                            ));
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Item number
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Item image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          item.gambar1,
                          width: 40,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 40,
                            height: 50,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey, size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Item details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.judul,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatCurrency(item.subTotal),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      if (enableTapToCheckout)
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.orange),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator
    if (isLoading && transactions.isEmpty) {
      return LoadingAnimations.buildTransactionLoading();
    }

    // Show error state
    if (error.isNotEmpty && transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada transaksi untuk ditampilkan',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    // Show transaction list with pull-to-refresh
    return RefreshIndicator(
      onRefresh: onRefresh != null ? () async => onRefresh!() : () async {},
      child: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final trx = transactions[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header dengan tanggal dan jenis transaksi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: trx.barang.length > 1
                                    ? Colors.orange
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                trx.barang.length > 1 ? 'Keranjang' : 'Direct',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'Tanggal ${_formatDate(trx.tanggalTransaksi)}',
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Tampilan berbeda untuk single vs multiple items
                        if (trx.barang.length == 1)
                          // Single item - tampilan compact
                          _buildSingleItemView(
                              trx.barang.first, enableTapToCheckout, trx)
                        else
                          // Multiple items - tampilan expanded
                          _buildMultipleItemsView(
                              trx.barang, enableTapToCheckout, trx),

                        const SizedBox(height: 8),

                        // Summary
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Jumlah Item: ${trx.barang.length}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    trx.jumlahBarang,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Harga',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                    _formatCurrency(trx.totalHargaFinal),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Loading indicator overlay
          if (isLoading && transactions.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr);
      return DateFormat('dd-MM-yyyy HH:mm').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(int value) {
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }
}

class _TransactionBookItem extends StatelessWidget {
  final TransactionItemModel item;
  final bool enableTapToCheckout;
  final TransactionHistoryModel transaction;
  const _TransactionBookItem(this.item, this.transaction,
      {this.enableTapToCheckout = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enableTapToCheckout
          ? () {
              print(
                  '🔍 [TRANSACTION PAGE] Navigating to transaction detail (book item)');
              print(
                  '🔍 [TRANSACTION PAGE] transaction.idTransaksi: ${transaction.idTransaksi}');
              // Navigate to transaction detail page
              Get.to(() => TransactionDetailPage(
                    invoiceId: transaction.idInvoice.isNotEmpty
                        ? transaction.idInvoice
                        : transaction.idTransaksi,
                  ));
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.gambar1,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
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
                        fontWeight: FontWeight.w600, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Subtotal: ${_formatCurrency(item.subTotal)}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int value) {
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }
}
