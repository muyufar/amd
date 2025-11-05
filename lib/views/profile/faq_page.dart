import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _FaqContent(),
      ),
    );
  }
}

class _FaqContent extends StatelessWidget {
  const _FaqContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Cara Unduh Aplikasi
        _buildSectionTitle('1. Cara Unduh Aplikasi'),
        const SizedBox(height: 16),
        _buildStepItem('Buka Play Store'),
        const SizedBox(height: 12),
        _buildStepItem('Cari ebook AMD'),
        const SizedBox(height: 12),
        _buildStepItem('Klik tombol Pasang pada aplikasi ebook AMD'),
        const SizedBox(height: 32),

        // Section 2: Cara Membeli Buku dan Majalah
        _buildSectionTitle('2. Cara Membeli Buku dan Majalah'),
        const SizedBox(height: 16),
        _buildStepItem('Pasang Aplikasi ebook AMD di perangkat Anda'),
        const SizedBox(height: 12),
        _buildStepItem('Buka Aplikasi ebook AMD yang sudah dipasang di perangkat Anda'),
        const SizedBox(height: 12),
        _buildStepItem('Masuk dengan menggunakan akun Gmail anda untuk mendaftar di ebook AMD.'),
        const SizedBox(height: 12),
        _buildStepItem('Masuk ke menu Kategori atau bisa bisa langsung ke fitur pencarian untuk mencari buku yang ingin Anda beli'),
        const SizedBox(height: 12),
        _buildStepItem('Tap Purchase/Beli pada item yang diinginkan'),
        const SizedBox(height: 12),
        _buildStepItem('Periksa kembali pesanan Anda. Apabila sudah benar, pilih Lanjutkan untuk melanjutkan proses pembayaran.'),
        const SizedBox(height: 12),
        _buildStepItem('Item yang Anda beli akan langsung tersedia di kolom komputasi awan'),
        const SizedBox(height: 12),
        _buildStepItem('Jika proses unduh sudah selesai, item yang Anda beli sudah bisa dibaca dari kolom Koleksiku di Aplikasi.'),
        const SizedBox(height: 32),

        // Section 3: Cara Membaca Melalui ebook AMD
        _buildSectionTitle('3. Cara Membaca Melalui ebook AMD'),
        const SizedBox(height: 16),
        _buildStepItem('Login dengan akun ebook AMD Anda yang digunakan untuk membeli item di aplikasi yang sudah diunduh'),
        const SizedBox(height: 12),
        _buildStepItem('Item yang sudah dibeli sebelumnya akan tersedia di Koleksi Bukumu.'),
        const SizedBox(height: 12),
        _buildStepItem('Unduh item yang ingin dibaca dan tunggu proses pengunduhan selesai'),
        const SizedBox(height: 12),
        _buildStepItem('Setelah selesai proses pengunduhan, Anda bisa membacanya secara offline melalui kolom Koleksi.'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.6,
      ),
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

