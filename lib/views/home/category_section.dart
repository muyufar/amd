import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../category/category_page.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller jika belum ada
    final categoryController = Get.put(CategoryController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kategori Buku',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => const CategoryPage()),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
        ),
        Obx(() {
          if (categoryController.isLoading.value &&
              categoryController.parentCategories.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (categoryController.error.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gagal memuat kategori',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          categoryController.fetchParentCategories(reset: true),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildCategoryGrid();
        }),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categoryController = Get.find<CategoryController>();
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryController.parentCategories.length,
        itemBuilder: (context, index) {
          final category = categoryController.parentCategories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final hasChild = category['isHasChild'] == 1;
    final totalChild = category['totalChild'] ?? 0;

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          if (hasChild) {
            Get.to(() => const CategoryPage());
          } else {
            _navigateToCategoryBooks(category);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.category,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['nama_kategori'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasChild) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$totalChild',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCategoryBooks(Map<String, dynamic> category) {
    // TODO: Implement navigation to books in category
    Get.snackbar(
      'Info',
      'Fitur pencarian buku berdasarkan kategori akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
