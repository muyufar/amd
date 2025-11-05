import 'package:flutter/material.dart';

class ShoppingGuidePage extends StatelessWidget {
  const ShoppingGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cara Berbelanja'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _ShoppingGuideContent(),
      ),
    );
  }
}

class _ShoppingGuideContent extends StatelessWidget {
  const _ShoppingGuideContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildStepItem(
          'Pasang Aplikasi ebook AMD di perangkat Anda',
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          'Buka Aplikasi ebook AMD yang sudah dipasang di perangkat Anda',
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          'Masuk dengan menggunakan akun Gmail anda untuk mendaftar di ebook AMD.',
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          'Masuk ke menu Kategori atau bisa bisa langsung ke fitur pencarian untuk mencari buku yang ingin Anda beli',
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          'Tap Purchase/Beli pada item yang diinginkan',
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          'Periksa kembali pesanan Anda. Apabila sudah benar, pilih Lanjutkan untuk melanjutkan proses pembayaran.',
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          'Item yang Anda beli akan langsung tersedia di kolom komputasi awan',
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          'Jika proses unduh sudah selesai, item yang Anda beli sudah bisa dibaca dari kolom Koleksiku di Aplikasi.',
        ),
      ],
    );
  }

  Widget _buildStepItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
        Expanded(
          child: SelectableText(
            text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
