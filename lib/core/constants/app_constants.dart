class AppConstants {
  AppConstants._();

  static const String baseUrl = 'https://malina.plus/';
  
  static const String appName = 'Malina Plus';
  
  static const Duration splashDuration = Duration(seconds: 6);
  static const Duration tokenDelay = Duration(seconds: 5);
  static const Duration loadingDelay = Duration(seconds: 3);
  
  static const String fcmTopic = 'all';
  static const String notificationChannelId = 'high_importance_channel';
  static const String notificationChannelName = 'High Importance Notifications';
  static const String notificationChannelDescription = 'This channel is used for important notifications.';
  
  static const String splashImage = 'images/splash.png';
  static const String notificationIcon = '@drawable/ic_stat_ecoplantagro__2';
  
  static const int primaryColorValue = 0xFF0075CD;
  static const int statusBarColorValue = 0xFFf7f6fb;
}
