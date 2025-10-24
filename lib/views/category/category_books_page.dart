import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_books_controller.dart';

class CategoryBooksPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryBooksPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryBooksPage> createState() => _CategoryBooksPageState();
}

class _CategoryBooksPageState extends State<CategoryBooksPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  final CategoryBooksController controller = Get.put(CategoryBooksController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Add scroll listener for auto-load
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoading.value &&
          controller.hasMoreData.value) {
        controller.loadMoreBooks();
      }
    });

    // Fetch books
    controller.fetchBooksByCategory(
      idKategori: widget.categoryId,
      namaKategori: widget.categoryName,
      refresh: true,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.books.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.error.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchBooksByCategory(
                    idKategori: widget.categoryId,
                    namaKategori: widget.categoryName,
                    refresh: true,
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.books.isEmpty) {
          return _buildNotFoundAnimation();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchBooksByCategory(
            idKategori: widget.categoryId,
            namaKategori: widget.categoryName,
            refresh: true,
          ),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.books.length +
                (controller.hasMoreData.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.books.length) {
                return _buildLoadMoreIndicator();
              }

              final book = controller.books[index];
              return _buildBookCard(book);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotFoundAnimation() {
    _animationController.forward();

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated book icon
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.menu_book_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Buku',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada buku dalam kategori ini',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Memuat buku...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }

      if (!controller.hasMoreData.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Semua buku telah dimuat',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final double rating =
        double.tryParse(book['rating']?.toString() ?? '0') ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/book-detail',
              parameters: {'slug': book['slug_barang']});
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Book cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book['gambar1'] ?? '',
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 120,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey[400]),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['judul'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Rating
                    Row(
                      children: [
                        ...List.generate(
                            5,
                            (i) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color: i < rating
                                      ? Colors.amber
                                      : Colors.grey[300],
                                )),
                        const SizedBox(width: 8),
                        Text(
                          '(${book['jumlah_rating'] ?? '0'})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Row(
                      children: [
                        if (book['diskon'] != null && book['diskon'] > 0) ...[
                          Text(
                            'Rp ${book['diskon_price']?.toString() ?? '-'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rp ${book['harga']?.toString() ?? '-'}',
                            style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Rp ${book['harga']?.toString() ?? '-'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terjual: ${book['jumlah_terjual'] ?? '0'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
