import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});
  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _gather();
  }

  void _gather() {
    setState(() {
      _data['Platform'] = Platform.operatingSystem;
      _data['OS Version'] = Platform.operatingSystemVersion;
      _data['Dart Version'] = Platform.version.split(' ').first;
      _data['Processors'] = Platform.numberOfProcessors.toString();
      _data['Locale'] = Platform.localeName;
      _data['Hostname'] = Platform.localHostname;
    });
  }

  Future<void> _copyReport() async {
    final lines = _data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    await Clipboard.setData(ClipboardData(text: lines));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diagnostics copied to clipboard')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(icon: const Icon(Icons.copy_outlined), tooltip: 'Copy report', onPressed: _copyReport),
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh', onPressed: _gather),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text('System', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary)),
                ),
                const Divider(height: 1),
                ..._data.entries.map((e) => ListTile(
                  dense: true,
                  title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Text(e.value.toString(), style: Theme.of(context).textTheme.bodySmall),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
