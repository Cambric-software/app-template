import 'package:flutter/widgets.dart';

/// Manages form state: validation, submission, and loading.
class FormService extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _submitted = false;
  String? _error;

  String get name => 'FormService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<bool> healthCheck() async => true;

  bool get isLoading => _loading;
  bool get isSubmitted => _submitted;
  String? get error => _error;
  bool get isValid => formKey.currentState?.validate() ?? false;

  bool validate() {
    final valid = formKey.currentState?.validate() ?? false;
    notifyListeners();
    return valid;
  }

  Future<bool> submit(Future<void> Function() action) async {
    if (_loading) return false;
    if (!validate()) return false;
    formKey.currentState?.save();
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _submitted = true;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void reset() {
    formKey.currentState?.reset();
    _loading = false;
    _submitted = false;
    _error = null;
    notifyListeners();
  }
}
