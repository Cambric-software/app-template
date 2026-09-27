import 'dart:io';

class SystemInfoService {
  String get name => 'SystemInfoService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Map<String, dynamic> get info => {
    'os': Platform.operatingSystem,
    'osVersion': Platform.operatingSystemVersion,
    'dart': Platform.version,
    'processors': Platform.numberOfProcessors,
    'locale': Platform.localeName,
    'pathSeparator': Platform.pathSeparator,
    'executable': Platform.executable,
  };

  String get dartVersion => Platform.version.split(' ').first;
  String get hostname => Platform.localHostname;
}
