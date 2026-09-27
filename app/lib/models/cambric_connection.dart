class CambricConnection {
  final String connectionId;
  final String localProductId;
  final String remoteProductId;
  final int protocolVersion;
  final List<String> capabilities;
  final bool readAllowed;
  final bool writeAllowed;

  const CambricConnection({
    required this.connectionId,
    required this.localProductId,
    required this.remoteProductId,
    required this.protocolVersion,
    required this.capabilities,
    required this.readAllowed,
    required this.writeAllowed,
  });

  Map<String, dynamic> toJson() {
    return {
      'connectionId': connectionId,
      'localProductId': localProductId,
      'remoteProductId': remoteProductId,
      'protocolVersion': protocolVersion,
      'capabilities': capabilities,
      'readAllowed': readAllowed,
      'writeAllowed': writeAllowed,
    };
  }
}
