import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/publisher_controller.dart';
import '../../widgets/loading_animations.dart';
import 'imprint_books_page.dart';

class PublisherPage extends StatefulWidget {
  const PublisherPage({super.key});

  @override
  State<PublisherPage> createState() => _PublisherPageState();
}

class _PublisherPageState extends State<PublisherPage> {
  late ScrollController _scrollController;
  late PublisherController controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    try {
      controller = Get.find<PublisherController>();
    } catch (e) {
      controller = Get.put(PublisherController());
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!controller.isLoading.value && controller.hasMoreData.value) {
          controller.loadMorePublishers();
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
        title: Obx(() => Text(
              controller.isShowingImprints.value
                  ? controller.selectedPublisherName.value.isNotEmpty
                      ? controller.selectedPublisherName.value
                      : 'Imprint'
                  : 'Penerbit',
            )),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: Obx(() => controller.isShowingImprints.value
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => controller.resetToPublishers(),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              )),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.publishers.isEmpty) {
          return LoadingAnimations.buildMainLoading(
            title: 'Memuat Penerbit...',
            icon: Icons.business,
            color: Colors.purple,
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Gagal memuat data',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700])),
                const SizedBox(height: 8),
                Text(controller.error.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[600])),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.refreshPublishers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          );
        }

        if (controller.publishers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Tidak ada penerbit',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text('Belum ada penerbit untuk ditampilkan',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }

        return _buildContent();
      }),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isShowingImprints.value) {
        return _buildImprintsAndBooks();
      } else {
        return _buildPublishers();
      }
    });
  }

  Widget _buildPublishers() {
    return RefreshIndicator(
      onRefresh: controller.refreshPublishers,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: controller.publishers.length +
            (controller.hasMoreData.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.publishers.length) {
            return controller.isLoading.value
                ? LoadingAnimations.buildCompactLoading(
                    text: 'Memuat penerbit...', color: Colors.purple)
                : const SizedBox.shrink();
          }

          final publisher = controller.publishers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () => controller.fetchImprints(
                  publisher['id_penerbit'], publisher['nama_penerbit']),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child:
                          const Icon(Icons.business, color: Colors.purple, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(publisher['nama_penerbit'] ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.grey[400], size: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImprintsAndBooks() {
    return Obx(() {
      if (controller.isLoading.value && controller.imprints.isEmpty) {
        return LoadingAnimations.buildMainLoading(
            title: 'Memuat Imprint...',
            icon: Icons.label,
            color: Colors.purple);
      }

      return RefreshIndicator(
        onRefresh: controller.refreshImprints,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (controller.imprints.isNotEmpty) ...[
              SliverToBoxAdapter(
                  child: _buildSectionHeader(
                      'Imprint', Colors.purple, Icons.label)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildImprintItem(controller.imprints[index]),
                    childCount: controller.imprints.length,
                  ),
                ),
              ),
            ],
            if (controller.imprints.isEmpty && !controller.isLoading.value)
              SliverFillRemaining(child: _buildEmptyState()),
          ],
        ),
      );
    });
  }

  Widget _buildImprintItem(Map<String, dynamic> imprint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Get.to(() => ImprintBooksPage(
                imprintId: imprint['id'],
                imprintName: imprint['name'] ?? 'Imprint',
              ));
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.label, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(imprint['name'] ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500))),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Tidak Ada Data',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Belum ada imprint dalam penerbit ini',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
