import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    print('🟡 [REGISTER PAGE] Starting registration...');
    print('🟡 [REGISTER PAGE] Form data:');
    print('  - Nama: ${_namaController.text.trim()}');
    print('  - Email: ${_emailController.text.trim()}');
    print('  - Telepon: ${_teleponController.text.trim()}');
    print('  - Password: ${_passwordController.text.length} chars');
    print(
        '  - Confirm Password: ${_confirmPasswordController.text.length} chars');

    try {
      final res = await AuthService().registerUser(
        namaUser: _namaController.text.trim(),
        emailUser: _emailController.text.trim(),
        teleponUser: _teleponController.text.trim(),
        passwordUser: _passwordController.text,
        confirmPasswordUser: _confirmPasswordController.text,
      );

      print('🟡 [REGISTER PAGE] Response received: $res');
      print('🟡 [REGISTER PAGE] Response code: ${res['code']}');
      print('🟡 [REGISTER PAGE] Response content: ${res['content']}');

      if (res['code'] == 201 && res['content'] != null) {
        print('🟢 [REGISTER PAGE] Registration successful!');
        Get.defaultDialog(
          title: 'Registrasi Berhasil',
          middleText:
              'Registrasi berhasil silahkan cek Email anda untuk verifikasi',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
            Get.offAllNamed('/login');
          },
        );
      } else {
        print('🔴 [REGISTER PAGE] Registration failed - Code: ${res['code']}');
        String errorMsg = res['message'] ?? 'Registrasi gagal';
        if (res['errors'] != null) {
          final errors = res['errors'] as Map<String, dynamic>;
          errorMsg = errors.values
              .map((v) => (v is List && v.isNotEmpty) ? v[0] : v.toString())
              .join('\n');
          print('🔴 [REGISTER PAGE] Validation errors: $errors');
        }
        print('🔴 [REGISTER PAGE] Error message: $errorMsg');
        Get.defaultDialog(
          title: '',
          middleText: errorMsg,
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(),
        );
      }
    } catch (e) {
      print('🔴 [REGISTER PAGE] Exception caught: $e');
      print('🔴 [REGISTER PAGE] Exception type: ${e.runtimeType}');
      Get.defaultDialog(
        title: 'Error',
        middleText: e.toString(),
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } finally {
      setState(() => _loading = false);
      print('🟡 [REGISTER PAGE] Registration process completed');
    }
  }

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
                onPressed: () => Get.back(),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage:
                          AssetImage('assets/images/Logo_Splash_Screen_b.png'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Buat Akun',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Daftar untuk melanjutkan',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _namaController,
                              decoration: const InputDecoration(
                                  labelText: 'Nama Lengkap'),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Nama wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Email wajib diisi'
                                  : !GetUtils.isEmail(v)
                                      ? 'Format email tidak valid'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _teleponController,
                              decoration:
                                  const InputDecoration(labelText: 'Telepon'),
                              keyboardType: TextInputType.phone,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Telepon wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Password wajib diisi'
                                  : v.length < 6
                                      ? 'Minimal 6 karakter'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Konfirmasi Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscureConfirmPassword,
                              validator: (v) => v != _passwordController.text
                                  ? 'Password tidak sama'
                                  : null,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _loading ? null : _register,
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Text('Daftar',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? '),
                    GestureDetector(
                      onTap: () => Get.toNamed('/login'),
                      child: const Text('Masuk',
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
