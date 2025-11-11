import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bookshelf_controller.dart';
import '../../utils/theme_utils.dart';
import 'bookshelf_detail_page.dart';
import '../../widgets/loading_animations.dart';
import '../../services/book_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage>
    with SingleTickerProviderStateMixin {
  final BookshelfController controller = Get.put(BookshelfController());
  final BookService bookService = BookService();
  late TabController _tabController;
  bool isGrid = false;

  // Bonus books state
  List<Map<String, dynamic>> bonusBooks = [];
  bool isLoadingBonus = false;
  String errorBonus = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller.fetchBukuOwned();
    _fetchBonusBooks();

    _tabController.addListener(() {
      if (_tabController.index == 1 && bonusBooks.isEmpty && !isLoadingBonus) {
        _fetchBonusBooks();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBonusBooks() async {
    setState(() {
      isLoadingBonus = true;
      errorBonus = '';
    });
    try {
      final data = await bookService.fetchBonusBooks();
      setState(() {
        bonusBooks = data;
        isLoadingBonus = false;
      });
    } catch (e) {
      setState(() {
        errorBonus = e.toString();
        isLoadingBonus = false;
      });
    }
  }

  Future<void> _refresh() async {
    if (_tabController.index == 0) {
      controller.fetchBukuOwned();
    } else {
      _fetchBonusBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksi Bukumu'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Buku Berbayar'),
            Tab(text: 'Bonus Buku'),
          ],
        ),
        actions: [
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              if (_tabController.index == 0) {
                return IconButton(
                  icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
                  tooltip: isGrid ? 'Tampilan List' : 'Tampilan Grid',
                  onPressed: () {
                    setState(() {
                      isGrid = !isGrid;
                    });
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Buku Berbayar
          _buildBerbayarTab(),
          // Tab 2: Bonus Buku
          _buildBonusTab(),
        ],
      ),
    );
  }

  Widget _buildBerbayarTab() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Obx(() {
        if (controller.isLoading.value) {
          return LoadingAnimations.buildBookshelfLoading();
        } else if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        } else if (controller.bukuOwned.isEmpty) {
          return const Center(child: Text('Belum ada buku yang dimiliki.'));
        }
        if (isGrid) {
          // GridView mode
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: controller.bukuOwned.length,
            itemBuilder: (context, index) {
              final buku = controller.bukuOwned[index];
              String slug = '';
              if (buku.containsKey('slug_ebook')) {
                slug = buku['slug_ebook'] ?? '';
              }
              return InkWell(
                onTap: () {
                  print('DEBUG: Buku dipilih: $buku');
                  print('DEBUG: Key tersedia: ${buku.keys}');
                  print('DEBUG: Slug yang digunakan: $slug');
                  if (slug.isNotEmpty) {
                    Get.to(() => BookshelfDetailPage(slug: slug));
                  } else {
                    print(
                        'ERROR: Tidak menemukan slug_ebook yang valid untuk navigasi detail.');
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 160,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: borderRadiusTheme,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: colorTextGrey.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover Image full width
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: Image.network(
                            buku['gambar1'] ?? '',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: colorGrey.withOpacity(0.2),
                              child: Icon(Icons.broken_image, color: colorGrey),
                            ),
                          ),
                        ),
                      ),
                      // Book details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                buku['judul'] ?? '-',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'Tahun: ${buku['tahun'] ?? '-'}',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 11,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'Ditambahkan: ${buku['rak_created_at'] != null && buku['rak_created_at'].toString().length >= 10 ? buku['rak_created_at'].toString().substring(0, 10) : '-'}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          // ListView mode (seperti sebelumnya)
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.bukuOwned.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final buku = controller.bukuOwned[index];
              String slug = '';
              if (buku.containsKey('slug_ebook')) {
                slug = buku['slug_ebook'] ?? '';
              }
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: borderRadiusTheme,
                  boxShadow: [boxShadow],
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      buku['gambar1'] ?? '',
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 70,
                        color: colorGrey.withOpacity(0.2),
                        child: Icon(Icons.broken_image, color: colorGrey),
                      ),
                    ),
                  ),
                  title: Text(buku['judul'] ?? '-',
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tahun: ${buku['tahun'] ?? '-'}',
                          style: textTheme.bodySmall),
                      Text(
                        'Ditambahkan : ${buku['rak_created_at'] != null && buku['rak_created_at'].toString().length >= 10 ? buku['rak_created_at'].toString().substring(0, 10) : '-'}',
                        style:
                            textTheme.bodySmall?.copyWith(color: colorPrimary),
                      ),
                    ],
                  ),
                  onTap: () {
                    print('DEBUG: Buku dipilih: $buku');
                    print('DEBUG: Key tersedia: ${buku.keys}');
                    print('DEBUG: Slug yang digunakan: $slug');
                    if (slug.isNotEmpty) {
                      Get.to(() => BookshelfDetailPage(slug: slug));
                    } else {
                      print(
                          'ERROR: Tidak menemukan slug_ebook yang valid untuk navigasi detail.');
                    }
                  },
                ),
              );
            },
          );
        }
      }),
    );
  }

  Widget _buildBonusTab() {
    return RefreshIndicator(
      onRefresh: _fetchBonusBooks,
      child: _buildBonusContent(),
    );
  }

  Widget _buildBonusContent() {
    if (isLoadingBonus) {
      return LoadingAnimations.buildBookshelfLoading();
    } else if (errorBonus.isNotEmpty) {
      return Center(child: Text('Error: $errorBonus'));
    } else if (bonusBooks.isEmpty) {
      return LoadingAnimations.buildEmptyBonusBooks();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemCount: bonusBooks.length,
      itemBuilder: (context, index) {
        final bonus = bonusBooks[index];
        return InkWell(
          onTap: () {
            final fileUrl = bonus['file']?.toString() ?? '';
            if (fileUrl.isNotEmpty) {
              Get.to(() => _BonusPDFViewerPage(url: fileUrl));
            } else {
              Get.snackbar(
                'Error',
                'File PDF tidak tersedia',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: borderRadiusTheme,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: colorTextGrey.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.network(
                      bonus['cover'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colorGrey.withOpacity(0.2),
                        child: Icon(Icons.broken_image, color: colorGrey),
                      ),
                    ),
                  ),
                ),
                // Title
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bonus['title'] ?? '-',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BonusPDFViewerPage extends StatelessWidget {
  final String url;
  const _BonusPDFViewerPage({required this.url});

  @override
  Widget build(BuildContext context) {
    final pdfUrl = url.startsWith('http') ? url : 'http://$url';
    return Scaffold(
      appBar: AppBar(title: const Text('Baca Bonus Buku')),
      body: SfPdfViewer.network(
        pdfUrl,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          print('PDF Load Error: ${details.error}');
          Get.snackbar(
            'Error',
            'Gagal memuat bonus buku',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      ),
    );
  }
}
