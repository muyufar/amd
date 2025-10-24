import 'package:andi_digital/views/profile/profile_page.dart';
import 'package:andi_digital/views/publisher/publisher_page.dart';
import 'package:andi_digital/views/wishlist/wishlist_page.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../utils/theme_utils.dart';
import '../bookshelf/bookshelf_page.dart';
import '../transaction/transaction_page.dart';
import 'package:palette_generator/palette_generator.dart';
import 'ebook_list_page.dart';
import '../category/category_page.dart';
import '../../widgets/loading_animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final HomeController controller = Get.find<HomeController>();
  final CartController cartController = Get.find<CartController>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print(
        '🟡 [HOME PAGE] Cart controller initialized, items: ${cartController.cartItems.length}');
  }

  final List<Widget> _pages = [
    HomeContent(),
    const _ProtectedPage(redirect: '/whislist', child: WishlistPage()),
    const _ProtectedPage(redirect: '/transaksi', child: TransactionPage()),
    const _ProtectedPage(redirect: '/bookshelf', child: BookshelfPage()),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (_selectedIndex != index) {
            setState(() => _selectedIndex = index);
          }
        },
        selectedItemColor: colorPrimary,
        unselectedItemColor: colorGrey,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.home,
                  size: 30, key: ValueKey(_selectedIndex == 0)),
            ),
            label: _selectedIndex == 0 ? 'Beranda' : '',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.favorite_border,
                  size: 30, key: ValueKey(_selectedIndex == 1)),
            ),
            label: _selectedIndex == 1 ? 'Favorit' : '',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.receipt_long,
                  size: 30, key: ValueKey(_selectedIndex == 2)),
            ),
            label: _selectedIndex == 2 ? 'Transaksi' : '',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.menu_book,
                  size: 30, key: ValueKey(_selectedIndex == 3)),
            ),
            label: _selectedIndex == 3 ? 'Buku' : '',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.person,
                  size: 30, key: ValueKey(_selectedIndex == 4)),
            ),
            label: _selectedIndex == 4 ? 'Profil' : '',
          ),
        ],
      ),
    );
  }
}

// Widget pembungkus untuk proteksi login
class _ProtectedPage extends StatelessWidget {
  final Widget child;
  final String redirect;
  const _ProtectedPage({required this.child, required this.redirect});

  @override
  Widget build(BuildContext context) {
    final token = GetStorage().read('token');
    if (token == null) {
      // Redirect ke login jika belum login
      Future.microtask(
          () => Get.offAllNamed('/login', parameters: {'redirect': redirect}));
      return const SizedBox.shrink();
    }
    return child;
  }
}

class HomeContent extends StatefulWidget {
  HomeContent({super.key});
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Color? bannerColor;
  Color? bannerColor2;
  String? currentBannerUrl;
  final HomeController controller = Get.find<HomeController>();
  final CartController cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    // Set url default sesuai banner pertama
    currentBannerUrl =
        'https://andipublisher.com/images/banner/1684211764_BANNER.jpeg';
    _updateBannerColor(currentBannerUrl!);
    // Refresh data home otomatis saat halaman dimuat
    controller.fetchBukuTerbaru();
    controller.fetchBukuTerlaris();
  }

  Future<void> _updateBannerColor(String url) async {
    final imageProvider = NetworkImage(url);
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    setState(() {
      bannerColor = paletteGenerator.dominantColor?.color ??
          Color.fromARGB(255, 255, 255, 255);
      bannerColor2 = paletteGenerator.colors.length > 1
          ? paletteGenerator.colors.elementAt(1)
          : bannerColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Search bar tetap di atas
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bannerColor ?? Color.fromARGB(255, 255, 255, 255),
                  bannerColor2 ?? Color.fromARGB(255, 255, 255, 255)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                children: [
                  // Search bar
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.search, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Cari buku, penulis, atau penerbit',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              readOnly: true,
                              onTap: () {
                                Get.toNamed('/search');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Cart Icon
                  GestureDetector(
                    onTap: () {
                      final token = GetStorage().read('token');
                      if (token == null) {
                        Get.toNamed('/login');
                      } else {
                        Get.toNamed('/cart');
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart,
                                  color: Colors.grey[700]),
                              const SizedBox(width: 4),
                              Text('${cartController.cartCount}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Konten scrollable (banner + konten lain)
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner sekarang ikut scroll
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 180,
                        child: currentBannerUrl != null
                            ? Image.network(
                                currentBannerUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  // Sembunyikan gradasi saat loading
                                  return Container(
                                    width: double.infinity,
                                    height: 160,
                                    color: Colors.grey[200],
                                    child: Center(
                                        child: LoadingAnimations
                                            .buildCompactLoading(
                                      text: 'Memuat kategori...',
                                      color: Colors.blue,
                                    )),
                                  );
                                },
                                frameBuilder: (context, child, frame,
                                    wasSynchronouslyLoaded) {
                                  if (frame != null && bannerColor == null) {
                                    _updateBannerColor(currentBannerUrl!);
                                  }
                                  return child;
                                },
                              )
                            : Container(
                                width: double.infinity,
                                height: 160,
                                color: Colors.grey[200],
                              ),
                      ),
                      const SizedBox(height: 24),
                      // Tombol kategori & penerbit
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.to(() => CategoryPage());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: colorPrimary,
                                  elevation: 0,
                                  side:
                                      BorderSide(color: colorPrimary, width: 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: borderRadiusTheme),
                                ),
                                child: Text('Kategori',
                                    style: textTheme.bodyMedium
                                        ?.copyWith(color: colorPrimary)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.to(() => PublisherPage());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: colorPrimary,
                                  elevation: 0,
                                  side:
                                      BorderSide(color: colorPrimary, width: 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: borderRadiusTheme),
                                ),
                                child: Text('Penerbit',
                                    style: textTheme.bodyMedium
                                        ?.copyWith(color: colorPrimary)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Section Terbaru
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Terbaru',
                                style: textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () {
                                Get.to(() => EbookListPage(
                                      title: 'Ebook Terbaru',
                                      type: EbookListType.terbaru,
                                    ));
                              },
                              child: Text('Lihat Semua',
                                  style: TextStyle(color: colorPrimary)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height:
                            290, // atau 270, atau lebih besar sesuai kebutuhan
                        child: Obx(() {
                          if (controller.isLoadingTerbaru.value) {
                            return LoadingAnimations.buildCompactLoading(
                              text: 'Memuat buku terbaru...',
                              color: Colors.green,
                            );
                          } else if (controller.errorTerbaru.value.isNotEmpty) {
                            return Center(
                                child: Text(controller.errorTerbaru.value));
                          } else if (controller.bukuTerbaru.isEmpty) {
                            return const Center(child: Text('Tidak ada data'));
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.bukuTerbaru.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final buku = controller.bukuTerbaru[index];
                              return BookCard(buku: buku);
                            },
                          );
                        }),
                      ),
                      // Section Terlaris
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Terlaris',
                                style: textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () {
                                Get.to(() => EbookListPage(
                                      title: 'Ebook Terlaris',
                                      type: EbookListType.terlaris,
                                    ));
                              },
                              child: Text('Lihat Semua',
                                  style: TextStyle(color: colorPrimary)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 290,
                        child: Obx(() {
                          if (controller.isLoadingTerlaris.value) {
                            return LoadingAnimations.buildCompactLoading(
                              text: 'Memuat buku terlaris...',
                              color: Colors.orange,
                            );
                          } else if (controller
                              .errorTerlaris.value.isNotEmpty) {
                            return Center(
                                child: Text(controller.errorTerlaris.value));
                          } else if (controller.bukuTerlaris.isEmpty) {
                            return const Center(child: Text('Tidak ada data'));
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.bukuTerlaris.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final buku = controller.bukuTerlaris[index];
                              return BookCard(buku: buku);
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      // Kategori Section
                      // CategorySection(),
                      // const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Map<String, dynamic> buku;
  const BookCard({super.key, required this.buku});

  @override
  Widget build(BuildContext context) {
    final double rating =
        double.tryParse(buku['rating']?.toString() ?? '0') ?? 0.0;
    return Container(
      width: 160,
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
          mainAxisSize: MainAxisSize.min, // Fix overflow
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                buku['gambar1'] ?? '',
                height: 130, // sedikit lebih tinggi
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 130,
                  width: 160,
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
