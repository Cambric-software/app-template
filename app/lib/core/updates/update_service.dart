class UpdateService {
  static final UpdateService instance = UpdateService._();

  UpdateService._();

  Future<bool> isUpdateAvailable({
    required String currentVersion,
  }) async {
    // Template intentionally does not contact a server automatically.
    // Future applications may implement their own update source here.
    return false;
  }
}
