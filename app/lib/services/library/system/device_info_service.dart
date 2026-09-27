import 'dart:io';

class DeviceInfo {
  final String platform;
  final String osVersion;
  final int processors;
  final String locale;
  const DeviceInfo({required this.platform, required this.osVersion, required this.processors, required this.locale});
  Map<String, dynamic> toJson() => {'platform': platform, 'osVersion': osVersion, 'processors': processors, 'locale': locale};
}

class DeviceInfoService {
  String get name => 'DeviceInfoService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  DeviceInfo get info => DeviceInfo(
    platform: Platform.operatingSystem,
    osVersion: Platform.operatingSystemVersion,
    processors: Platform.numberOfProcessors,
    locale: Platform.localeName,
  );

  bool get isDesktop => Platform.isWindows || Platform.isLinux;
  bool get isMobile => Platform.isAndroid;
}
