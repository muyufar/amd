class BookModel {
  final String idBarang;
  final String slugBarang;
  final String judul;
  final String sinopsis;
  final bool isDisplay;
  final bool? isOnCampaign;
  final String statusEbook;
  final bool isOwned;
  final bool isRated;
  final bool isWishlisted;
  final String? fileEbookPreview;
  final String? fileEbookPdf;
  final List<String> fileBonusEbook;
  final Map<String, dynamic> harga;
  final Map<String, dynamic> diskon;
  final Map<String, dynamic> campaign;
  final Map<String, dynamic> flashsale;
  final List<String> images;
  final Map<String, dynamic> kategori;
  final List<Map<String, dynamic>> info;

  BookModel({
    required this.idBarang,
    required this.slugBarang,
    required this.judul,
    required this.sinopsis,
    required this.isDisplay,
    this.isOnCampaign,
    required this.statusEbook,
    required this.isOwned,
    required this.isRated,
    required this.isWishlisted,
    this.fileEbookPreview,
    this.fileEbookPdf,
    required this.fileBonusEbook,
    required this.harga,
    required this.diskon,
    required this.campaign,
    required this.flashsale,
    required this.images,
    required this.kategori,
    required this.info,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      idBarang: json['id_barang'] ?? '',
      slugBarang: json['slug_barang'] ?? '',
      judul: json['judul'] ?? '',
      sinopsis: json['sinopsis'] ?? '',
      isDisplay: json['isDisplay'] ?? false,
      isOnCampaign: json['isOnCampaign'],
      statusEbook: json['status_ebook'] ?? '',
      isOwned: json['isOwned'] ?? false,
      isRated: json['isRated'] ?? false,
      isWishlisted: json['isWishlisted'] ?? false,
      fileEbookPreview: json['file_ebook_preview'],
      fileEbookPdf: json['file_ebook_pdf'],
      fileBonusEbook: List<String>.from(json['file_bonus_ebook'] ?? []),
      harga: Map<String, dynamic>.from(json['harga'] ?? {}),
      diskon: Map<String, dynamic>.from(json['diskon'] ?? {}),
      campaign: Map<String, dynamic>.from(json['campaign'] ?? {}),
      flashsale: Map<String, dynamic>.from(json['flashsale'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      kategori: Map<String, dynamic>.from(json['kategori'] ?? {}),
      info: List<Map<String, dynamic>>.from(
          (json['info'] ?? []).map((item) => Map<String, dynamic>.from(item))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_barang': idBarang,
      'slug_barang': slugBarang,
      'judul': judul,
      'sinopsis': sinopsis,
      'isDisplay': isDisplay,
      'isOnCampaign': isOnCampaign,
      'status_ebook': statusEbook,
      'isOwned': isOwned,
      'isRated': isRated,
      'isWishlisted': isWishlisted,
      'file_ebook_preview': fileEbookPreview,
      'file_ebook_pdf': fileEbookPdf,
      'file_bonus_ebook': fileBonusEbook,
      'harga': harga,
      'diskon': diskon,
      'campaign': campaign,
      'flashsale': flashsale,
      'images': images,
      'kategori': kategori,
      'info': info,
    };
  }
}
