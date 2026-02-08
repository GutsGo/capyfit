import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:capyfit/data/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:capyfit/data/utils/constants.dart';

/// 全局配置服务，负责获取与缓存 capy_conf.json
class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  static const String _releaseConfigUrl =
      '${GlobalConstants.updateBaseUrl}/capy_conf.json';
  static const String _debugConfigUrl =
      '${GlobalConstants.updateBaseUrl}/capy_conf.debug.json';

  Map<String, dynamic>? _cachedConfig;
  DateTime? _lastFetchTime;

  /// 获取配置信息
  /// [ignoreCache] 是否忽略缓存强制刷新
  Future<Map<String, dynamic>> fetchConfig({bool ignoreCache = false}) async {
    if (!ignoreCache && _cachedConfig != null) {
      return _cachedConfig!;
    }

    try {
      final configUrl = kDebugMode ? _debugConfigUrl : _releaseConfigUrl;
      final response = await http.get(Uri.parse(configUrl));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic>) {
          _cachedConfig = data;
          _lastFetchTime = DateTime.now();

          Log.i(data);
          return _cachedConfig!;
        } else {
          throw Exception('配置格式错误');
        }
      } else {
        throw Exception('无法获取配置信息: ${response.statusCode}');
      }
    } catch (e) {
      if (_cachedConfig != null) {
        Log.e('获取新配置失败，使用缓存数据', e);
        return _cachedConfig!;
      }
      rethrow;
    }
  }

  /// 获取缓存的配置（不触发网络请求）
  Map<String, dynamic>? get cachedConfig => _cachedConfig;

  /// 获取上次更新时间
  DateTime? get lastFetchTime => _lastFetchTime;
}
