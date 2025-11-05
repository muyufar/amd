class TransactionHistoryModel {
  final bool isAllReview;
  final String idTransaksi;
  final String idInvoice;
  final String statusTransaksi;
  final String tanggalTransaksi;
  final int totalHargaFinal;
  final String jumlahBarang;
  final List<TransactionItemModel> barang;
  final String? paymentUrl;

  TransactionHistoryModel({
    required this.isAllReview,
    required this.idTransaksi,
    required this.idInvoice,
    required this.statusTransaksi,
    required this.tanggalTransaksi,
    required this.totalHargaFinal,
    required this.jumlahBarang,
    required this.barang,
    this.paymentUrl,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      isAllReview: json['isAllReview'] ?? false,
      idTransaksi: json['id_transaksi'] ?? '',
      idInvoice: json['id_invoice'] ?? '',
      statusTransaksi: json['status_transaksi'] ?? '',
      tanggalTransaksi: json['tanggal_transaksi'] ?? '',
      totalHargaFinal: json['total_harga_final'] ?? 0,
      jumlahBarang: json['jumlah_barang'] ?? '',
      barang: (json['barang'] as List<dynamic>? ?? [])
          .map((e) => TransactionItemModel.fromJson(e))
          .toList(),
      paymentUrl: json['payment_url'] ?? json['url_pembayaran'],
    );
  }
}

class TransactionItemModel {
  final String idBarang;
  final String slugEbook;
  final String gambar1;
  final String judul;
  final int subTotal;
  final bool isReviewed;

  TransactionItemModel({
    required this.idBarang,
    required this.slugEbook,
    required this.gambar1,
    required this.judul,
    required this.subTotal,
    required this.isReviewed,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      idBarang: json['id_barang'] ?? '',
      slugEbook: json['slug_ebook'] ?? '',
      gambar1: json['gambar1'] ?? '',
      judul: json['judul'] ?? '',
      subTotal: json['subtotal'] ?? 0,
      isReviewed: json['isReviewed'] ?? false,
    );
  }
}
