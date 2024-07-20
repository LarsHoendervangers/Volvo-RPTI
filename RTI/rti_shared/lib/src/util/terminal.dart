import 'dart:io';

class Terminal {
  
  Terminal._();
  static final Terminal _instance = Terminal._();
  factory Terminal() => _instance;

  Future<void> runCmd(String cmd, List<String> args) async {
    print("Running command: $cmd $args");

    try {
      ProcessResult result = Process.runSync(cmd, args);
      print(result.stderr);
    } catch (err) {
      print("ERR: $err");
    }
  }

  Future<Process> start(String cmd, List<String> args) async {
    print("Starting process: $cmd $args");

    return await Process.start(cmd, args);
  }
}