import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wishlist_controller.dart';
import '../book_detail/book_detail_page.dart';
import '../../utils/theme_utils.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  bool isGrid = false;

  @override
  Widget build(BuildContext context) {
    final WishlistController controller = Get.put(WishlistController());
    // Refresh otomatis saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchWishlist();
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
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
          return const Center(child: CircularProgressIndicator());
        } else if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        } else if (controller.wishlist.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 72, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Whsilist Belum ada silahkan cari Buku',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }
        if (isGrid) {
          // GridView mode
          return RefreshIndicator(
            onRefresh: controller.fetchWishlist,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemCount: controller.wishlist.length,
              itemBuilder: (context, index) {
                final raw = controller.wishlist[index];
                if (raw is! Map<String, dynamic>) {
                  return const SizedBox.shrink();
                }
                final item = raw;
                final harga =
                    int.tryParse((item['harga'] ?? '0').toString()) ?? 0;
                final diskon =
                    int.tryParse((item['diskon'] ?? '0').toString()) ?? 0;
                final hargaDiskon = harga - (harga * diskon ~/ 100);
                final slug = (item['slug_barang'] ?? item['slug_ebook'] ?? '')
                    .toString();
                return InkWell(
                  onTap: () {
                    print('DEBUG: Tap wishlist, slug: $slug');
                    if (slug.isNotEmpty) {
                      Get.toNamed('/book-detail', parameters: {'slug': slug});
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
                            (item['gambar1'] ?? '').toString(),
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
                                (item['judul'] ?? '-').toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 1),
                              if (diskon > 0)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Rp${harga.toString()}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontSize: 13,
                                            )),
                                        const SizedBox(width: 8),
                                        Text('Rp${hargaDiskon.toString()}',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('Diskon: $diskon%',
                                        style:
                                            const TextStyle(color: Colors.red)),
                                  ],
                                )
                              else
                                Text('Rp${harga.toString()}',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              if (item['tahun'] != null)
                                Text('Tahun: ${item['tahun']}',
                                    style: textTheme.bodySmall),
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
          // ListView mode
          return RefreshIndicator(
            onRefresh: controller.fetchWishlist,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.wishlist.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final raw = controller.wishlist[index];
                if (raw is! Map<String, dynamic>) {
                  return const SizedBox.shrink();
                }
                final item = raw;
                final harga =
                    int.tryParse((item['harga'] ?? '0').toString()) ?? 0;
                final diskon =
                    int.tryParse((item['diskon'] ?? '0').toString()) ?? 0;
                final hargaDiskon = harga - (harga * diskon ~/ 100);
                final slug = (item['slug_barang'] ?? item['slug_ebook'] ?? '')
                    .toString();
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: borderRadiusTheme,
                    boxShadow: [boxShadow],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        (item['gambar1'] ?? '').toString(),
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
                    title: Text(
                      (item['judul'] ?? '-').toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (diskon > 0)
                          Row(
                            children: [
                              Text('Rp${harga.toString()}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 13,
                                  )),
                              const SizedBox(width: 8),
                              Text('Rp${hargaDiskon.toString()}',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text('Diskon: $diskon%',
                                  style: const TextStyle(color: Colors.red)),
                            ],
                          )
                        else
                          Text('Rp${harga.toString()}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        if (item['tahun'] != null)
                          Text('Tahun: ${item['tahun']}',
                              style: textTheme.bodySmall),
                      ],
                    ),
                    onTap: () {
                      print('DEBUG: Tap wishlist, slug: $slug');
                      if (slug.isNotEmpty) {
                        Get.toNamed('/book-detail', parameters: {'slug': slug});
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
