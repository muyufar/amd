import 'package:andi_digital/views/auth/loginsignbutton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.toNamed('home'),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage(
                          'assets/images/Logo_Splash_Screen_b.png'), // Ganti dengan path logo Anda
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Selamat Datang',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Masuk Untuk Melanjutkan',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Obx(() => TextField(
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.vpn_key),
                      labelText: 'Kata Sandi',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          controller.isPasswordVisible.value =
                              !controller.isPasswordVisible.value;
                        },
                      ),
                    ),
                    obscureText: !controller.isPasswordVisible.value,
                  )),
              const SizedBox(height: 24),
              Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: controller.login,
                        child: const Text('Masuk',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    )),
              const SizedBox(height: 12),
              Obx(() => controller.isLoading.value
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: GoogleSignInButton(
                        onPressed: controller.loginWithGoogle,
                      ),
                    )),
              const Spacer(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? '),
                    GestureDetector(
                      onTap: () => Get.toNamed('/register'),
                      child: const Text('Daftar',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
