import 'package:flutter/material.dart';

import '../../core/cache/cache_service.dart';

class CacheScreen extends StatefulWidget {
  const CacheScreen({super.key});

  @override
  State<CacheScreen> createState() => _CacheScreenState();
}

class _CacheScreenState extends State<CacheScreen> {
  int _size = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final size = await CacheService.instance.sizeBytes();

    if (!mounted) return;

    setState(() {
      _size = size;
      _loading = false;
    });
  }

  Future<void> _clear() async {
    await CacheService.instance.clear();
    await _refresh();
  }

  String _format(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            title: const Text('Cached data'),
            subtitle: Text(
              _loading ? 'Calculating...' : _format(_size),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _clear,
            child: const Text('Clear cache'),
          ),
        ],
      ),
    );
  }
}
