import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BecomeAuthorPage extends StatelessWidget {
  const BecomeAuthorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingin Jadi Penulis ?'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _BecomeAuthorContent(),
      ),
    );
  }
}

class _BecomeAuthorContent extends StatelessWidget {
  const _BecomeAuthorContent();

  @override
  Widget build(BuildContext context) {
    const String phoneNumber = '0811-2860-877';
    const String phoneNumberForWhatsApp = '628112860877';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                'Untuk yang berminat menjadi penulis ebook dapat menghubungi narahubung kami di $phoneNumber',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              const String message =
                  'Hai eBook AMD! Saya berminat menjadi penulis ebook';
              final Uri waUri = Uri.parse(
                  'https://wa.me/$phoneNumberForWhatsApp?text=${Uri.encodeComponent(message)}');
              if (await canLaunchUrl(waUri)) {
                await launchUrl(waUri, mode: LaunchMode.externalApplication);
              } else {
                Get.snackbar(
                  'Gagal membuka WhatsApp',
                  'Silakan hubungi $phoneNumber secara manual.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            icon: const Icon(Icons.chat),
            label: const Text('Hubungi via WhatsApp'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final Uri telUri = Uri.parse('tel:$phoneNumberForWhatsApp');
              if (await canLaunchUrl(telUri)) {
                await launchUrl(telUri);
              } else {
                Get.snackbar(
                  'Gagal membuka aplikasi telepon',
                  'Silakan hubungi $phoneNumber secara manual.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            icon: const Icon(Icons.phone),
            label: const Text('Hubungi via Telepon'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
