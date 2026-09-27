import 'dart:io';

class ProcessResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  bool get succeeded => exitCode == 0;
  const ProcessResult({required this.exitCode, required this.stdout, required this.stderr});
}

class ProcessService {
  String get name => 'ProcessService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<ProcessResult> run(String executable, List<String> arguments, {String? workingDir}) async {
    try {
      final result = await Process.run(executable, arguments,
          workingDirectory: workingDir, runInShell: true);
      return ProcessResult(exitCode: result.exitCode, stdout: result.stdout.toString(), stderr: result.stderr.toString());
    } catch (e) {
      return ProcessResult(exitCode: -1, stdout: '', stderr: e.toString());
    }
  }

  Future<ProcessResult> runShell(String command, {String? workingDir}) =>
      run(Platform.isWindows ? 'cmd' : '/bin/sh',
          Platform.isWindows ? ['/c', command] : ['-c', command],
          workingDir: workingDir);
}
