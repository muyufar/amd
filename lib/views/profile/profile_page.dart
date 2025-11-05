import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'privacy_policy_page.dart';
import 'shopping_guide_page.dart';
import 'become_author_page.dart';
import 'faq_page.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/bonus_claim_dialog.dart';
import '../../utils/theme_utils.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final box = GetStorage();
    final userData = box.read('user');
    String name = 'User';
    String email = 'user@mail.com';
    if (userData != null) {
      // userData kemungkinan Map<String, dynamic>
      name = userData['name'] ?? '-';
      email = userData['email'] ?? '-';
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Avatar, Name, Email
          CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage(
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}'),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // Login/Logout Button (dipindah ke atas)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final token = GetStorage().read('token');
                  final bool isLoggedIn =
                      token != null && (!(token is String) || token.isNotEmpty);
                  if (!isLoggedIn) {
                    Get.toNamed('/login');
                    return;
                  }

                  // Logout flow (diangkat dari ListTile sebelumnya)
                  Get.dialog(
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                    barrierDismissible: false,
                  );
                  try {
                    await authController.logout();
                    Get.back();
                    Get.offAllNamed('/login');
                    Get.snackbar(
                      'Logout Berhasil',
                      'Anda telah berhasil logout',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    Get.back();
                    Get.snackbar(
                      'Logout Gagal',
                      'Terjadi kesalahan saat logout: $e',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                icon: Builder(builder: (context) {
                  final token = GetStorage().read('token');
                  final bool isLoggedIn =
                      token != null && (!(token is String) || token.isNotEmpty);
                  return Icon(isLoggedIn ? Icons.logout : Icons.login);
                }),
                label: Builder(builder: (context) {
                  final token = GetStorage().read('token');
                  final bool isLoggedIn =
                      token != null && (!(token is String) || token.isNotEmpty);
                  return Text(isLoggedIn ? 'Logout' : 'Login');
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Kontak Kami'),
                  onTap: () async {
                    final String phone = '628112860877';
                    final String message =
                        'Hai eBook AMD! Saya butuh bantuan CS';
                    final Uri waUri = Uri.parse(
                        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
                    if (await canLaunchUrl(waUri)) {
                      await launchUrl(waUri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      Get.snackbar(
                        'Gagal membuka WhatsApp',
                        'Silakan hubungi $phone secara manual.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: const Text('Cara Berbelanja'),
                  onTap: () {
                    Get.to(() => const ShoppingGuidePage());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Ingin Jadi Penulis ?'),
                  onTap: () {
                    Get.to(() => const BecomeAuthorPage());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Kebijakan & Privasi'),
                  onTap: () {
                    Get.to(() => const PrivacyPolicyPage());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file_outlined),
                  title: const Text('FAQ'),
                  onTap: () {
                    Get.to(() => const FaqPage());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_remove_outlined),
                  title: const Text('Hapus Akun'),
                  onTap: () async {
                    final String phone = '628112860877';
                    final String message =
                        'Hai eBook AMD! Saya ingin menghapus akun saya';
                    final Uri waUri = Uri.parse(
                        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
                    if (await canLaunchUrl(waUri)) {
                      await launchUrl(waUri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      Get.snackbar(
                        'Gagal membuka WhatsApp',
                        'Silakan hubungi $phone secara manual.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.card_giftcard),
                  title: const Text('Klaim Bonus'),
                  onTap: () {
                    final token = GetStorage().read('token');
                    if (token == null || (token is String && token.isEmpty)) {
                      Get.toNamed('/login');
                    } else {
                      Get.dialog(BonusClaimDialog());
                    }
                  },
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
