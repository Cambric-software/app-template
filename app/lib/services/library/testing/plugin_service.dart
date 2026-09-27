class PluginInfo {
  final String id;
  final String name;
  final String version;
  final bool enabled;
  const PluginInfo({required this.id, required this.name, required this.version, this.enabled = true});
}

abstract class CambricPlugin {
  PluginInfo get info;
  Future<void> initialize();
  Future<void> dispose();
  Future<bool> healthCheck();
}

class PluginService {
  final Map<String, CambricPlugin> _plugins = {};

  String get name => 'PluginService';
  bool get isAvailable => true;
  Future<void> initialize() async { for (final p in _plugins.values) { await p.initialize(); } }
  Future<void> dispose() async { for (final p in _plugins.values) { await p.dispose(); } }
  Future<bool> healthCheck() async => true;

  void register(CambricPlugin plugin) => _plugins[plugin.info.id] = plugin;
  void unregister(String id) => _plugins.remove(id);
  CambricPlugin? get(String id) => _plugins[id];
  List<CambricPlugin> get all => _plugins.values.toList();
  bool isRegistered(String id) => _plugins.containsKey(id);

  Future<Map<String, bool>> healthCheckAll() async {
    final results = <String, bool>{};
    for (final entry in _plugins.entries) {
      results[entry.key] = await entry.value.healthCheck().catchError((_) => false);
    }
    return results;
  }
}
