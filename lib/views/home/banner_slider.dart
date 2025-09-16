import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
  final bool square;
  final Function(String)? onBannerChanged;
  BannerSlider({super.key, this.square = false, this.onBannerChanged});

  final List<String> images = [
    'https://andipublisher.com/images/banner/1751512883_BANNER.jpg',
    'https://andipublisher.com/images/banner/1751334421_BANNER.jpg',
  ];

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Panggil callback untuk banner pertama saat init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onBannerChanged != null) {
        widget.onBannerChanged!(widget.images[0]);
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    if (widget.onBannerChanged != null) {
      widget.onBannerChanged!(widget.images[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        itemCount: widget.images.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: widget.square
                ? Image.network(
                    widget.images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
