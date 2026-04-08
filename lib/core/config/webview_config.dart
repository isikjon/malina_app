import 'dart:io';

class WebViewConfig {
  static String getIosOptimizationScript() {
    return '''
      (function() {
        const originalAddEventListener = Element.prototype.addEventListener;
        let tapStarted = false;
        let tapElement = null;
        
        document.addEventListener('pointerdown', function(e) {
          tapStarted = true;
          tapElement = e.target;
        }, { capture: true, passive: true });
        
        document.addEventListener('pointerup', function(e) {
          if (tapStarted && tapElement) {
            const clickEvent = new MouseEvent('click', {
              bubbles: true,
              cancelable: true,
              view: window
            });
            tapElement.dispatchEvent(clickEvent);
            tapStarted = false;
            tapElement = null;
          }
        }, { capture: true, passive: true });
        
        document.addEventListener('touchstart', function(e) {
          if (e.target.onclick || e.target.getAttribute('onclick')) {
            e.preventDefault();
            e.stopPropagation();
          }
        }, { passive: false });
      })();
    ''';
  }

  static String getDisableSelectionCss() {
    return '''
      * {
        -webkit-user-select: none !important;
        -webkit-touch-callout: none !important;
        user-select: none !important;
        -moz-user-select: none !important;
        -ms-user-select: none !important;
      }
      input, textarea {
        -webkit-user-select: text !important;
        user-select: text !important;
      }
      button, a, [role="button"] {
        -webkit-user-select: none !important;
        user-select: none !important;
      }
    ''';
  }

  static bool get isIOS => Platform.isIOS;

  static bool get isHighEndDevice {
    if (!Platform.isIOS) return false;
    return true;
  }
}
