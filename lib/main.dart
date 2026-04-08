import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'core/config/firebase_config.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/scroll_behavior.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    // ATT is now handled in SplashScreen for better UX and App Store compliance
  }

  await FirebaseConfig.initialize();
  await _setupFirebaseMessaging();
  runApp(const MyApp());
}

Future<void> _setupFirebaseMessaging() async {
  try {
    await FirebaseMessaging.instance.subscribeToTopic(AppConstants.fcmTopic);
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
    }
  } catch (e) {
    debugPrint('Error setting up Firebase Messaging: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      scrollBehavior: NoBounceScrollBehavior(),
      home: const SplashScreen(),
    );
  }
}
