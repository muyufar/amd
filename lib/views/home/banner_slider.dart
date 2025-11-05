import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/banner_service.dart';

class BannerSlider extends StatefulWidget {
  final bool square;
  final Function(String)? onBannerChanged;
  BannerSlider({super.key, this.square = false, this.onBannerChanged});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int currentIndex = 0;
  List<BannerData> banners = [];
  bool isLoading = true;
  String? error;
  PageController? _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadBanners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      final bannerData = await BannerService.getActiveBanners();
      if (mounted) {
        setState(() {
          banners = bannerData ?? [];
          isLoading = false;
          error = bannerData == null ? 'Gagal memuat banner' : null;
        });

        // Panggil callback untuk banner pertama jika ada
        if (banners.isNotEmpty && widget.onBannerChanged != null) {
          widget.onBannerChanged!(banners[0].image);
        }

        // Mulai auto-slide jika ada lebih dari 1 banner
        if (banners.length > 1) {
          _startAutoSlide();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          error = 'Error: $e';
        });
      }
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (mounted && banners.isNotEmpty) {
        int nextIndex = (currentIndex + 1) % banners.length;
        _pageController?.animateToPage(
          nextIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    if (widget.onBannerChanged != null && banners.isNotEmpty) {
      widget.onBannerChanged!(banners[index].image);
    }

    // Restart auto-slide timer setelah user manual swipe
    if (banners.length > 1) {
      _startAutoSlide();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text(
                error!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (banners.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Tidak ada banner tersedia',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return GestureDetector(
                onTap: () {
                  if (banner.link != null && banner.link!.isNotEmpty) {
                    // TODO: Handle banner link tap
                    print('Banner tapped: ${banner.link}');
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  child: widget.square
                      ? Image.network(
                          banner.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.image_not_supported,
                                  color: Colors.grey[400]),
                            );
                          },
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: Image.network(
                            banner.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.grey[400]),
                              );
                            },
                          ),
                        ),
                ),
              );
            },
          ),
          if (banners.length > 1)
            Positioned(
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: List.generate(banners.length, (index) {
                    final bool isActive = currentIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white70,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
