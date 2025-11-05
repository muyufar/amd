import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme_utils.dart';
import '../../controllers/imprint_books_controller.dart';

class ImprintBooksPage extends StatefulWidget {
  final String imprintId;
  final String imprintName;
  const ImprintBooksPage({
    super.key,
    required this.imprintId,
    required this.imprintName,
  });

  @override
  State<ImprintBooksPage> createState() => _ImprintBooksPageState();
}

class _ImprintBooksPageState extends State<ImprintBooksPage> {
  bool isGrid = true;
  late final ImprintBooksController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(ImprintBooksController());
    controller.fetchBooks(widget.imprintId, reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.imprintName),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: isGrid ? 'Tampilan List' : 'Tampilan Grid',
            onPressed: () {
              setState(() {
                isGrid = !isGrid;
              });
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.books.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        } else if (controller.books.isEmpty) {
          return const Center(child: Text('Tidak ada data'));
        }
        final isLoadingMore = controller.isLoadingMore.value;
        final hasMore = controller.hasMore.value;
        final currentPage = controller.currentPage.value;

        if (isGrid) {
          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: controller.books.length,
                  itemBuilder: (context, index) {
                    final buku = controller.books[index];
                    return _BookCard(buku: buku);
                  },
                ),
              ),
              _buildPaginationControls(
                isLoadingMore: isLoadingMore,
                hasMore: hasMore,
                currentPage: currentPage,
                totalItems: controller.books.length,
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final buku = controller.books[index];
                    return _BookListTile(buku: buku);
                  },
                ),
              ),
              _buildPaginationControls(
                isLoadingMore: isLoadingMore,
                hasMore: hasMore,
                currentPage: currentPage,
                totalItems: controller.books.length,
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildPaginationControls({
    required bool isLoadingMore,
    required bool hasMore,
    required int currentPage,
    required int totalItems,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Halaman $currentPage • Total: $totalItems item',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (hasMore || currentPage > 1)
            Row(
              children: [
                if (currentPage > 1)
                  OutlinedButton.icon(
                    onPressed: isLoadingMore
                        ? null
                        : () {
                            controller.currentPage.value--;
                            controller.fetchBooks(widget.imprintId, reset: true);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            });
                          },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Sebelumnya'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                if (currentPage > 1 && hasMore) const SizedBox(width: 8),
                if (hasMore)
                  ElevatedButton.icon(
                    onPressed: isLoadingMore
                        ? null
                        : () {
                            controller.loadMoreBooks(widget.imprintId);
                          },
                    icon: isLoadingMore
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.arrow_forward, size: 16),
                    label: Text(isLoadingMore ? 'Memuat...' : 'Selanjutnya'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      backgroundColor: colorPrimary,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Map<String, dynamic> buku;
  const _BookCard({required this.buku});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: InkWell(
        onTap: () {
          Get.toNamed('/book-detail',
              parameters: {'slug': buku['slug_barang'] ?? ''});
        },
        borderRadius: borderRadiusTheme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      buku['penulis'] ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      buku['judul'] ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${buku['harga'] ?? '-'}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
  }
}

class _BookListTile extends StatelessWidget {
  final Map<String, dynamic> buku;
  const _BookListTile({required this.buku});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 50,
            height: 70,
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
        title: Text(
          buku['judul'] ?? '-',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Rp ${buku['harga'] ?? '-'}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorBlack,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        onTap: () {
          Get.toNamed('/book-detail',
              parameters: {'slug': buku['slug_barang'] ?? ''});
        },
      ),
    );
  }
}

