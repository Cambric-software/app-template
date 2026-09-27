import 'dart:io';

class PlatformService {
  static bool get isWindows => Platform.isWindows;

  static bool get isLinux => Platform.isLinux;

  static bool get isAndroid => Platform.isAndroid;

  static String get name {
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    return 'Unknown';
  }
}
