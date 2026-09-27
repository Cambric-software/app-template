import 'package:flutter/services.dart';

class ClipboardService {
  String get name => 'ClipboardService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<String?> pasteText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  Future<bool> hasText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text?.isNotEmpty ?? false;
  }
}
