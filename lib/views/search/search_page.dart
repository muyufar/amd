import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme_utils.dart';
import '../../controllers/search_controller.dart' as search_controller;
import '../../widgets/loading_animations.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final search_controller.SearchController controller =
        Get.find<search_controller.SearchController>();
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: BoxDecoration(
            color: colorPrimary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Pencarian Ebook',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // agar judul tetap center
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: borderRadiusTheme,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Icon(Icons.search, color: colorGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: 'Cari buku, penulis, atau penerbit',
                              border: InputBorder.none,
                            ),
                            style: textTheme.bodyMedium,
                            onChanged: (value) {
                              controller.setKeyword(value);
                            },
                            onSubmitted: (value) {
                              controller.setKeyword(value);
                            },
                          ),
                        ),
                        if (controller.keyword.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, color: colorGrey),
                            onPressed: () {
                              searchController.clear();
                              controller.resetSearch();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.keyword.isEmpty) {
          return _buildEmptyState();
        }

        if (controller.isLoading) {
          return Center(
            child: LoadingAnimations.buildCompactLoading(
              text: 'Mencari buku...',
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorGrey),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage,
                  style: textTheme.bodyMedium?.copyWith(color: colorGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.setKeyword(controller.keyword),
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: colorGrey),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada hasil untuk "${controller.keyword}"',
                  style: textTheme.bodyMedium?.copyWith(color: colorGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Coba kata kunci yang berbeda',
                  style: textTheme.bodySmall?.copyWith(color: colorGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildFilterSectionHeader(controller),
            _buildResultsHeader(controller),
            Expanded(
              child: _buildSearchResults(controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: colorGrey),
          const SizedBox(height: 16),
          Text(
            'Mulai pencarian Anda',
            style: textTheme.titleMedium?.copyWith(
              color: colorGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cari buku, penulis, atau penerbit',
            style: textTheme.bodyMedium?.copyWith(color: colorGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSectionHeader(
      search_controller.SearchController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: colorGrey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _showFilterBottomSheet(controller),
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: colorPrimary),
                const SizedBox(width: 8),
                Text(
                  'Filter',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _showFilterBottomSheet(controller),
            child: Text(
              'Terapkan Filter',
              style: TextStyle(color: colorPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(search_controller.SearchController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${controller.totalResults} hasil ditemukan',
            style: textTheme.bodyMedium?.copyWith(
              color: colorGrey,
            ),
          ),
          if (controller.filters.isNotEmpty)
            TextButton(
              onPressed: () => controller.clearAllFilters(),
              child: Text(
                'Hapus Filter',
                style: TextStyle(color: colorPrimary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(search_controller.SearchController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount:
          controller.searchResults.length + (controller.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.searchResults.length) {
          // Load more button
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: controller.isLoading
                  ? LoadingAnimations.buildCompactLoading(
                      text: 'Memuat lebih banyak...',
                    )
                  : ElevatedButton(
                      onPressed: () => controller.loadMoreResults(),
                      child: Text('Muat Lebih Banyak'),
                    ),
            ),
          );
        }

        final book = controller.searchResults[index];
        return _buildBookCard(book);
      },
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final double rating =
        double.tryParse(book['rating']?.toString() ?? '0') ?? 0.0;
    final int harga = book['harga'] ?? 0;
    final int diskon = book['diskon'] ?? 0;
    final int diskonPrice = book['diskon_price'] ?? 0;
    final bool hasDiscount = diskon > 0 && diskonPrice > 0;

    return Container(
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
              parameters: {'slug': book['slug_barang'] ?? ''});
        },
        borderRadius: borderRadiusTheme,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: colorGrey.withOpacity(0.2),
                    child: Icon(Icons.broken_image, color: colorGrey),
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
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book['penulis'] ?? '-',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorGrey,
                      ),
                      maxLines: 1,
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
                                  color:
                                      i < rating ? Colors.amber : colorTextGrey,
                                )),
                        const SizedBox(width: 8),
                        Text(
                          '(${book['jumlah_rating'] ?? 0})',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Row(
                      children: [
                        if (hasDiscount) ...[
                          Text(
                            'Rp ${diskonPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rp ${harga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorGrey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Rp ${harga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terjual: ${book['jumlah_terjual'] ?? 0}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorGrey,
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

  void _showFilterBottomSheet(search_controller.SearchController controller) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Pencarian',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clearAllFilters();
                      Get.back();
                    },
                    child: Text('Reset'),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Filter content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sort by
                    _buildFilterOptions(
                      'Urutkan',
                      [
                        {'value': 'terbaru', 'label': 'Terbaru'},
                        {'value': 'terlama', 'label': 'Terlama'},
                        {
                          'value': 'harga_tertinggi',
                          'label': 'Harga Tertinggi'
                        },
                        {'value': 'harga_terendah', 'label': 'Harga Terendah'},
                        {
                          'value': 'rating_tertinggi',
                          'label': 'Rating Tertinggi'
                        },
                      ],
                      controller.filters['sortBy'],
                      (value) => controller.setFilter('sortBy', value),
                    ),
                    const SizedBox(height: 24),
                    // Category
                    _buildFilterOptions(
                      'Kategori',
                      controller.kategoriOptions
                          .map((kategori) => {
                                'value': kategori['id'],
                                'label': kategori['name'],
                              })
                          .toList(),
                      controller.filters['kategori'],
                      (value) => controller.setFilter('kategori', value),
                    ),
                    const SizedBox(height: 24),
                    // Author
                    _buildFilterOptions(
                      'Penulis',
                      controller.penulisOptions
                          .map((penulis) => {
                                'value': penulis['id'],
                                'label':
                                    '${penulis['name']} (${penulis['count']})',
                              })
                          .toList(),
                      controller.filters['penulis'],
                      (value) {
                        final currentPenulis = List<String>.from(
                            controller.filters['penulis'] ?? []);
                        if (currentPenulis.contains(value)) {
                          currentPenulis.remove(value);
                        } else {
                          currentPenulis.add(value);
                        }
                        controller.setFilter('penulis', currentPenulis);
                      },
                      isMultiSelect: true,
                    ),
                    const SizedBox(height: 24),
                    // Publisher
                    _buildFilterOptions(
                      'Penerbit',
                      controller.penerbitOptions
                          .map((penerbit) => {
                                'value': penerbit['id'],
                                'label':
                                    '${penerbit['name'] ?? 'Tidak diketahui'} (${penerbit['count']})',
                              })
                          .toList(),
                      controller.filters['penerbit'],
                      (value) => controller.setFilter('penerbit', value),
                    ),
                    const SizedBox(height: 24),
                    // Price range
                    Text(
                      'Harga Minimum',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Masukkan harga minimum',
                        border: OutlineInputBorder(
                          borderRadius: borderRadiusTheme,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          controller.setFilter('hargaMin', int.tryParse(value));
                        } else {
                          controller.removeFilter('hargaMin');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Apply button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.loadFilters();
                    Get.back();
                  },
                  child: Text('Terapkan Filter'),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFilterOptions(
    String title,
    List<Map<String, dynamic>> options,
    dynamic currentValue,
    Function(dynamic) onChanged, {
    bool isMultiSelect = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = isMultiSelect
                ? (currentValue as List?)?.contains(option['value'])
                : currentValue == option['value'];

            return FilterChip(
              label: Text(option['label']),
              selected: isSelected ?? false,
              onSelected: (selected) {
                onChanged(option['value']);
              },
              selectedColor: colorPrimary.withOpacity(0.2),
              checkmarkColor: colorPrimary,
            );
          }).toList(),
        ),
      ],
    );
  }
}
