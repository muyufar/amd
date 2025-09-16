class CartItem {
  final String id;
  final String idUser;
  final String idEbook;
  final String? affiliatorId;
  final String createdAt;

  CartItem({
    required this.id,
    required this.idUser,
    required this.idEbook,
    this.affiliatorId,
    required this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      idUser: json['id_user'] ?? '',
      idEbook: json['id_ebook'] ?? '',
      affiliatorId: json['affiliator_id'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'id_ebook': idEbook,
      'affiliator_id': affiliatorId,
      'created_at': createdAt,
    };
  }
}

class CartBook {
  final String idBarang;
  final String idKeranjang;
  final String slugBarang;
  final String gambar1;
  final String judul;
  final int harga;
  final int hargaPromo;
  final int diskon;
  final int affiliateDiskon;
  final int subtotal;
  final String? lamaSewa;
  final Map<String, dynamic>? campaign;

  CartBook({
    required this.idBarang,
    required this.idKeranjang,
    required this.slugBarang,
    required this.gambar1,
    required this.judul,
    required this.harga,
    required this.hargaPromo,
    required this.diskon,
    required this.affiliateDiskon,
    required this.subtotal,
    this.lamaSewa,
    this.campaign,
  });

  factory CartBook.fromJson(Map<String, dynamic> json) {
    // Handle different field names from API response
    final idBarang = json['id_barang'] ?? '';
    final idKeranjang = json['id_keranjang'] ?? '';
    final harga = json['harga'] ?? json['harga_gross'] ?? 0;
    final hargaPromo = json['harga_promo'] ?? json['harga_diskon'] ?? 0;
    final diskon = json['diskon'] ?? json['discount_ebook'] ?? 0;
    final affiliateDiskon =
        json['affiliate_diskon'] ?? json['discount_affiliator'] ?? 0;

    // Calculate subtotal if not provided
    final subtotal =
        json['subtotal'] ?? json['harga_diskon_affiliator'] ?? hargaPromo;

    return CartBook(
      idBarang: idBarang,
      idKeranjang: idKeranjang,
      slugBarang: json['slug_barang'] ?? '',
      gambar1: json['gambar1'] ?? '',
      judul: json['judul'] ?? '',
      harga: harga,
      hargaPromo: hargaPromo,
      diskon: diskon,
      affiliateDiskon: affiliateDiskon,
      subtotal: subtotal,
      lamaSewa: json['lama_sewa'],
      campaign: json['campaign'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_barang': idBarang,
      'id_keranjang': idKeranjang,
      'slug_barang': slugBarang,
      'gambar1': gambar1,
      'judul': judul,
      'harga': harga,
      'harga_promo': hargaPromo,
      'diskon': diskon,
      'affiliate_diskon': affiliateDiskon,
      'subtotal': subtotal,
      'lama_sewa': lamaSewa,
      'campaign': campaign,
    };
  }
}

class CartCheckout {
  final Map<String, dynamic> dataUser;
  final Map<String, dynamic> dataProfile;
  final Map<String, dynamic> subtotal;
  final Map<String, dynamic> voucher;
  final List<CartBook> dataCheckout;
  final Map<String, dynamic>? midtrans;

  CartCheckout({
    required this.dataUser,
    required this.dataProfile,
    required this.subtotal,
    required this.voucher,
    required this.dataCheckout,
    this.midtrans,
  });

  factory CartCheckout.fromJson(Map<String, dynamic> json) {
    return CartCheckout(
      dataUser: json['data_user'] ?? {},
      dataProfile: json['data_profile'] ?? {},
      subtotal: json['subtotal'] ?? {},
      voucher: json['voucher'] ?? {},
      dataCheckout: (json['data_checkout'] as List<dynamic>?)
              ?.map((item) => CartBook.fromJson(item))
              .toList() ??
          [],
      midtrans: json['midtrans'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data_user': dataUser,
      'data_profile': dataProfile,
      'subtotal': subtotal,
      'voucher': voucher,
      'data_checkout': dataCheckout.map((item) => item.toJson()).toList(),
      'midtrans': midtrans,
    };
  }
}
