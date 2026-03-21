import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 全局错误处理和日志
class AppErrorHandler {
  /// 是否为调试模式
  static bool get isDebug => kDebugMode;
  
  /// 记录错误
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    if (isDebug) {
      print('═══════════════════════════════════════');
      print('[ERROR] $context');
      print('Error: $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
      print('═══════════════════════════════════════');
    }
  }
  
  /// 记录警告
  static void logWarning(String context, String message) {
    if (isDebug) {
      print('[WARNING] $context: $message');
    }
  }
  
  /// 记录信息
  static void logInfo(String context, String message) {
    if (isDebug) {
      print('[INFO] $context: $message');
    }
  }
  
  /// 安全执行异步操作
  static Future<T?> safeAsync<T>(
    Future<T?> Function() operation, {
    required String operationName,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      logError(operationName, e, stackTrace);
      return defaultValue;
    }
  }
  
  /// 安全执行同步操作
  static T? safeSync<T>(
    T? Function() operation, {
    required String operationName,
    T? defaultValue,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      logError(operationName, e, stackTrace);
      return defaultValue;
    }
  }
  
  /// 显示错误弹窗
  static void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('❌ $title'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  /// 显示警告弹窗
  static void showWarningDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('⚠️ $title'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
