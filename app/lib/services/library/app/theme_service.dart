import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _mode;
  final Color _seedColor;

  ThemeService({
    ThemeMode initialMode = ThemeMode.system,
    Color seedColor = const Color(0xFF3B82F6),
  })  : _mode = initialMode,
        _seedColor = seedColor;

  String get name => 'ThemeService';
  bool get isAvailable => true;
  Future<bool> healthCheck() async => true;

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  ThemeMode get mode => _mode;
  Color get seedColor => _seedColor;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode');
    if (saved == 'light') {
      _mode = ThemeMode.light;
    } else if (saved == 'dark') {
      _mode = ThemeMode.dark;
    } else {
      _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    notifyListeners();
  }

  ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
      );

  ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      );
}
