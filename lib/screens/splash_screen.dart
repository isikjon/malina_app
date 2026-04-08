import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:website/screens/webview_screen.dart';

import '../core/constants/app_constants.dart';
import '../core/services/permission_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Request ATT (iOS only)
    await requestTrackingPermission();
    
    // 2. Request other permissions
    await PermissionService.instance.requestRequiredPermissions();
    
    // 3. Navigate to home
    await _navigateToHome();
  }

  Future<void> requestTrackingPermission() async {
    if (Platform.isIOS) {
      try {
        // Проверяем доступность ATT (iOS 14+)
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        print('Current ATT Status: $status');

        // Если статус не определен, запрашиваем разрешение
        if (status == TrackingStatus.notDetermined) {
          final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
          print('ATT Request Result: $newStatus');

          // Получаем IDFA только если разрешено
          if (newStatus == TrackingStatus.authorized) {
            final idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
            print('IDFA: $idfa');
          }
        }
      } catch (e) {
        print('Error requesting ATT permission: $e');
      }
    }
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const WebViewScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // <-- SEE HERE
      statusBarIconBrightness: Brightness.light, //<-- For Android SEE HERE (dark icons)
      statusBarBrightness: Brightness.light,
    ));
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'images/splash.png',
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
