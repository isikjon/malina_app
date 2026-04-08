import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();
  static final instance = PermissionService._();

  Future<void> requestRequiredPermissions() async {
    // Request permissions sequentially with small delays for iOS stability
    await Permission.notification.request();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await Permission.camera.request();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await Permission.microphone.request();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await Permission.locationWhenInUse.request();
    await Future.delayed(const Duration(milliseconds: 500));

    await Permission.photos.request();
  }

  Future<bool> isPermissionGranted(Permission permission) async {
    return await permission.isGranted;
  }

  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }
}
