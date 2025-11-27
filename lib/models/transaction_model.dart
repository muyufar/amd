class TransactionHistoryModel {
  final bool isAllReview;
  final String idTransaksi;
  final String idInvoice;
  final int statusTransaksi;
  final String tanggalTransaksi;
  final int totalHargaFinal;
  final int jumlahBarang;
  final TransactionItemModel? barang;
  final String? paymentUrl;

  TransactionHistoryModel({
    required this.isAllReview,
    required this.idTransaksi,
    required this.idInvoice,
    required this.statusTransaksi,
    required this.tanggalTransaksi,
    required this.totalHargaFinal,
    required this.jumlahBarang,
    this.barang,
    this.paymentUrl,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    // Handle barang as object (new format) or list (old format for backward compatibility)
    TransactionItemModel? barangItem;
    if (json['barang'] != null) {
      if (json['barang'] is Map<String, dynamic>) {
        // New format: barang is an object
        barangItem = TransactionItemModel.fromJson(json['barang'] as Map<String, dynamic>);
      } else if (json['barang'] is List && (json['barang'] as List).isNotEmpty) {
        // Old format: barang is a list, take first item
        barangItem = TransactionItemModel.fromJson((json['barang'] as List).first);
      }
    }

    return TransactionHistoryModel(
      isAllReview: json['isAllReview'] ?? false,
      idTransaksi: json['id_transaksi'] ?? '',
      idInvoice: json['id_invoice'] ?? '',
      statusTransaksi: json['status_transaksi'] is int 
          ? json['status_transaksi'] 
          : int.tryParse(json['status_transaksi']?.toString() ?? '0') ?? 0,
      tanggalTransaksi: json['tanggal_transaksi'] ?? '',
      totalHargaFinal: json['total_harga_final'] ?? 0,
      jumlahBarang: json['jumlah_barang'] is int 
          ? json['jumlah_barang'] 
          : int.tryParse(json['jumlah_barang']?.toString() ?? '0') ?? 0,
      barang: barangItem,
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
  final int hargaGross;
  final int hargaDiskon;
  final bool isReviewed;

  TransactionItemModel({
    required this.idBarang,
    required this.slugEbook,
    required this.gambar1,
    required this.judul,
    required this.subTotal,
    required this.hargaGross,
    required this.hargaDiskon,
    required this.isReviewed,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      idBarang: json['id_barang'] ?? '',
      slugEbook: json['slug_ebook'] ?? '',
      gambar1: json['gambar1'] ?? '',
      judul: json['judul'] ?? '',
      subTotal: json['subtotal'] ?? 0,
      hargaGross: json['harga_gross'] ?? 0,
      hargaDiskon: json['harga_diskon'] ?? 0,
      isReviewed: json['isReviewed'] ?? false,
    );
  }
}
