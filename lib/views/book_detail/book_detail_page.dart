import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_detail_controller.dart';
import '../../controllers/cart_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:intl/intl.dart';
import '../category/category_books_page.dart';
import '../../widgets/loading_animations.dart';

class BookDetailPage extends StatelessWidget {
  final BookDetailController controller = Get.put(BookDetailController());
  final CartController cartController = Get.put(CartController());

  String _getButtonText(String? statusEbook) {
    if (statusEbook == null) return 'Aksi';

    final status = statusEbook.toLowerCase();
    if (status == 'beli sekarang') {
      return 'Beli';
    }
    return statusEbook;
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';

    int intValue;
    if (value is Map<String, dynamic>) {
      // If it's a Map, try to get the 'original' value
      intValue = value['original'] ?? 0;
    } else if (value is int) {
      intValue = value;
    } else if (value is String) {
      intValue = int.tryParse(value) ?? 0;
    } else {
      intValue = 0;
    }

    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(intValue);
  }

  final reviewFormKey = GlobalKey();
  final scrollController = ScrollController();

  BookDetailPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final slug = Get.parameters['slug'] ?? '';
    final kodeAfiliasi = Get.parameters['afiliasi'];
    print('BookDetailPage - Get.parameters: ${Get.parameters}');
    print('BookDetailPage - kodeAfiliasi: $kodeAfiliasi');
    controller.fetchDetail(
      slug,
    );
    // Tentukan harga akhir
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Buku')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return LoadingAnimations.buildBookDetailLoading();
        } else if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        } else if (controller.detail.value == null) {
          return const Center(child: Text('Data tidak ditemukan'));
        }
        final data = controller.detail.value!;

        // Debug: Print data untuk troubleshooting
        print('🔍 [BOOK DETAIL] Full data: $data');
        print('🔍 [BOOK DETAIL] Status ebook: ${data['status_ebook']}');

        final hargaOriginal = data['harga']?['original'] ?? 0;
        final rincian = data['diskon']?['rincian'] ?? {};
        final hargaAkhir =
            data['diskon']['rincian']['harga_akhir'] ?? hargaOriginal;
        final diskonBuku = rincian['diskon_buku'] ?? 0;
        final diskonAffiliate = rincian['diskon_affiliate'] ?? 0;
        final adaDiskon = (hargaAkhir < hargaOriginal) ||
            (diskonBuku > 0) ||
            (diskonAffiliate > 0);
        String formatRupiah(dynamic value) {
          if (value == null || value == '-') return '-';
          return NumberFormat.currency(
                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
              .format(value);
        }

        return Stack(
          children: [
            ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                if (kodeAfiliasi != null && kodeAfiliasi.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Kode Afiliasi: $kodeAfiliasi',
                          style: const TextStyle(color: Colors.blue)),
                    ),
                  ),
                // COVER BUKU DALAM CARD + TOMBOL WISHLIST
                if (data['images'] != null && data['images'].isNotEmpty)
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 84.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(top: 8, bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Center(
                              child: SizedBox(
                                width: 180,
                                child: AspectRatio(
                                  aspectRatio: 0.68,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      data['images'][0],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey,
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Tombol wishlist di kanan atas cover
                      Positioned(
                        top: 16,
                        right: 100,
                        child: Obx(() {
                          final wish = controller.isWishlisted.value ||
                              (data['isWishlisted'] == true);
                          return Material(
                            color: Colors.white.withOpacity(0.8),
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: IconButton(
                              icon: controller.loadingWishlist.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Icon(
                                      wish
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: wish ? Colors.red : Colors.grey,
                                    ),
                              onPressed: controller.loadingWishlist.value
                                  ? null
                                  : () async {
                                      final token = GetStorage().read('token');
                                      if (token == null) {
                                        Get.toNamed('/login');
                                        return;
                                      }
                                      final id = data['id_barang'] ??
                                          data['id_ebook'] ??
                                          '';
                                      await controller.addOrToggleWishlist(id);
                                    },
                              tooltip: 'Wishlist',
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                // HARGA
                if (adaDiskon) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      formatRupiah(hargaOriginal),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      formatRupiah(hargaAkhir),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      formatRupiah(hargaOriginal),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
                // JUDUL
                Text(
                  data['judul'] ?? '-',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // KATEGORI
                if (data['kategori'] != null &&
                    data['kategori']['label'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to category page with specific category
                        final idKategori = data['kategori']['id'] ??
                            data['kategori']['id_kategori'];
                        final namaKategori = data['kategori']['label'];

                        print(
                            '🔍 [BOOK DETAIL] Navigating to category: $namaKategori (ID: $idKategori)');

                        if (idKategori != null &&
                            idKategori.toString().isNotEmpty) {
                          // Navigate to specific category with books
                          Get.to(() => CategoryBooksPage(
                                categoryId: idKategori.toString(),
                                categoryName: namaKategori,
                              ));
                        } else {
                          // Fallback to general category page
                          Get.toNamed('/category');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              data['kategori']['label'],
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.blue[700],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // SPESIFIKASI
                const SizedBox(height: 8),
                const Text('Spesifikasi',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                if (data['info'] != null && data['info'] is List)
                  Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      ...List.generate((data['info'] as List).length, (i) {
                        final info = data['info'][i];
                        return TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              (info['label'] ?? '').toString().capitalizeFirst!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(info['value']?.toString() ?? '-'),
                          ),
                        ]);
                      }),
                    ],
                  ),
                const SizedBox(height: 16),
                // DESKRIPSI
                const Text('Deskripsi',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                _ExpandableText(text: data['sinopsis'] ?? '-'),
                const SizedBox(height: 24),
                // ULASAN PEMBELI
                const Text('Ulasan Pembeli',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Obx(() {
                  if (controller.loadingReviews.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final reviewsData = controller.reviews.value;
                  if (reviewsData != null &&
                      (reviewsData['jumlah'] ?? 0) > 0 &&
                      reviewsData['list'] != null &&
                      (reviewsData['list'] as List).isNotEmpty) {
                    return Column(
                      children: [
                        // Show total rating
                        if (reviewsData['totals'] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${reviewsData['totals']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${reviewsData['jumlah']} ulasan)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Show individual reviews
                        ...List.generate(reviewsData['list'].length, (i) {
                          final review = reviewsData['list'][i];
                          final rating = double.tryParse(
                                  review['value']?.toString() ?? '0') ??
                              0.0;
                          final name = (review['isNameHidden'] == '1')
                              ? (review['nama_user']?.substring(0, 1) ?? '-') +
                                  '*****'
                              : (review['nama_user'] ?? '-');
                          final date =
                              review['created_at']?.split(' ')?.first ?? '';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      ...List.generate(
                                          5,
                                          (j) => Icon(Icons.star,
                                              size: 16,
                                              color: j < rating
                                                  ? Colors.amber
                                                  : Colors.grey)),
                                      const SizedBox(width: 8),
                                      Text(date,
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(review['description'] ?? '-'),
                                ],
                              ),
                            ),
                          );
                        })
                      ],
                    );
                  } else {
                    return const Text('Belum ada ulasan',
                        style: TextStyle(color: Colors.grey));
                  }
                }),
                // FORM BERI RATING & REVIEW
                if ((data['status_ebook'] ?? '').toString().toLowerCase() ==
                    'beri rating')
                  KeyedSubtree(
                    key: reviewFormKey,
                    child: _ReviewForm(
                        idEbook: data['id_barang'] ?? data['id_ebook'] ?? ''),
                  ),
                const SizedBox(height: 80), // Untuk ruang tombol bawah
              ],
            ),
            // Tombol aksi utama dengan design baru - dinamis berdasarkan status_ebook
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildActionButtons(
                  data, adaDiskon, hargaAkhir, hargaOriginal, kodeAfiliasi),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> data, bool adaDiskon,
      dynamic hargaAkhir, dynamic hargaOriginal, String? kodeAfiliasi) {
    final statusEbook = (data['status_ebook'] ?? '').toString().toLowerCase();

    // Debug: Print status untuk troubleshooting
    print('🔍 [BOOK DETAIL] Status ebook: $statusEbook');

    // Jika status BUKAN "beli sekarang", berarti buku sudah dibeli
    if (statusEbook != 'beli sekarang' && statusEbook.isNotEmpty) {
      // Cek apakah user sudah memberikan rating
      final hasUserReviewed = _checkIfUserHasReviewed(data);
      print('🔍 [BOOK DETAIL] Has user reviewed: $hasUserReviewed');
      return _buildOwnedBookButtons(data, hasUserReviewed);
    }

    // Jika status adalah "beli sekarang" atau default
    return _buildPurchaseButtons(
        data, adaDiskon, hargaAkhir, hargaOriginal, kodeAfiliasi);
  }

  bool _checkIfUserHasReviewed(Map<String, dynamic> data) {
    final statusEbook = (data['status_ebook'] ?? '').toString().toLowerCase();

    // Debug: Print status untuk troubleshooting
    print('🔍 [BOOK DETAIL] Checking review status for: $statusEbook');

    // Jika status masih "beri rating", berarti user belum memberikan rating
    if (statusEbook == 'beri rating') {
      print('🔍 [BOOK DETAIL] User belum rating (status: beri rating)');
      return false;
    }

    // Jika status bukan "beri rating" dan bukan "beli sekarang", berarti user sudah memberikan rating
    if (statusEbook != 'beli sekarang' && statusEbook.isNotEmpty) {
      print('🔍 [BOOK DETAIL] User sudah rating (status: $statusEbook)');
      return true;
    }

    // Default: belum rating
    print('🔍 [BOOK DETAIL] Default: User belum rating');
    return false;
  }

  Widget _buildOwnedBookButtons(
      Map<String, dynamic> data, bool hasUserReviewed) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol Baca Buku (selalu ada)
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  onTap: () {
                    final fileEbook = data['file_ebook_pdf']?.toString() ?? '';
                    if (fileEbook.isNotEmpty) {
                      Get.to(() => _PDFViewerPage(url: fileEbook));
                    } else {
                      Get.defaultDialog(
                        title: 'Info',
                        middleText: 'File ebook belum tersedia',
                        textConfirm: 'OK',
                        confirmTextColor: Colors.white,
                        onConfirm: () => Get.back(),
                      );
                    }
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Baca Buku',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),

          // Tombol kedua berdasarkan status rating
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: hasUserReviewed ? Colors.green : Colors.orange,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  onTap: () {
                    if (hasUserReviewed) {
                      // Jika sudah rating, tampilkan bonus buku
                      Get.defaultDialog(
                        title: 'Bonus Buku',
                        middleText: 'Bonus buku akan segera tersedia!',
                        textConfirm: 'OK',
                        confirmTextColor: Colors.white,
                        onConfirm: () => Get.back(),
                      );
                    } else {
                      // Jika belum rating, scroll ke form review
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasUserReviewed ? Icons.card_giftcard : Icons.star,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasUserReviewed ? 'Bonus Buku' : 'Beri Rating',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButtons(Map<String, dynamic> data, bool adaDiskon,
      dynamic hargaAkhir, dynamic hargaOriginal, String? kodeAfiliasi) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Keranjang
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Obx(() => IconButton(
                  icon: cartController.isAddingToCart.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 24,
                        ),
                  onPressed: cartController.isAddingToCart.value
                      ? null
                      : () async {
                          print('🟢 [BOOK DETAIL] Add to cart button pressed');

                          final token = GetStorage().read('token');
                          if (token == null) {
                            print(
                                '🔴 [BOOK DETAIL] No token found, redirecting to login');
                            Get.toNamed('/login');
                            return;
                          }

                          final idEbook =
                              data['id_barang'] ?? data['id_ebook'] ?? '';
                          print('🟢 [BOOK DETAIL] Book data: $data');
                          print('🟢 [BOOK DETAIL] Extracted idEbook: $idEbook');
                          print(
                              '🟢 [BOOK DETAIL] Kode afiliasi: $kodeAfiliasi');

                          if (idEbook.isEmpty) {
                            print('🔴 [BOOK DETAIL] ID buku kosong');
                            Get.snackbar(
                              'Error',
                              'ID buku tidak ditemukan',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          print(
                              '🟢 [BOOK DETAIL] Calling cartController.addToCart...');
                          final success = await cartController.addToCart(
                            idEbook: idEbook,
                            ref: kodeAfiliasi,
                          );
                          print(
                              '🟢 [BOOK DETAIL] Add to cart result: $success');

                          if (success) {
                            Get.snackbar(
                              'Berhasil',
                              'Berhasil ditambahkan ke keranjang',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              cartController.error.value,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                )),
          ),

          // Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),

          // Icon Preview
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_book,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                Get.defaultDialog(
                  title: 'Info',
                  middleText:
                      'Buku ini Tidak tersedia previewnya, Langsung beli saja ya...!',
                  textConfirm: 'OK',
                  confirmTextColor: Colors.white,
                  onConfirm: () => Get.back(),
                );
              },
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),

          // Tombol Beli Sekarang
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  onTap: () {
                    final token = GetStorage().read('token');
                    if ((data['status_ebook'] ?? '').toString().toLowerCase() ==
                        'beli sekarang') {
                      if (token == null) {
                        Get.toNamed('/login', parameters: {
                          'redirect': '/checkout',
                          'id': data['id_barang']
                        });
                      } else {
                        Get.toNamed('/checkout', parameters: {
                          'id': data['id_barang'],
                          if (kodeAfiliasi != null) 'afiliasi': kodeAfiliasi,
                        });
                      }
                    }
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Beli Sekarang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(
                              adaDiskon ? hargaAkhir : hargaOriginal),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool expanded = false;
  static const int maxLines = 4;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      maxLines: expanded ? null : maxLines,
      overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 15),
    );
    final isLong = widget.text.length > 120;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget,
        if (isLong && !expanded)
          GestureDetector(
            onTap: () => setState(() => expanded = true),
            child: const Text('Baca Selengkapnya',
                style: TextStyle(color: Colors.blue)),
          ),
        if (isLong && expanded)
          GestureDetector(
            onTap: () => setState(() => expanded = false),
            child: const Text('Tutup', style: TextStyle(color: Colors.blue)),
          ),
      ],
    );
  }
}

class _ReviewForm extends StatefulWidget {
  final String idEbook;
  const _ReviewForm({required this.idEbook});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();
  bool isHide = false;

  @override
  Widget build(BuildContext context) {
    final BookDetailController controller = Get.find<BookDetailController>();
    return Card(
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Beri Rating & Review',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                  5,
                  (i) => IconButton(
                        icon: Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setState(() => rating = i + 1),
                      )),
            ),
            TextField(
              controller: reviewController,
              decoration: const InputDecoration(
                labelText: 'Tulis review (opsional)',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            Row(
              children: [
                Checkbox(
                  value: isHide,
                  onChanged: (v) => setState(() => isHide = v ?? true),
                ),
                const Text('Sembunyikan nama saya'),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: controller.loadingReview.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.star, color: Colors.white),
                    label: Text(
                      'Kirim',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      shadowColor: Colors.blue.withOpacity(0.2),
                    ),
                    onPressed: controller.loadingReview.value
                        ? null
                        : () async {
                            if (rating == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Pilih rating terlebih dahulu!')),
                              );
                              return;
                            }
                            final res = await controller.submitReview(
                              idEbook: widget.idEbook,
                              rating: rating,
                              description: reviewController.text.trim(),
                              isHide: isHide ? 1 : 0,
                            );
                            if (res != null && res['status'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Buku berhasil direview')),
                              );
                              setState(() {
                                rating = 0;
                                reviewController.clear();
                                isHide = false;
                              });
                            } else {
                              final msg =
                                  res?['message'] ?? 'Gagal mengirim review';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Buku gagal di review'),
                                      Text(msg,
                                          style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// Tambahkan widget _PDFViewerPage di bawah file ini
class _PDFViewerPage extends StatelessWidget {
  final String url;
  const _PDFViewerPage({required this.url});

  @override
  Widget build(BuildContext context) {
    final pdfUrl = url.startsWith('http') ? url : 'http://$url';
    return Scaffold(
      appBar: AppBar(title: const Text('Baca Preview')),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}
