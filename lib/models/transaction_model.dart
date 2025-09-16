
class TransactionHistoryModel {
  final bool isAllReview;
  final String idTransaksi;
  final String statusTransaksi;
  final String tanggalTransaksi;
  final int totalHargaFinal;
  final String jumlahBarang;
  final List<TransactionItemModel> barang;

  TransactionHistoryModel({
    required this.isAllReview,
    required this.idTransaksi,
    required this.statusTransaksi,
    required this.tanggalTransaksi,
    required this.totalHargaFinal,
    required this.jumlahBarang,
    required this.barang,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      isAllReview: json['isAllReview'] ?? false,
      idTransaksi: json['id_transaksi'] ?? '',
      statusTransaksi: json['status_transaksi'] ?? '',
      tanggalTransaksi: json['tanggal_transaksi'] ?? '',
      totalHargaFinal: json['total_harga_final'] ?? 0,
      jumlahBarang: json['jumlah_barang'] ?? '',
      barang: (json['barang'] as List<dynamic>? ?? [])
          .map((e) => TransactionItemModel.fromJson(e))
          .toList(),
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
      subTotal: json['sub_total'] ?? 0,
      isReviewed: json['isReviewed'] ?? false,
    );
  }
}
