import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme_utils.dart';
import '../../controllers/home_controller.dart';

enum EbookListType { terbaru, terlaris }

class EbookListPage extends StatefulWidget {
  final String title;
  final EbookListType type;
  const EbookListPage({super.key, required this.title, required this.type});

  @override
  State<EbookListPage> createState() => _EbookListPageState();
}

class _EbookListPageState extends State<EbookListPage> {
  bool isGrid = true;
  late final HomeController controller;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  DateTime? _lastLoadMoreTime;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    if (widget.type == EbookListType.terbaru) {
      if (controller.bukuTerbaru.isEmpty) {
        controller.fetchBukuTerbaru(reset: true);
      }
    } else {
      if (controller.bukuTerlaris.isEmpty) {
        controller.fetchBukuTerlaris(reset: true);
      }
    }

    // Add scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent <= 0) {
      return;
    }

    // Check if scrolled near bottom (within 200 pixels)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreIfNeeded();
    }
  }

  void _loadMoreIfNeeded() async {
    // Debounce: prevent multiple calls within 1 second
    final now = DateTime.now();
    if (_lastLoadMoreTime != null &&
        now.difference(_lastLoadMoreTime!) < const Duration(seconds: 1)) {
      return;
    }

    if (_isLoadingMore) return;

    final hasMore = widget.type == EbookListType.terbaru
        ? controller.hasMoreTerbaru.value
        : controller.hasMoreTerlaris.value;
    final isLoadingMore = widget.type == EbookListType.terbaru
        ? controller.isLoadingMoreTerbaru.value
        : controller.isLoadingMoreTerlaris.value;

    if (!hasMore || isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _lastLoadMoreTime = now;
    });

    try {
      if (widget.type == EbookListType.terbaru) {
        await controller.loadMoreBukuTerbaru();
      } else {
        await controller.loadMoreBukuTerlaris();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
        final isLoading = widget.type == EbookListType.terbaru
            ? controller.isLoadingTerbaru.value
            : controller.isLoadingTerlaris.value;
        final error = widget.type == EbookListType.terbaru
            ? controller.errorTerbaru.value
            : controller.errorTerlaris.value;
        final list = widget.type == EbookListType.terbaru
            ? controller.bukuTerbaru
            : controller.bukuTerlaris;
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (error.isNotEmpty) {
          return Center(child: Text(error));
        } else if (list.isEmpty) {
          return const Center(child: Text('Tidak ada data'));
        }
        final isLoadingMore = widget.type == EbookListType.terbaru
            ? controller.isLoadingMoreTerbaru.value
            : controller.isLoadingMoreTerlaris.value;
        final hasMore = widget.type == EbookListType.terbaru
            ? controller.hasMoreTerbaru.value
            : controller.hasMoreTerlaris.value;

        if (isGrid) {
          return RefreshIndicator(
            onRefresh: () async {
              if (widget.type == EbookListType.terbaru) {
                controller.fetchBukuTerbaru(reset: true);
                // Wait for loading to complete
                while (controller.isLoadingTerbaru.value) {
                  await Future.delayed(const Duration(milliseconds: 100));
                }
              } else {
                controller.fetchBukuTerlaris(reset: true);
                // Wait for loading to complete
                while (controller.isLoadingTerlaris.value) {
                  await Future.delayed(const Duration(milliseconds: 100));
                }
              }
            },
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemCount: list.length + (hasMore && isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == list.length) {
                  return _buildLoadMoreIndicator(isLoadingMore);
                }
                final buku = list[index];
                return _BookCard(buku: buku);
              },
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              if (widget.type == EbookListType.terbaru) {
                controller.fetchBukuTerbaru(reset: true);
                // Wait for loading to complete
                while (controller.isLoadingTerbaru.value) {
                  await Future.delayed(const Duration(milliseconds: 100));
                }
              } else {
                controller.fetchBukuTerlaris(reset: true);
                // Wait for loading to complete
                while (controller.isLoadingTerlaris.value) {
                  await Future.delayed(const Duration(milliseconds: 100));
                }
              }
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: list.length + (hasMore && isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == list.length) {
                  return _buildLoadMoreIndicator(isLoadingMore);
                }
                final buku = list[index];
                return _BookListTile(buku: buku);
              },
            ),
          );
        }
      }),
    );
  }

  Widget _buildLoadMoreIndicator(bool isLoadingMore) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
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
      width: 160,
      height: 280, // Fixed height to prevent overflow
      margin: const EdgeInsets.only(bottom: 16),
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
              parameters: {'slug': buku['slug_barang']});
        },
        borderRadius: borderRadiusTheme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image full width
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 180, // Fixed height untuk cover
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
                      buku['penulis'] ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w300,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                    // Book title
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

                    // Price
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
              parameters: {'slug': buku['slug_barang']});
        },
      ),
    );
  }
}
