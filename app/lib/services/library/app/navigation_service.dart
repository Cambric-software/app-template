import 'package:flutter/material.dart';

/// Global navigation without BuildContext.
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String get name => 'NavigationService';
  bool get isAvailable => navigatorKey.currentState != null;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => isAvailable;

  NavigatorState? get navigator => navigatorKey.currentState;

  Future<T?> push<T>(Widget screen) =>
      navigator!.push<T>(MaterialPageRoute(builder: (_) => screen));

  Future<T?> pushNamed<T>(String route, {Object? arguments}) =>
      navigator!.pushNamed<T>(route, arguments: arguments);

  void pop<T>([T? result]) => navigator?.pop<T>(result);

  Future<T?> pushReplacement<T>(Widget screen) =>
      navigator!.pushReplacement(MaterialPageRoute(builder: (_) => screen));

  void popToRoot() => navigator?.popUntil((route) => route.isFirst);

  bool canPop() => navigator?.canPop() ?? false;
}
