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

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    if (widget.type == EbookListType.terbaru) {
      if (controller.bukuTerbaru.isEmpty) {
        controller.fetchBukuTerbaru();
      }
    } else {
      if (controller.bukuTerlaris.isEmpty) {
        controller.fetchBukuTerlaris();
      }
    }
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
        if (isGrid) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final buku = list[index];
              return _BookCard(buku: buku);
            },
          );
        } else {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final buku = list[index];
              return _BookListTile(buku: buku);
            },
          );
        }
      }),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Map<String, dynamic> buku;
  const _BookCard({required this.buku});

  @override
  Widget build(BuildContext context) {
    final double rating =
        double.tryParse(buku['rating']?.toString() ?? '0') ?? 0.0;
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
              parameters: {'slug': buku['slug_barang']});
        },
        borderRadius: borderRadiusTheme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                buku['gambar1'] ?? '',
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 130,
                  width: double.infinity,
                  color: colorGrey.withOpacity(0.2),
                  child: Icon(Icons.broken_image, color: colorGrey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    buku['judul'] ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp ${buku['harga'] ?? '-'}',
                    style: textTheme.bodyMedium?.copyWith(
                        color: colorBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text('Terjual: ${buku['jumlah_terjual'] ?? '0'}',
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorGrey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                              Icons.star,
                              size: 20,
                              color: i < rating ? Colors.amber : colorTextGrey,
                            )),
                  ),
                  const SizedBox(height: 8),
                ],
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
    final double rating =
        double.tryParse(buku['rating']?.toString() ?? '0') ?? 0.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadiusTheme,
        boxShadow: [boxShadow],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        title: Text(
          buku['judul'] ?? '-',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rp ${buku['harga'] ?? '-'}',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            Text('Terjual: ${buku['jumlah_terjual'] ?? '0'}',
                style: textTheme.bodySmall),
            Row(
              children: List.generate(
                  5,
                  (i) => Icon(Icons.star,
                      size: 16,
                      color: i < rating ? Colors.amber : Colors.grey)),
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
