import 'dart:io';

class PlatformService {
  String get name => 'PlatformService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  static bool get isWindows => Platform.isWindows;
  static bool get isLinux => Platform.isLinux;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isDesktop => Platform.isWindows || Platform.isLinux;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static String get platformName {
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    return Platform.operatingSystem;
  }
  static String get os => Platform.operatingSystem;
  static String get osVersion => Platform.operatingSystemVersion;
  static int get processors => Platform.numberOfProcessors;
  static String get locale => Platform.localeName;
}
