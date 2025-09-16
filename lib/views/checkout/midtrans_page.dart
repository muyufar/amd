import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class MidtransPage extends StatefulWidget {
  const MidtransPage({super.key});

  @override
  State<MidtransPage> createState() => _MidtransPageState();
}

class _MidtransPageState extends State<MidtransPage> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    final url = Get.parameters['url'] ?? '';
    final options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptEnabled: true,
        clearCache: false,
        cacheEnabled: true,
        supportZoom: false,
        disableHorizontalScroll: false,
        disableVerticalScroll: false,
        userAgent:
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        allowContentAccess: true,
        allowFileAccess: true,
        mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        thirdPartyCookiesEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        clearSessionCache: false,
        builtInZoomControls: false,
        displayZoomControls: false,
        supportMultipleWindows: false,
        useWideViewPort: true,
        loadWithOverviewMode: true,
        safeBrowsingEnabled: false,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
        allowsAirPlayForMediaPlayback: true,
        allowsBackForwardNavigationGestures: true,
        allowsLinkPreview: true,
        isFraudulentWebsiteWarningEnabled: false,
        allowsPictureInPictureMediaPlayback: true,
        disableLongPressContextMenuOnLinks: false,
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        _showExitDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran Midtrans'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _showExitDialog(),
          ),
        ),
        body: SafeArea(
          child: url.isNotEmpty
              ? InAppWebView(
                  key: webViewKey,
                  initialOptions: options,
                  initialUrlRequest: URLRequest(url: WebUri(url)),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    print('🔵 [MIDTRANS] Loading: $url');
                  },
                  onLoadStop: (controller, url) {
                    print('🔵 [MIDTRANS] Loaded: $url');
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    final uri = navigationAction.request.url!;
                    final urlString = uri.toString();

                    print('🔵 [MIDTRANS] URL Navigation: $urlString');

                    // Handle payment completion
                    if (urlString.contains('finish') ||
                        urlString.contains('success') ||
                        urlString.contains('completed')) {
                      _handlePaymentSuccess();
                      return NavigationActionPolicy.CANCEL;
                    }

                    // Handle payment failure
                    if (urlString.contains('unfinish') ||
                        urlString.contains('error') ||
                        urlString.contains('failed')) {
                      _handlePaymentFailure();
                      return NavigationActionPolicy.CANCEL;
                    }

                    // Allow Midtrans domains and related domains
                    if (urlString.startsWith('https://app.midtrans.com') ||
                        urlString
                            .startsWith('https://app.sandbox.midtrans.com') ||
                        urlString.startsWith('https://api.midtrans.com') ||
                        urlString
                            .startsWith('https://api.sandbox.midtrans.com') ||
                        urlString.startsWith('https://veritrans.co.id') ||
                        urlString.startsWith('https://') ||
                        urlString.startsWith('http://')) {
                      return NavigationActionPolicy.ALLOW;
                    }

                    // Handle other external links
                    if (urlString.startsWith('tel:') ||
                        urlString.startsWith('mailto:') ||
                        urlString.startsWith('sms:')) {
                      try {
                        await launchUrl(Uri.parse(urlString),
                            mode: LaunchMode.externalApplication);
                      } catch (e) {
                        print('🔴 [MIDTRANS] Error opening external URL: $e');
                      }
                      return NavigationActionPolicy.CANCEL;
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onReceivedError: (controller, request, error) {
                    print('🔴 [MIDTRANS] WebView Error: $error');

                    // Handle specific security errors
                    if (error.toString().contains('ERR_BLOCKED_BY_ORB') ||
                        error.toString().contains('ERR_BLOCKED_BY_CLIENT') ||
                        error.toString().contains('ERR_BLOCKED_BY_RESPONSE') ||
                        error
                            .toString()
                            .contains('ERR_CERT_AUTHORITY_INVALID') ||
                        error
                            .toString()
                            .contains('ERR_CERT_COMMON_NAME_INVALID') ||
                        error.toString().contains('ERR_CERT_DATE_INVALID') ||
                        error.toString().contains('ERR_CERT_INVALID') ||
                        error.toString().contains('ERR_CERT_REVOKED') ||
                        error
                            .toString()
                            .contains('ERR_CERT_UNABLE_TO_CHECK_REVOCATION') ||
                        error
                            .toString()
                            .contains('ERR_CERT_WEAK_SIGNATURE_ALGORITHM') ||
                        error.toString().contains('ERR_SSL_PROTOCOL_ERROR') ||
                        error
                            .toString()
                            .contains('ERR_SSL_VERSION_OR_CIPHER_MISMATCH') ||
                        error
                            .toString()
                            .contains('ERR_SSL_CLIENT_AUTH_CERT_NEEDED') ||
                        error
                            .toString()
                            .contains('ERR_SSL_SERVER_CERT_BAD_FORMAT') ||
                        error
                            .toString()
                            .contains('ERR_SSL_SERVER_CERT_UNTRUSTED') ||
                        error
                            .toString()
                            .contains('ERR_SSL_SERVER_CERT_EXPIRED') ||
                        error
                            .toString()
                            .contains('ERR_SSL_SERVER_CERT_REVOKED') ||
                        error
                            .toString()
                            .contains('ERR_SSL_SERVER_CERT_BAD_FORMAT') ||
                        error
                            .toString()
                            .contains('ERR_SSL_SERVER_CERT_UNTRUSTED') ||
                        error
                            .toString()
                            .contains('ERR_SSL_SERVER_CERT_EXPIRED') ||
                        error
                            .toString()
                            .contains('ERR_SSL_SERVER_CERT_REVOKED')) {
                      _handleSecurityError();
                    } else {
                      _handlePaymentError(error.toString());
                    }
                  },
                  onReceivedHttpError: (controller, request, errorResponse) {
                    print(
                        '🔴 [MIDTRANS] HTTP Error: ${errorResponse.statusCode} - ${errorResponse.reasonPhrase}');
                    _handlePaymentError(
                        'HTTP ${errorResponse.statusCode}: ${errorResponse.reasonPhrase}');
                  },
                  onReceivedServerTrustAuthRequest:
                      (controller, challenge) async {
                    // Bypass SSL certificate validation for Midtrans
                    print(
                        '🔵 [MIDTRANS] SSL Certificate Challenge: ${challenge.protectionSpace.host}');
                    return ServerTrustAuthResponse(
                        action: ServerTrustAuthResponseAction.PROCEED);
                  },
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'URL pembayaran tidak ditemukan',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Silakan coba lagi',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pembayaran?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Lanjutkan'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to previous page
            },
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentSuccess() {
    isSuccess = true;
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Pembayaran Berhasil'),
          ],
        ),
        content: const Text(
            'Pembayaran Anda telah berhasil diproses. Terima kasih!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAllNamed('/home'); // Go to home
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _handlePaymentFailure() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Pembayaran Gagal'),
          ],
        ),
        content:
            const Text('Pembayaran Anda gagal diproses. Silakan coba lagi.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to checkout
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _handleSecurityError() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.orange),
            SizedBox(width: 8),
            Text('Masalah Keamanan WebView'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terjadi masalah keamanan pada WebView pembayaran.'),
            SizedBox(height: 8),
            Text('Solusi:'),
            Text('• Pastikan koneksi internet stabil'),
            Text('• Coba refresh halaman'),
            Text('• Gunakan browser eksternal jika perlu'),
            Text('• Periksa pengaturan keamanan perangkat'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _refreshWebView();
            },
            child: const Text('Refresh'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _openInExternalBrowser();
            },
            child: const Text('Buka di Browser'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to checkout
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  void _handleORBError() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.orange),
            SizedBox(width: 8),
            Text('Masalah Keamanan WebView'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terjadi masalah keamanan pada WebView pembayaran.'),
            SizedBox(height: 8),
            Text('Solusi:'),
            Text('• Pastikan koneksi internet stabil'),
            Text('• Coba refresh halaman'),
            Text('• Gunakan browser eksternal jika perlu'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _refreshWebView();
            },
            child: const Text('Refresh'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _openInExternalBrowser();
            },
            child: const Text('Buka di Browser'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to checkout
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(String error) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.orange),
            SizedBox(width: 8),
            Text('Terjadi Kesalahan'),
          ],
        ),
        content: Text('Terjadi kesalahan saat memproses pembayaran: $error'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to checkout
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _refreshWebView() {
    if (webViewController != null) {
      webViewController!.reload();
    }
  }

  void _openInExternalBrowser() {
    final url = Get.parameters['url'] ?? '';
    if (url.isNotEmpty) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
