import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bookshelf_controller.dart';
import '../../utils/theme_utils.dart';
import 'bookshelf_detail_page.dart';
import '../../widgets/loading_animations.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  final BookshelfController controller = Get.put(BookshelfController());
  bool isGrid = false;

  @override
  void initState() {
    super.initState();
    controller.fetchBukuOwned();
  }

  Future<void> _refresh() async {
    controller.fetchBukuOwned();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksi Bukumu'),
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
        if (controller.isLoading.value) {
          return LoadingAnimations.buildBookshelfLoading();
        } else if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        } else if (controller.bukuOwned.isEmpty) {
          return const Center(child: Text('Belum ada buku yang dimiliki.'));
        }
        if (isGrid) {
          // GridView mode
          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: borderRadiusTheme,
                      boxShadow: [boxShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            buku['gambar1'] ?? '',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 150,
                              width: double.infinity,
                              color: colorGrey.withOpacity(0.2),
                              child: Icon(Icons.hide_image, color: colorGrey),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                buku['judul'] ?? '-',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 1),
                              Text('Tahun: ${buku['tahun'] ?? '-'}',
                                  style: textTheme.bodySmall),
                              const SizedBox(height: 4),
                              Text(
                                'Ditambahkan : ${buku['rak_created_at'] != null && buku['rak_created_at'].toString().length >= 10 ? buku['rak_created_at'].toString().substring(0, 10) : '-'}',
                                style: textTheme.bodySmall
                                    ?.copyWith(color: colorPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          // ListView mode (seperti sebelumnya)
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
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
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorPrimary),
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
            ),
          );
        }
      }),
    );
  }
}
