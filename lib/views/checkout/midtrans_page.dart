import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MidtransPage extends StatefulWidget {
  const MidtransPage({super.key});

  @override
  State<MidtransPage> createState() => _MidtransPageState();
}

class _MidtransPageState extends State<MidtransPage> {
  final GlobalKey webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final url = Get.parameters['url'] ?? '';

    InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
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
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          foregroundColor: Colors.black,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              url.isNotEmpty
                  ? InAppWebView(
                      key: webViewKey,
                      initialOptions: options,
                      initialUrlRequest: URLRequest(url: WebUri(url)),
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        final uri = navigationAction.request.url!;

                        log('url ${navigationAction.request.url}');

                        // Handle payment completion
                        if ((uri.toString()).contains('finish')) {
                          Get.offAllNamed('/home');
                          return NavigationActionPolicy.CANCEL;
                        } else if ((uri.toString()).contains('success')) {
                          Get.offAllNamed('/home');
                          return NavigationActionPolicy.CANCEL;
                        } else if ((uri.toString()).contains('completed')) {
                          Get.offAllNamed('/home');
                          return NavigationActionPolicy.CANCEL;
                        }

                        // Handle payment failure
                        if ((uri.toString()).contains('unfinish')) {
                          Get.back();
                          return NavigationActionPolicy.CANCEL;
                        } else if ((uri.toString()).contains('error')) {
                          Get.back();
                          return NavigationActionPolicy.CANCEL;
                        } else if ((uri.toString()).contains('failed')) {
                          Get.back();
                          return NavigationActionPolicy.CANCEL;
                        }

                        // Allow Midtrans domains
                        if ((uri.toString())
                            .startsWith('https://app.midtrans.com')) {
                          return NavigationActionPolicy.ALLOW;
                        } else if ((uri.toString())
                            .startsWith('https://app.sandbox.midtrans.com')) {
                          return NavigationActionPolicy.ALLOW;
                        } else if ((uri.toString())
                            .startsWith('https://api.midtrans.com')) {
                          return NavigationActionPolicy.ALLOW;
                        } else if ((uri.toString())
                            .startsWith('https://api.sandbox.midtrans.com')) {
                          return NavigationActionPolicy.ALLOW;
                        } else if ((uri.toString())
                            .startsWith('https://veritrans.co.id')) {
                          return NavigationActionPolicy.ALLOW;
                        }

                        // Handle other external links
                        if ((uri.toString()).startsWith('http://') ||
                            (uri.toString()).startsWith('https://')) {
                          try {
                            await launchUrl(Uri.parse(uri.toString()),
                                mode: LaunchMode.externalApplication);
                          } catch (e) {
                            log('Error opening external URL: $e');
                          }
                          return NavigationActionPolicy.CANCEL;
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onReceivedServerTrustAuthRequest:
                          (controller, challenge) async {
                        // Bypass SSL certificate validation for Midtrans
                        log('SSL Certificate Challenge: ${challenge.protectionSpace.host}');
                        return ServerTrustAuthResponse(
                            action: ServerTrustAuthResponseAction.PROCEED);
                      },
                      onReceivedError: (controller, request, error) {
                        log('WebView Error: $error');
                        // Handle errors silently or show minimal feedback
                      },
                      onReceivedHttpError:
                          (controller, request, errorResponse) {
                        log('HTTP Error: ${errorResponse.statusCode} - ${errorResponse.reasonPhrase}');
                        // Handle HTTP errors silently
                      },
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
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
            ],
          ),
        ),
      ),
    );
  }
}
