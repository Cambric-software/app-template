import 'package:flutter/material.dart';

import 'widgets/cambric_version_label.dart';

class CambricAppShell extends StatelessWidget {
  final String productName;
  final String version;
  final Widget child;

  const CambricAppShell({
    super.key,
    required this.productName,
    required this.version,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: child,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: CambricVersionLabel(
              version: version,
            ),
          ),
        ],
      ),
    );
  }
}
