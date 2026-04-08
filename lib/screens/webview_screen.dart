import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_constants.dart';
import '../core/config/webview_config.dart';
import '../core/services/permission_service.dart';
import '../core/services/webview_bridge_service.dart';
import '../core/services/webview_optimization_extension.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  StreamSubscription<String>? _tokenRefreshSubscription;

  String? _fcmToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await PermissionService.instance.requestRequiredPermissions();
    await _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      setState(() => _fcmToken = token);

      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
        (newToken) {
          setState(() => _fcmToken = newToken);
          _sendTokenToWebView(newToken);
        },
      );
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  void _injectJavaScriptBridge() {
    if (_webViewController == null) return;
    WebViewBridgeService.injectBridge(_webViewController!, _fcmToken);
  }

  void _injectCSSForDisableSelection(InAppWebViewController controller) {
    final cssCode = '''
      var style = document.createElement('style');
      style.textContent = `${WebViewConfig.getDisableSelectionCss()}`;
      document.head.appendChild(style);
    ''';
    
    controller.evaluateJavascript(source: cssCode);
    
    if (WebViewConfig.isIOS) {
      controller.evaluateJavascript(source: WebViewConfig.getIosOptimizationScript());
    }
  }

  void _handleJavaScriptMessage(String message) {
    if (_webViewController == null) return;
    WebViewBridgeService.handleMessage(_webViewController!, message, _fcmToken);
  }

  void _sendTokenToWebView(String token) {
    if (_webViewController == null) return;
    WebViewBridgeService.sendTokenToWebView(_webViewController!, token);
  }

  Future<NavigationActionPolicy> _handleUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final uri = navigationAction.request.url;
    if (uri == null) return NavigationActionPolicy.ALLOW;

    if (uri.scheme == 'tel' || uri.scheme == 'mailto') {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Error launching $uri: $e');
      }
      return NavigationActionPolicy.CANCEL;
    }

    if (uri.host == 'malina.plus' || uri.host == 'www.malina.plus') {
      return NavigationActionPolicy.ALLOW;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching external URL: $e');
    }

    return NavigationActionPolicy.CANCEL;
  }

  @override
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: Platform.isAndroid ? [SystemUiOverlay.top] : [],
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(AppConstants.statusBarColorValue),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 35,
                color: const Color(AppConstants.statusBarColorValue),
              ),
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(AppConstants.baseUrl),
                  ),
                  initialSettings: InAppWebViewSettings(
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: false,
                    useHybridComposition: true,
                    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                    overScrollMode: OverScrollMode.NEVER,
                    allowsInlineMediaPlayback: true,
                    isInspectable: false,
                    allowsBackForwardNavigationGestures: false,
                    supportZoom: false,
                  ),
                  shouldOverrideUrlLoading: _handleUrlLoading,
                  onWebViewCreated: (controller) {
                    _webViewController = controller;

                    controller.addJavaScriptHandler(
                      handlerName: 'AndroidBridge',
                      callback: (args) {
                        if (args.isNotEmpty) {
                          _handleJavaScriptMessage(args[0].toString());
                        }
                      },
                    );
                  },
                  onLoadStop: (controller, url) {
                    _injectJavaScriptBridge();
                    _injectCSSForDisableSelection(controller);
                    if (WebViewConfig.isIOS) {
                      controller.optimizeForIOSPro();
                    }
                  },
                  onProgressChanged: (controller, progress) async {
                    if (progress >= 100) {
                      final url = await controller.getUrl();
                      if (url?.path != "/mobile/" && url?.path != "/mobile/loader") {
                        Future.delayed(AppConstants.loadingDelay, () {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        });
                      }
                    }
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
