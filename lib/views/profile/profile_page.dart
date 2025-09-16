import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../controllers/auth_controller.dart';

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
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.library_books_outlined),
                  title: const Text('Blog'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Kontak Kami'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: const Text('Cara Berbelanja'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.refresh_outlined),
                  title: const Text('Pengembalian Barang'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Ingin Jadi Penulis ?'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Kebijakan & Privasi'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file_outlined),
                  title: const Text('FAQ'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('Beri Penilaian'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.person_remove_outlined),
                  title: const Text('Hapus Akun'),
                  onTap: () {},
                ),
                const Divider(),
                Builder(
                  builder: (context) {
                    final token = box.read('token');
                    if (token == null) {
                      return ListTile(
                        leading: const Icon(Icons.login),
                        title: const Text('Login'),
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', (route) => false);
                        },
                      );
                    } else {
                      return ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        onTap: () async {
                          // Show loading dialog
                          Get.dialog(
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                            barrierDismissible: false,
                          );

                          try {
                            // Call logout API
                            await authController.logout();

                            // Close loading dialog
                            Get.back();

                            // Navigate to login page
                            Get.offAllNamed('/login');

                            // Show success message
                            Get.snackbar(
                              'Logout Berhasil',
                              'Anda telah berhasil logout',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } catch (e) {
                            // Close loading dialog
                            Get.back();

                            // Show error message
                            Get.snackbar(
                              'Logout Gagal',
                              'Terjadi kesalahan saat logout: $e',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
