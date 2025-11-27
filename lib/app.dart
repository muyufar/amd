import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'controllers/auth_controller.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    // Panggil autoLogin dan cek token saat app start
    Future.delayed(Duration.zero, () {
      final authController = Get.put(AuthController(), permanent: true);
      // Cek token saat aplikasi dimulai
      authController.checkTokenAndLogoutIfExpired();
    });
    _handleInitialUri();
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      if (uri.pathSegments.isNotEmpty) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      print('Deep link error: $err');
    });
  }

  Future<void> _handleInitialUri() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null && uri.pathSegments.isNotEmpty) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      print('Initial deep link error: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    // Contoh: /api/dev/ebook/harry-potter/AD-0000001 atau /ebook/harry-potter
    final ebookIndex = uri.pathSegments.indexWhere((s) => s == 'ebook');
    if (ebookIndex != -1 && uri.pathSegments.length > ebookIndex + 1) {
      final slug = uri.pathSegments[ebookIndex + 1];
      final kodeAfiliasi = uri.pathSegments.length > ebookIndex + 2
          ? uri.pathSegments[ebookIndex + 2]
          : null;
      if (slug.isNotEmpty) {
        Get.toNamed('/book-detail', parameters: {
          'slug': slug,
          if (kodeAfiliasi != null) 'afiliasi': kodeAfiliasi,
        });
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AMD',
      initialRoute: '/home',
      getPages: AppPages.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
