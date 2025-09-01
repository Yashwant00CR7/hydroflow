import 'dart:developer' as developer;

class Logger {
  static void log(String message, {String? name}) {
    developer.log(message, name: name ?? 'App');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: 'Error', error: error, stackTrace: stackTrace);
  }

  static void debug(String message) {
    developer.log(message, name: 'Debug');
  }
}
