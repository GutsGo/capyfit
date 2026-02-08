import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 全局统一日志工具类
class Log {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // 默认不显示方法堆栈，保持简洁
      errorMethodCount: 5, // 错误时显示 5 行堆栈
      lineLength: 80, // 每行长度
      colors: true, // 彩色输出
      printEmojis: true, // 打印 Emoji
      printTime: false, // 不显示时间，控制台通常已有时间戳
    ),
  );

  /// 调试日志
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 信息日志
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 警告日志
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 错误日志
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 严重错误日志
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// 简化版打印 (类似于 print)
  static void p(dynamic message) {
    if (kDebugMode) {
      _logger.d(message);
    }
  }
}
