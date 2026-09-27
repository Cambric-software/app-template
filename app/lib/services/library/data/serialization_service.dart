import 'dart:convert';

/// Serializes and deserializes objects to/from JSON and Map.
///
/// Implement [Serializable] on your models for typed serialization.
///
/// Usage:
/// ```dart
/// class User implements Serializable {
///   final String name;
///   User(this.name);
///
///   @override
///   Map<String, dynamic> toJson() => {'name': name};
///
///   factory User.fromJson(Map<String, dynamic> json) =>
///       User(json['name'] as String);
/// }
///
/// final s = SerializationService();
/// final json = s.toJsonString(user);
/// final user2 = s.fromJsonString(json, User.fromJson);
/// ```
abstract class Serializable {
  Map<String, dynamic> toJson();
}

class SerializationService {
  String get name => 'SerializationService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  String toJsonString(Serializable object, {bool pretty = false}) {
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(object.toJson());
    }
    return jsonEncode(object.toJson());
  }

  T fromJsonString<T>(
    String source,
    T Function(Map<String, dynamic>) factory,
  ) {
    final data = jsonDecode(source) as Map<String, dynamic>;
    return factory(data);
  }

  T fromMap<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) factory,
  ) => factory(data);

  List<T> listFromJsonString<T>(
    String source,
    T Function(Map<String, dynamic>) factory,
  ) {
    final list = jsonDecode(source) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map(factory)
        .toList();
  }
}
