import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(
      init: TransactionController(),
      builder: (controller) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Riwayat Transaksi'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Belum Dibayar'),
                  Tab(text: 'Selesai'),
                  Tab(text: 'Kadaluwarsa'),
                ],
              ),
              automaticallyImplyLeading: false,
            ),
            body: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error.value.isNotEmpty) {
                return Center(child: Text(controller.error.value));
              }
              return TabBarView(
                children: [
                  _TransactionList(controller.belumDibayarList,
                      enableTapToCheckout: true),
                  _TransactionList(controller.selesaiList),
                  _TransactionList(controller.dibatalkanList),
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
  const _TransactionList(this.transactions, {this.enableTapToCheckout = false});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Tidak ada transaksi'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final trx = transactions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      'Tanggal ${_formatDate(trx.tanggalTransaksi)}',
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
                  ...trx.barang.map((item) => _TransactionBookItem(item,
                      enableTapToCheckout: enableTapToCheckout)),
                  const SizedBox(height: 8),
                  Text(trx.jumlahBarang, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Harga',
                          style: TextStyle(fontWeight: FontWeight.w500)),
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
          ),
        );
      },
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
  const _TransactionBookItem(this.item, {this.enableTapToCheckout = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enableTapToCheckout
          ? () {
              if (item.idBarang.isNotEmpty) {
                Get.toNamed('/checkout', parameters: {'id': item.idBarang});
              }
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
