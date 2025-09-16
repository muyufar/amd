import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_detail_controller.dart';
import '../../controllers/cart_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:intl/intl.dart';

class BookDetailPage extends StatelessWidget {
  final BookDetailController controller = Get.put(BookDetailController());
  final CartController cartController = Get.put(CartController());
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
          return const Center(child: CircularProgressIndicator());
        } else if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        } else if (controller.detail.value == null) {
          return const Center(child: Text('Data tidak ditemukan'));
        }
        final data = controller.detail.value!;
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
                                      final wish =
                                          controller.isWishlisted.value;
                                      final msg = wish
                                          ? 'Berhasil ditambahkan ke wishlist'
                                          : 'Berhasil dihapus dari wishlist';
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
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
                    child: Text(
                      data['kategori']['label'],
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
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
                if (data['reviews'] != null &&
                    (data['reviews']['jumlah'] ?? 0) > 0 &&
                    data['reviews']['list'] != null &&
                    (data['reviews']['list'] as List).isNotEmpty)
                  ...List.generate(data['reviews']['list'].length, (i) {
                    final review = data['reviews']['list'][i];
                    final rating =
                        double.tryParse(review['value']?.toString() ?? '0') ??
                            0.0;
                    final name = (review['isNameHidden'] == '1')
                        ? (review['nama_user']?.substring(0, 1) ?? '-') +
                            '*****'
                        : (review['nama_user'] ?? '-');
                    final date = review['created_at']?.split(' ')?.first ?? '';
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
                                        color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(review['description'] ?? '-'),
                          ],
                        ),
                      ),
                    );
                  })
                else
                  const Text('Belum ada ulasan',
                      style: TextStyle(color: Colors.grey)),
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
            // Tombol chat dan aksi utama
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  if ((data['status_ebook'] ?? '').toString().toLowerCase() ==
                      'beli sekarang') ...[
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.menu_book),
                          label: const Text('Baca Preview'),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add to Cart Button
                    SizedBox(
                      height: 48,
                      child: Obx(() => ElevatedButton.icon(
                            icon: cartController.isAddingToCart.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.shopping_cart),
                            label: const Text('Keranjang'),
                            onPressed: cartController.isAddingToCart.value
                                ? null
                                : () async {
                                    final token = GetStorage().read('token');
                                    if (token == null) {
                                      Get.toNamed('/login');
                                      return;
                                    }

                                    final idEbook = data['id_barang'] ??
                                        data['id_ebook'] ??
                                        '';
                                    if (idEbook.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'ID buku tidak ditemukan')),
                                      );
                                      return;
                                    }

                                    final success =
                                        await cartController.addToCart(
                                      idEbook: idEbook,
                                      ref: kodeAfiliasi,
                                    );

                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Berhasil ditambahkan ke keranjang'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(cartController.error.value),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final token = GetStorage().read('token');
                            if ((data['status_ebook'] ?? '')
                                    .toString()
                                    .toLowerCase() ==
                                'beli sekarang') {
                              if (token == null) {
                                Get.toNamed('/login', parameters: {
                                  'redirect': '/checkout',
                                  'id': data['id_barang']
                                });
                              } else {
                                Get.toNamed('/checkout', parameters: {
                                  'id': data['id_barang'],
                                  if (kodeAfiliasi != null)
                                    'afiliasi': kodeAfiliasi,
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            data['status_ebook'] ?? 'Aksi',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final status = (data['status_ebook'] ?? '')
                                .toString()
                                .toLowerCase();
                            if (status == 'beri rating') {
                              if (reviewFormKey.currentContext != null) {
                                Scrollable.ensureVisible(
                                  reviewFormKey.currentContext!,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            data['status_ebook'] ?? 'Aksi',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
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
