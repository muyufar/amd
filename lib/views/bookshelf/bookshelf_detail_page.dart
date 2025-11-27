import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/book_service.dart';
import '../../controllers/book_detail_controller.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io' show Platform, File, Directory;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

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
  Map<String, bool> downloadingFiles = {}; // Track downloading files

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

  bool _hasBonusBooks(Map<String, dynamic> data) {
    final fileBonusEbook = data['file_bonus_ebook'];
    if (fileBonusEbook == null) return false;
    if (fileBonusEbook is List) {
      return fileBonusEbook.isNotEmpty &&
          fileBonusEbook.any((url) => url != null && url.toString().isNotEmpty);
    }
    return false;
  }

  void _showBonusBooksDialog(Map<String, dynamic> data) {
    final fileBonusEbook = data['file_bonus_ebook'];
    if (fileBonusEbook == null || fileBonusEbook is! List) {
      return;
    }

    final bonusUrls = (fileBonusEbook)
        .where((url) => url != null && url.toString().isNotEmpty)
        .map((url) => url.toString())
        .toList();

    if (bonusUrls.isEmpty) {
      return;
    }

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bonus Buku',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: bonusUrls.length,
                      itemBuilder: (context, index) {
                        final url = bonusUrls[index];
                        final fileName = _getFileNameFromUrl(url);
                        final isDownloading = downloadingFiles[url] ?? false;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isDownloading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                else
                                  IconButton(
                                    icon: const Icon(Icons.download, size: 20),
                                    onPressed: () async {
                                      await _downloadBonusBook(url, fileName);
                                      setDialogState(() {}); // Refresh dialog
                                    },
                                    tooltip: 'Download',
                                  ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                            onTap: () {
                              Get.back(); // Close dialog
                              Get.to(() => _PDFViewerPage(url: url));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final fileName = path.split('/').last;
      // Remove query parameters if any
      final cleanFileName = fileName.split('?').first;
      // Remove extension for display, or keep it
      final displayName = cleanFileName
          .replaceAll('-', ' ')
          .replaceAll('_', ' ')
          .replaceAll('.pdf', '');
      return displayName.isNotEmpty ? displayName : 'Bonus Buku';
    } catch (e) {
      return 'Bonus Buku';
    }
  }

  String _getFileNameForDownload(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final fileName = path.split('/').last;
      // Remove query parameters if any
      final cleanFileName = fileName.split('?').first;
      // Ensure it has .pdf extension
      if (!cleanFileName.toLowerCase().endsWith('.pdf')) {
        return '$cleanFileName.pdf';
      }
      return cleanFileName;
    } catch (e) {
      return 'bonus_buku_${DateTime.now().millisecondsSinceEpoch}.pdf';
    }
  }

  void _showRatingDialog(Map<String, dynamic> data) {
    final idEbook = data['id_barang'] ?? data['id_ebook'] ?? '';
    final statusEbook = (data['status_ebook'] ?? '').toString().toLowerCase();
    final canReview = statusEbook == 'beri rating';

    // Get or create controller
    final controller = Get.put(BookDetailController());

    // Fetch reviews if not already loaded
    if (idEbook.isNotEmpty) {
      controller.fetchReviews(idEbook);
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rating & Ulasan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reviews List
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    ? (review['nama_user']?.substring(0, 1) ??
                                            '-') +
                                        '*****'
                                    : (review['nama_user'] ?? '-');
                                final date =
                                    review['created_at']?.split(' ')?.first ??
                                        '';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
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
                              }),
                            ],
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text('Belum ada ulasan',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          );
                        }
                      }),

                      // Review Form (only if can review)
                      if (canReview) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        _ReviewForm(idEbook: idEbook),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadBonusBook(String url, String displayName) async {
    // Check if already downloading
    if (downloadingFiles[url] == true) {
      return;
    }

    // Request storage permission
    if (Platform.isAndroid) {
      // For Android 10 and below
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      // For Android 11+ (API 30+), also request manage external storage
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }

      // Note: We'll proceed even if permission is not granted
      // The app will use app-specific directory (scoped storage) if needed
    }

    setState(() {
      downloadingFiles[url] = true;
    });

    try {
      // Get download directory
      Directory directory;
      if (Platform.isAndroid) {
        // Try to use Downloads directory first
        try {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            directory = downloadsDir;
          } else {
            // Fallback to app external storage directory
            directory = await getExternalStorageDirectory() ??
                await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          // If access denied, use app documents directory (scoped storage)
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        // For iOS, use app documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      // Create ebook folder if not exists
      final ebookDir = Directory('${directory.path}/ebook_amd');
      if (!await ebookDir.exists()) {
        await ebookDir.create(recursive: true);
      }

      // Get file name
      final fileName = _getFileNameForDownload(url);
      final filePath = '${ebookDir.path}/$fileName';

      // Check if file already exists
      final file = File(filePath);
      if (await file.exists()) {
        setState(() {
          downloadingFiles[url] = false;
        });
        Get.snackbar(
          'File Sudah Ada',
          'File sudah tersedia di: $filePath',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Download file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Save file
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          downloadingFiles[url] = false;
        });

        Get.snackbar(
          'Download Berhasil',
          'File tersimpan di: ${Platform.isAndroid ? "Download/ebook_amd" : "Dokumen/ebook_amd"}/$fileName',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        setState(() {
          downloadingFiles[url] = false;
        });
        Get.snackbar(
          'Download Gagal',
          'Gagal mengunduh file. Status: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        downloadingFiles[url] = false;
      });
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
                            const Text('Deskripsi',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            _ExpandableText(text: detail!['sinopsis'] ?? '-'),
                            const SizedBox(height: 80),
                            // SPESIFIKASI / INFORMASI BUKU
                            const SizedBox(height: 8),
                            const Text('Informasi Buku',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 16),
                            if (detail!['info'] != null &&
                                detail!['info'] is List)
                              _BookInfoSection(
                                  infoList: detail!['info'] as List),
                            const SizedBox(height: 16),
                            // DESKRIPSI
                            // Untuk ruang tombol bawah
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
                            child: Container(
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
                                  // Tombol Baca Ebook
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.only(
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
                                            final url =
                                                detail!['file_ebook_pdf']
                                                    .toString();
                                            Get.to(
                                                () => _PDFViewerPage(url: url));
                                          },
                                          child: const Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.menu_book,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Baca Ebook',
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
                                  ),
                                  // Divider
                                  Container(
                                    width: 1,
                                    height: 35,
                                    color: Colors.grey[300],
                                  ),
                                  // Tombol Rating/Ulasan
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
                                            _showRatingDialog(detail!);
                                          },
                                          child: const Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Rating/Ulasan',
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
                                  ),
                                ],
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

class _PDFViewerPage extends StatefulWidget {
  final String url;
  const _PDFViewerPage({required this.url});

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
      appBar: AppBar(title: const Text('Baca Ebook')),
      body: SfPdfViewer.network(
        pdfUrl,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          print('PDF Load Error: ${details.error}');
          Get.snackbar(
            'Error',
            'Gagal memuat ebook',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
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
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

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
                    label: const Text(
                      'Kirim',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                              Get.snackbar(
                                'Peringatan',
                                'Pilih rating terlebih dahulu!',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
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
                              Get.snackbar(
                                'Berhasil',
                                'Buku berhasil direview',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                              setState(() {
                                rating = 0;
                                reviewController.clear();
                                isHide = false;
                              });
                              // Refresh reviews
                              controller.fetchReviews(widget.idEbook);
                            } else {
                              final msg =
                                  res?['message'] ?? 'Gagal mengirim review';
                              Get.snackbar(
                                'Error',
                                msg,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
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
