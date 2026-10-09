import 'dart:async';

import 'package:flutter/material.dart';

import '../core/network/connectivity_service.dart';

/// A banner that appears at the top of the screen when the device goes offline.
///
/// Polls [ConnectivityService] every 10 seconds and shows/hides automatically.
///
/// Usage — wrap your main screen body:
/// ```dart
/// ConnectivityBanner(
///   child: MyAppContent(),
/// )
/// ```
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({
    required this.child,
    this.message = 'You are offline',
    this.backgroundColor,
    this.textColor,
    this.pollInterval = const Duration(seconds: 10),
    super.key,
  });

  final Widget child;
  final String message;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration pollInterval;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivity = ConnectivityService();
  Timer? _timer;
  bool _isOffline = false;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _check(); // initial check
    _timer = Timer.periodic(widget.pollInterval, (_) => _check());
  }

  Future<void> _check() async {
    final state = await _connectivity.check();
    final offline = state == ConnectivityState.offline;
    if (mounted && offline != _isOffline) {
      setState(() => _isOffline = offline);
      if (offline) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: _heightFactor,
          child: Material(
            color: widget.backgroundColor ?? const Color(0xFFF59E0B),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 16,
                      color: widget.textColor ?? Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor ?? Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
