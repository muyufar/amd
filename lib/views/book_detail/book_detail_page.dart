import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_detail_controller.dart';
import '../../controllers/cart_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:intl/intl.dart';
import '../category/category_books_page.dart';
import '../../widgets/loading_animations.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

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
        print(
            '🔍 [BOOK DETAIL] file_ebook_preview in UI: ${data['file_ebook_preview']}');
        print(
            '🔍 [BOOK DETAIL] file_ebook_preview type in UI: ${data['file_ebook_preview'].runtimeType}');
        print(
            '🔍 [BOOK DETAIL] file_ebook_preview isEmpty in UI: ${data['file_ebook_preview']?.toString().isEmpty}');

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

                // DESKRIPSI
                const Text('Deskripsi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                const SizedBox(height: 4),
                _ExpandableText(
                  text: data['sinopsis'] ?? '-',
                ),
                const SizedBox(height: 24),
                // SPESIFIKASI / INFORMASI BUKU
                const SizedBox(height: 8),
                const Text('Informasi Buku',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                if (data['info'] != null && data['info'] is List)
                  _BookInfoSection(infoList: data['info'] as List),
                const SizedBox(height: 16),
                // BONUS BUKU (jika ada)
                if (_hasBonusBooks(data)) ...[
                  const Text('Bonus Buku',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _BonusBooksSection(
                      bonusBooks: data['file_bonus_ebook'] as List),
                  const SizedBox(height: 16),
                ],
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
    print('🔍 [BOOK DETAIL] Full data keys: ${data.keys.toList()}');
    print(
        '🔍 [BOOK DETAIL] file_ebook_preview exists: ${data.containsKey('file_ebook_preview')}');
    print(
        '🔍 [BOOK DETAIL] file_ebook_preview value: ${data['file_ebook_preview']}');
    print(
        '🔍 [BOOK DETAIL] file_ebook_preview type: ${data['file_ebook_preview'].runtimeType}');

    // Jika status BUKAN "beli sekarang", berarti buku sudah dibeli
    if (statusEbook != 'beli sekarang' && statusEbook.isNotEmpty) {
      return _buildOwnedBookButtons(data);
    }

    // Jika status adalah "beli sekarang" atau default
    return _buildPurchaseButtons(
        data, adaDiskon, hargaAkhir, hargaOriginal, kodeAfiliasi);
  }

  bool _hasBonusBooks(Map<String, dynamic> data) {
    final fileBonusEbook = data['file_bonus_ebook'];
    if (fileBonusEbook == null) return false;
    if (fileBonusEbook is List) {
      return fileBonusEbook.isNotEmpty &&
          fileBonusEbook.any((url) => url != null && url.toString().isNotEmpty);
    }
    return false;
  }

  Widget _buildOwnedBookButtons(Map<String, dynamic> data) {
    return Container(
      height: 50,
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
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final fileEbook = data['file_ebook_pdf']?.toString() ?? '';
              if (fileEbook.isNotEmpty) {
                Get.to(() => _PDFViewerPage(url: fileEbook, isPreview: false));
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
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Baca Buku',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseButtons(Map<String, dynamic> data, bool adaDiskon,
      dynamic hargaAkhir, dynamic hargaOriginal, String? kodeAfiliasi) {
    return Container(
      height: 50,
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
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
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
                          size: 20,
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
            height: 35,
            color: Colors.grey[300],
          ),

          // Icon Preview
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.teal,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_book,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                final fileEbookPreview =
                    data['file_ebook_preview']?.toString() ?? '';
                if (fileEbookPreview.isNotEmpty) {
                  // Navigate to PDF viewer with preview URL
                  Get.to(() =>
                      _PDFViewerPage(url: fileEbookPreview, isPreview: true));
                } else {
                  Get.defaultDialog(
                    title: 'Infos',
                    middleText: 'Preview buku belum tersedia untuk buku ini',
                    textConfirm: 'OK',
                    confirmTextColor: Colors.white,
                    onConfirm: () => Get.back(),
                  );
                }
              },
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 35,
            color: Colors.grey[300],
          ),

          // Tombol Beli Sekarang
          Expanded(
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
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
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _formatCurrency(
                              adaDiskon ? hargaAkhir : hargaOriginal),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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
      textAlign: TextAlign.justify,
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

// Tambahkan widget _PDFViewerPage di bawah file ini
class _PDFViewerPage extends StatefulWidget {
  final String url;
  final bool isPreview;
  const _PDFViewerPage({required this.url, this.isPreview = false});

  @override
  State<_PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<_PDFViewerPage> {
  @override
  void initState() {
    super.initState();
    // Enable screenshot protection saat halaman dibuka
    _enableScreenshotProtection();
  }

  @override
  void dispose() {
    // Disable screenshot protection saat halaman ditutup
    _disableScreenshotProtection();
    super.dispose();
  }

  static const MethodChannel _channel =
      MethodChannel('com.andi.digital.andi_digital/screenshot');

  Future<void> _enableScreenshotProtection() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('enableScreenshotProtection');
      }
    } catch (e) {
      print('Error enabling screenshot protection: $e');
    }
  }

  Future<void> _disableScreenshotProtection() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('disableScreenshotProtection');
      }
    } catch (e) {
      print('Error disabling screenshot protection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfUrl =
        widget.url.startsWith('http') ? widget.url : 'http://${widget.url}';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPreview ? 'Preview Buku' : 'Baca Buku'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (widget.isPreview)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PREVIEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          print('PDF Load Error: ${details.error}');
          Get.snackbar(
            'Error',
            'Gagal memuat ${widget.isPreview ? 'preview' : 'buku'}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          print(
              'PDF Loaded successfully: ${details.document.pages.count} pages');
        },
      ),
    );
  }
}

class _BookInfoSection extends StatefulWidget {
  final List<dynamic> infoList;
  const _BookInfoSection({required this.infoList});

  @override
  State<_BookInfoSection> createState() => _BookInfoSectionState();
}

class _BookInfoSectionState extends State<_BookInfoSection> {
  bool _showAllAuthors = false;
  static const int _maxAuthorsToShow = 3;

  @override
  Widget build(BuildContext context) {
    // Split info into two columns
    final leftColumn = <Widget>[];
    final rightColumn = <Widget>[];

    for (int i = 0; i < widget.infoList.length; i++) {
      final info = widget.infoList[i];
      final label = (info['label'] ?? '').toString().capitalizeFirst ?? '';
      final value = info['value']?.toString() ?? '-';

      final infoItem = _buildInfoItem(label, value, info);

      // Distribute items into two columns (alternating)
      if (i % 2 == 0) {
        leftColumn.add(infoItem);
      } else {
        rightColumn.add(infoItem);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: leftColumn,
          ),
        ),
        const SizedBox(width: 24),
        // Right column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rightColumn,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, Map<String, dynamic> info) {
    // Check if this is a clickable field (Penerbit, Penulis)
    final isClickable =
        label.toLowerCase() == 'penerbit' || label.toLowerCase() == 'penulis';

    // Special handling for Penulis
    if (label.toLowerCase() == 'penulis' && value.contains(',')) {
      return _buildAuthorsSection(value, info);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key (label)
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          // Value
          if (isClickable)
            GestureDetector(
              onTap: () {
                // Handle click action for Penerbit
                if (label.toLowerCase() == 'penerbit') {
                  // Navigate to publisher page or show publisher books
                  // You can implement navigation here if needed
                }
              },
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorsSection(String authorsValue, Map<String, dynamic> info) {
    final authors = authorsValue.split(',').map((e) => e.trim()).toList();
    final authorsToShow =
        _showAllAuthors ? authors : authors.take(_maxAuthorsToShow).toList();
    final hasMoreAuthors = authors.length > _maxAuthorsToShow;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key (label)
          Text(
            'Penulis',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          // Authors list
          ...authorsToShow.map((author) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: GestureDetector(
                  onTap: () {
                    // Handle click action for author
                    // You can implement navigation here if needed
                  },
                  child: Text(
                    '$author,',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )),
          // "Lainnya" button if there are more authors
          if (hasMoreAuthors && !_showAllAuthors)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showAllAuthors = true;
                });
              },
              child: Row(
                children: [
                  const Text(
                    'Lainnya',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
          if (_showAllAuthors && hasMoreAuthors)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showAllAuthors = false;
                });
              },
              child: Row(
                children: [
                  const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_up,
                    size: 16,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BonusBooksSection extends StatelessWidget {
  final List<dynamic> bonusBooks;
  const _BonusBooksSection({required this.bonusBooks});

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final fileName = path.split('/').last;
      final cleanFileName = fileName.split('?').first;
      final displayName = cleanFileName
          .replaceAll('-', ' ')
          .replaceAll('_', ' ')
          .replaceAll('.pdf', '');
      return displayName.isNotEmpty ? displayName : 'Bonus Buku';
    } catch (e) {
      return 'Bonus Buku';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bonusUrls = bonusBooks
        .where((url) => url != null && url.toString().isNotEmpty)
        .map((url) => url.toString())
        .toList();

    if (bonusUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: bonusUrls.asMap().entries.map((entry) {
        final index = entry.key;
        final url = entry.value;
        final fileName = _getFileNameFromUrl(url);
        return Card(
          margin:
              EdgeInsets.only(bottom: index < bonusUrls.length - 1 ? 12 : 0),
          child: ListTile(
            leading: const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 32,
            ),
            title: Text(
              fileName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Bonus ${index + 1}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.to(() => _PDFViewerPage(url: url, isPreview: false));
            },
          ),
        );
      }).toList(),
    );
  }
}
