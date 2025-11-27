import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import 'category_books_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late ScrollController _scrollController;
  late CategoryController controller;
  bool _showScrollToTop = false;
  bool _isLoadingMore = false;
  DateTime? _lastLoadMoreTime;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Initialize controller with fallback
    try {
      controller = Get.find<CategoryController>();
    } catch (e) {
      print(
          '🔍 [CATEGORY PAGE] Controller not found, creating new instance: $e');
      controller = Get.put(CategoryController());
    }

    // Add scroll listener for infinite scroll and scroll to top button
    _scrollController.addListener(() {
      // Show/hide scroll to top button
      if (_scrollController.position.pixels > 200) {
        if (!_showScrollToTop) {
          setState(() {
            _showScrollToTop = true;
          });
        }
      } else {
        if (_showScrollToTop) {
          setState(() {
            _showScrollToTop = false;
          });
        }
      }

      // Infinite scroll - load more when near bottom
      // Only check if scroll position is valid and not at the very beginning
      if (!_scrollController.hasClients ||
          _scrollController.position.maxScrollExtent <= 0) {
        return;
      }

      final threshold = _scrollController.position.maxScrollExtent - 200;
      if (_scrollController.position.pixels >= threshold) {
        // Prevent multiple calls with debounce (1000ms - increased)
        final now = DateTime.now();
        if (_lastLoadMoreTime != null &&
            now.difference(_lastLoadMoreTime!).inMilliseconds < 1000) {
          return;
        }

        // Prevent multiple simultaneous load more calls
        if (_isLoadingMore) {
          return;
        }

        if (controller.isShowingChildCategories) {
          // Load more books when showing child categories
          if (!controller.isLoadingBooks.value &&
              controller.hasMoreBooks.value &&
              !_isLoadingMore) {
            _isLoadingMore = true;
            _lastLoadMoreTime = now;
            print('🔄 [CATEGORY PAGE] Triggering loadMoreBooks');
            controller.loadMoreBooks().then((_) {
              _isLoadingMore = false;
            }).catchError((e) {
              print('🔴 [CATEGORY PAGE] Error loading more books: $e');
              _isLoadingMore = false;
            });
          }
        } else {
          // Load more parent categories
          if (!controller.isLoading.value &&
              controller.hasMoreData.value &&
              !_isLoadingMore) {
            _isLoadingMore = true;
            _lastLoadMoreTime = now;
            print('🔄 [CATEGORY PAGE] Triggering loadMoreParentCategories');
            controller.loadMoreParentCategories().then((_) {
              _isLoadingMore = false;
            }).catchError((e) {
              print('🔴 [CATEGORY PAGE] Error loading more categories: $e');
              _isLoadingMore = false;
            });
          }
        }
      }
    });
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
        title: Obx(() => Text(controller.isShowingChildCategories
            ? controller.selectedParentName.value
            : 'Kategori Buku')),
        leading: Obx(() => controller.isShowingChildCategories
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  controller.resetToParentCategories();
                  // Scroll to top
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
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              )),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.parentCategories.isEmpty) {
          return _buildLoadingAnimation();
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
                  onPressed: () =>
                      controller.fetchParentCategories(reset: true),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            _buildCombinedContent(),
            // Scroll to top button - only show when scrolled down
            if (_showScrollToTop)
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.keyboard_arrow_up),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildCombinedContent() {
    return Obx(() {
      if (controller.isShowingChildCategories) {
        return _buildChildCategoriesAndBooks();
      } else {
        return _buildParentCategories();
      }
    });
  }

  Widget _buildParentCategories() {
    return Obx(() {
      final categories = controller.parentCategories;

      if (categories.isEmpty && !controller.isLoading.value) {
        return const Center(
          child: Text('Tidak ada kategori tersedia'),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchParentCategories(reset: true),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: categories.length + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return _buildLoadMoreParentCategories();
            }
            final category = categories[index];
            return _buildCategoryItem(category);
          },
        ),
      );
    });
  }

  Widget _buildChildCategoriesAndBooks() {
    return Obx(() {
      // Show loading animation when fetching child categories
      if (controller.isLoading.value &&
          controller.childCategories.isEmpty &&
          controller.categoryBooks.isEmpty) {
        return _buildLoadingSubCategories();
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchChildCategories(
          controller.selectedParentId.value,
          controller.selectedParentName.value,
          reset: true,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Child Categories Section
            if (controller.childCategories.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Subkategori',
                  controller.childCategories.length,
                  Icons.category,
                ),
              ),
            if (controller.childCategories.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = controller.childCategories[index];
                      return _buildChildCategoryItem(category);
                    },
                    childCount: controller.childCategories.length,
                  ),
                ),
              ),

            // Books Section
            if (controller.categoryBooks.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Buku dalam Kategori',
                  controller.categoryBooks.length,
                  Icons.menu_book,
                ),
              ),
            if (controller.categoryBooks.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == controller.categoryBooks.length) {
                        return _buildLoadMoreBooks();
                      }
                      final book = controller.categoryBooks[index];
                      return _buildBookItem(book);
                    },
                    childCount: controller.categoryBooks.length +
                        (controller.hasMoreBooks.value ? 1 : 0),
                  ),
                ),
              ),

            // Empty state if no data
            if (controller.childCategories.isEmpty &&
                controller.categoryBooks.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final isParent = !controller.isShowingChildCategories;
    final hasChild = isParent && (category['isHasChild'] == 1);
    final totalChild = category['totalChild'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            isParent ? Icons.category : Icons.folder,
            color: Colors.blue,
            size: 24,
          ),
        ),
        title: Text(
          category['nama_kategori'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: isParent && hasChild
            ? Text('$totalChild subkategori tersedia')
            : null,
        trailing: isParent && hasChild
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        onTap: () {
          if (isParent && hasChild) {
            controller.fetchChildCategories(
              category['id_kategori'],
              category['nama_kategori'],
              reset: true,
            );
          } else {
            // Navigate to books in this category
            _navigateToCategoryBooks(category);
          }
        },
      ),
    );
  }

  void _navigateToCategoryBooks(Map<String, dynamic> category) {
    Get.to(() => CategoryBooksPage(
          categoryId: category['id_kategori'],
          categoryName: category['nama_kategori'],
        ));
  }

  Widget _buildSectionHeader(String title, int count, IconData icon) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  '$count item tersedia',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCategoryItem(Map<String, dynamic> category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.folder, color: Colors.green, size: 20),
        ),
        title: Text(
          category['nama_kategori'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => _navigateToCategoryBooks(category),
      ),
    );
  }

  Widget _buildBookItem(Map<String, dynamic> book) {
    final double rating =
        double.tryParse(book['rating']?.toString() ?? '0') ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Book cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book['gambar1'] ?? '',
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey[400]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['judul'] ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    Row(
                      children: [
                        ...List.generate(
                            5,
                            (i) => Icon(
                                  Icons.star,
                                  size: 12,
                                  color: i < rating
                                      ? Colors.amber
                                      : Colors.grey[300],
                                )),
                        const SizedBox(width: 4),
                        Text(
                          '(${book['jumlah_rating'] ?? '0'})',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Price
                    Row(
                      children: [
                        if (book['diskon'] != null && book['diskon'] > 0) ...[
                          Text(
                            'Rp ${book['diskon_price']?.toString() ?? '-'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rp ${book['harga']?.toString() ?? '-'}',
                            style: TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Rp ${book['harga']?.toString() ?? '-'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildLoadMoreParentCategories() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (!controller.hasMoreData.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Semua kategori telah dimuat',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildLoadMoreBooks() {
    return Obx(() {
      if (controller.isLoadingBooks.value) {
        return _buildLoadingMoreBooks();
      }

      if (!controller.hasMoreBooks.value) {
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

  Widget _buildLoadingSubCategories() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated folder icon
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.3),
                        Colors.green.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.folder,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // Animated loading text
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  'Memuat Subkategori...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Animated progress indicator
          SizedBox(
            width: 200,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 3),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.green[100],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 4,
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Animated category items
          _buildAnimatedCategoryItems(),
        ],
      ),
    );
  }

  Widget _buildAnimatedCategoryItems() {
    return Column(
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 800 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.folder,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 16,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 12,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
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
          },
        );
      }),
    );
  }

  Widget _buildLoadingMoreBooks() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated book stack
          _buildAnimatedBookStack(),
          const SizedBox(height: 16),

          // Animated loading text
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: 0.5 + (0.5 * value),
                child: Text(
                  'Memuat buku...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[600],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Animated progress bar
          SizedBox(
            width: 150,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.blue[100],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 3,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBookStack() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 800 + (index * 300)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -10 * (1 - value)),
              child: Transform.scale(
                scale: 0.7 + (0.3 * value),
                child: Container(
                  margin: EdgeInsets.only(
                    left: index * 8.0,
                    right: index == 2 ? 0 : 8.0,
                  ),
                  child: Icon(
                    Icons.menu_book,
                    size: 20,
                    color: Colors.blue.withOpacity(0.3 + (0.7 * value)),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada subkategori atau buku dalam kategori ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated book icon
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.3),
                        Colors.blue.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // Animated loading text
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  'Memuat Kategori...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Animated progress indicator
          SizedBox(
            width: 200,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 3),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.blue[100],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 4,
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Animated dots
          _buildAnimatedDots(),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: 0.5 + (0.5 * value),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3 + (0.7 * value)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
