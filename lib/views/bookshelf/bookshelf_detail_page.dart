import 'package:andi_digital/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/book_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookshelfDetailPage extends StatefulWidget {
  final String slug;
  const BookshelfDetailPage({super.key, required this.slug});

  @override
  State<BookshelfDetailPage> createState() => _BookshelfDetailPageState();
}

class _BookshelfDetailPageState extends State<BookshelfDetailPage> {
  Map<String, dynamic>? detail;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      final data = await BookService().fetchDetailBuku(widget.slug);
      setState(() {
        detail = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Ebook')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : detail == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : Stack(
                      children: [
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // COVER BUKU DALAM CARD
                            if ((detail!['images'] as List?)?.isNotEmpty ??
                                false)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 84.0),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin:
                                      const EdgeInsets.only(top: 8, bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Center(
                                      child: SizedBox(
                                        width: 180,
                                        child: AspectRatio(
                                          aspectRatio: 0.68,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              detail!['images'][0],
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                color: Colors.grey,
                                                child: const Icon(
                                                    Icons.broken_image),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // JUDUL
                            Text(
                              detail!['judul'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            // KATEGORI
                            if (detail!['kategori'] != null &&
                                detail!['kategori']['label'] != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2, bottom: 8),
                                child: Text(
                                  detail!['kategori']['label'],
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                              ),
                            // SPESIFIKASI
                            const SizedBox(height: 8),
                            const Text('Spesifikasi',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            if (detail!['info'] != null &&
                                detail!['info'] is List)
                              Table(
                                columnWidths: const {
                                  0: IntrinsicColumnWidth(),
                                  1: FlexColumnWidth(),
                                },
                                children: [
                                  ...List.generate(
                                      (detail!['info'] as List).length, (i) {
                                    final info = detail!['info'][i];
                                    return TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Text(
                                          (info['label'] ?? '')
                                              .toString()
                                              .capitalizeFirst!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Text(
                                            info['value']?.toString() ?? '-'),
                                      ),
                                    ]);
                                  }),
                                ],
                              ),
                            const SizedBox(height: 16),
                            // DESKRIPSI
                            const Text('Deskripsi',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            _ExpandableText(text: detail!['sinopsis'] ?? '-'),
                            const SizedBox(
                                height: 80), // Untuk ruang tombol bawah
                          ],
                        ),
                        // Tombol Baca Ebook di bawah
                        if ((detail!['file_ebook_pdf'] ?? '')
                            .toString()
                            .isNotEmpty)
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.menu_book),
                                      label: const Text('Baca Ebook'),
                                      onPressed: () {
                                        final url = detail!['file_ebook_pdf']
                                            .toString();
                                        Get.to(() => _PDFViewerPage(url: url));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.card_giftcard),
                                      label: const Text('Bonus Buku'),
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: 'Bonus Buku',
                                          middleText:
                                              'Bonus buku akan segera tersedia!',
                                          textConfirm: 'OK',
                                          confirmTextColor: Colors.white,
                                          onConfirm: () => Get.back(),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

class _PDFViewerPage extends StatelessWidget {
  final String url;
  const _PDFViewerPage({required this.url});

  @override
  Widget build(BuildContext context) {
    final pdfUrl = url.startsWith('http') ? url : 'http://$url';
    return Scaffold(
      appBar: AppBar(title: const Text('Baca Ebook')),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}
