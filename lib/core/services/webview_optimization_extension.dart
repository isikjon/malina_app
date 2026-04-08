import 'package:flutter_inappwebview/flutter_inappwebview.dart';

extension WebViewOptimization on InAppWebViewController {
  Future<void> optimizeForIOSPro() async {
    try {
      const optimizationScript = '''
        document.addEventListener('touchmove', function(e) {
        }, { passive: true });
        
        document.addEventListener('touchcancel', function(e) {
        }, { passive: true });
        
        const style = document.createElement('style');
        style.textContent = `
          html, body {
            position: fixed;
            width: 100%;
            height: 100%;
            overflow: hidden;
            -webkit-user-select: none;
          }
          body {
            overflow-y: scroll;
            -webkit-overflow-scrolling: touch;
            position: relative;
          }
          * {
            -webkit-backface-visibility: hidden;
            -webkit-perspective: 1000;
          }
          button, a, input, textarea, [role="button"] {
            cursor: pointer;
            -webkit-tap-highlight-color: rgba(0, 0, 0, 0.1);
          }
        `;
        document.head.appendChild(style);
      ''';
      
      await evaluateJavascript(source: optimizationScript);
    } catch (e) {
      print('Error optimizing WebView for iOS: \$e');
    }
  }
}
