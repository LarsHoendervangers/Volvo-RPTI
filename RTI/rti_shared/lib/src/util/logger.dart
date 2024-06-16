import 'dart:io';

class Logger {
  final String _tag;

  Logger(this._tag);

  log(LogLevel level, String msg) {
    stdout.writeln("[${level.name.toUpperCase()}] [${DateTime.now()}] [$_tag]: $msg");
  }
}

enum LogLevel {
  debug,
  info,
  warning,
  error
}