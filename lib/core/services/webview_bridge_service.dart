import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../config/webview_config.dart';

class WebViewBridgeService {
  static void injectBridge(
    InAppWebViewController controller,
    String? fcmToken,
  ) {
    const cssToDislableSelection = '''
      document.documentElement.style.webkitUserSelect = 'none';
      document.documentElement.style.webkitTouchCallout = 'none';
      document.body.style.webkitUserSelect = 'none';
      document.body.style.webkitTouchCallout = 'none';
      document.addEventListener('selectstart', (e) => e.preventDefault(), false);
      document.addEventListener('contextmenu', (e) => e.preventDefault(), false);
      
      document.documentElement.style.overflow = 'hidden';
      document.documentElement.style.position = 'fixed';
      document.documentElement.style.width = '100%';
      document.documentElement.style.height = '100%';
      document.body.style.position = 'relative';
      document.body.style.overflow = 'auto';
      document.body.style.webkitOverflowScrolling = 'touch';
    ''';
    
    final jsCode = '''
      $cssToDislableSelection
      
      ${WebViewConfig.isIOS ? WebViewConfig.getIosOptimizationScript() : ''}
      
      window.AndroidBridge = {
        getFCMToken: function() {
          window.flutter_inappwebview.callHandler('AndroidBridge', 'getFCMToken');
          return window._fcmToken || '';
        },
        test: function() {
          return 'Bridge is working!';
        }
      };
      console.log('AndroidBridge initialized');
    ''';

    controller.evaluateJavascript(source: jsCode);

    if (fcmToken != null) {
      sendTokenToWebView(controller, fcmToken);
    }
  }

  static void sendTokenToWebView(
    InAppWebViewController controller,
    String token,
  ) {
    final jsCode = '''
      window._fcmToken = '$token';
      console.log('FCM Token received: ${token.substring(0, 30)}...');
      
      document.addEventListener('touchstart', function(e) {
        var touch = e.touches[0];
        var element = touch.target;
        if (element && (element.tagName === 'BUTTON' || element.onclick || element.classList.contains('btn'))) {
          element.style.opacity = '0.7';
        }
      }, { passive: true });
      
      document.addEventListener('touchend', function(e) {
        var touch = e.changedTouches[0];
        var element = touch.target;
        if (element) {
          element.style.opacity = '1';
        }
      }, { passive: true });
      
      if (typeof window.onFCMTokenReceived === 'function') {
        window.onFCMTokenReceived('$token');
      }
    ''';

    controller.evaluateJavascript(source: jsCode);
  }

  static void handleMessage(
    InAppWebViewController controller,
    String message,
    String? fcmToken,
  ) {
    if (message == 'getFCMToken' && fcmToken != null) {
      sendTokenToWebView(controller, fcmToken);
    }
  }
}
