import 'package:flutter/material.dart';

class _EmptyBonusBooksWidget extends StatefulWidget {
  const _EmptyBonusBooksWidget();

  @override
  State<_EmptyBonusBooksWidget> createState() => _EmptyBonusBooksWidgetState();
}

class _EmptyBonusBooksWidgetState extends State<_EmptyBonusBooksWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated gift icon with looping animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_controller.value * 0.2),
                child: Transform.rotate(
                  angle: (_controller.value - 0.5) * 0.2,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.2 + _controller.value * 0.2),
                          Colors.green.withOpacity(0.4 + _controller.value * 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2 + _controller.value * 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.card_giftcard,
                      size: 60,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // Animated text
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  'Bonus Buku Belum Ada',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Subtitle text
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 2000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Bonus buku akan muncul di sini ketika tersedia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // Animated dots
          LoadingAnimations._buildAnimatedDots(Colors.green),
        ],
      ),
    );
  }
}

class LoadingAnimations {
  // Main loading animation for general pages
  static Widget buildMainLoading({
    String title = 'Memuat...',
    IconData icon = Icons.refresh,
    MaterialColor color = Colors.blue,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
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
                        color.withOpacity(0.3),
                        color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
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
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color.shade700,
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
                  backgroundColor: color.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Animated dots
          _buildAnimatedDots(color),
        ],
      ),
    );
  }

  // Book-specific loading animation
  static Widget buildBookLoading({
    String title = 'Memuat Buku...',
  }) {
    return buildMainLoading(
      title: title,
      icon: Icons.menu_book,
      color: Colors.blue,
    );
  }

  // Wishlist loading animation
  static Widget buildWishlistLoading() {
    return buildMainLoading(
      title: 'Memuat Wishlist...',
      icon: Icons.favorite,
      color: Colors.pink,
    );
  }

  // Transaction loading animation
  static Widget buildTransactionLoading() {
    return buildMainLoading(
      title: 'Memuat Transaksi...',
      icon: Icons.receipt_long,
      color: Colors.orange,
    );
  }

  // Bookshelf loading animation
  static Widget buildBookshelfLoading() {
    return buildMainLoading(
      title: 'Memuat Koleksi...',
      icon: Icons.library_books,
      color: Colors.purple,
    );
  }

  // Book detail loading animation
  static Widget buildBookDetailLoading() {
    return buildMainLoading(
      title: 'Memuat Detail Buku...',
      icon: Icons.book,
      color: Colors.green,
    );
  }

  // Compact loading for lists
  static Widget buildCompactLoading({
    String text = 'Memuat...',
    MaterialColor color = Colors.blue,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.7 + (0.3 * value),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: color,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Animated text
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: 0.5 + (0.5 * value),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color.shade600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Animated progress bar
          SizedBox(
            width: 120,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: color.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 3,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Skeleton loading for list items
  static Widget buildSkeletonItem({
    double height = 80,
    MaterialColor color = Colors.grey,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: 0.3 + (0.7 * value),
          child: Container(
            height: height,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Skeleton image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Skeleton text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 120,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
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
  }

  // Empty state animation for bonus books
  static Widget buildEmptyBonusBooks() {
    return const _EmptyBonusBooksWidget();
  }

  // Animated dots helper
  static Widget _buildAnimatedDots(MaterialColor color) {
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
                    color: color.withOpacity(0.3 + (0.7 * value)),
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
