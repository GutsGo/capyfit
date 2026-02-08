import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:capyfit/data/services/config_service.dart';

class UpdateInfo {
  final String latestVersion;
  final String releaseNotes;
  final String downloadUrl;
  final bool hasUpdate;
  final bool isForceUpdate;
  final bool shouldNotify;

  UpdateInfo({
    required this.latestVersion,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.hasUpdate,
    this.isForceUpdate = false,
    this.shouldNotify = false,
  });
}

class AppUpdateService {
  final ConfigService _configService = ConfigService();

  /// 检查更新
  Future<UpdateInfo> checkUpdate() async {
    // iOS 平台暂时跳过更新逻辑
    if (Platform.isIOS) {
      return UpdateInfo(
        latestVersion: '',
        releaseNotes: '',
        downloadUrl: '',
        hasUpdate: false,
      );
    }

    try {
      // 获取最新配置（忽略缓存以确保检查到更新）
      final data = await _configService.fetchConfig(ignoreCache: true);

      final String latestVersion = data['latestVersion'];
      final bool isForceUpdate = data['forceUpdate'] ?? false;
      final String releaseNotes = data['changelog'] ?? '无更新日志';

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      bool hasUpdate = _isVersionGreater(latestVersion, currentVersion);
      bool shouldNotify = isForceUpdate;
      if (hasUpdate && !shouldNotify) {
        shouldNotify = _isSignificantUpdate(latestVersion, currentVersion);
      }

      String downloadUrl = '';
      if (hasUpdate) {
        final urls = data['urls'] as Map<String, dynamic>;
        String baseUrl = urls['base'] ?? '';
        if (baseUrl.isNotEmpty && !baseUrl.endsWith('/')) {
          baseUrl += '/';
        }

        if (Platform.isAndroid) {
          final androidUrls = urls['android'] as Map<String, dynamic>;
          final assetPath = await _getBestAndroidAssetPath(androidUrls);
          downloadUrl = '$baseUrl$assetPath';
        } else if (Platform.isIOS) {
          // 虽然前面拦截了，但逻辑完整性保留
          downloadUrl = '$baseUrl${urls['ios'] ?? ''}';
        }
      }

      return UpdateInfo(
        latestVersion: latestVersion,
        releaseNotes: releaseNotes,
        downloadUrl: downloadUrl,
        hasUpdate: hasUpdate,
        isForceUpdate: isForceUpdate,
        shouldNotify: shouldNotify,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 比较版本号 (v1 > v2)
  bool _isVersionGreater(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) return true;
      if (v1Parts[i] < v2Parts[i]) return false;
    }
    return v1Parts.length > v2Parts.length;
  }

  /// 判断是否为重大更新（大版本或中版本变化）
  bool _isSignificantUpdate(String latest, String current) {
    List<int> latestParts = latest
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    List<int> currentParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    // 确保至少有主版本和次版本号
    while (latestParts.length < 2) {
      latestParts.add(0);
    }
    while (currentParts.length < 2) {
      currentParts.add(0);
    }

    // 检查大版本 (Major)
    if (latestParts[0] > currentParts[0]) return true;

    // 检查中版本 (Minor)
    if (latestParts[0] == currentParts[0] && latestParts[1] > currentParts[1]) {
      return true;
    }

    return false;
  }

  /// 根据设备架构获取最佳 Android APK 路径
  Future<String> _getBestAndroidAssetPath(
    Map<String, dynamic> androidUrls,
  ) async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final List<String> supportedAbis = androidInfo.supportedAbis;

    // 优先级排序：arm64-v8a > armeabi-v7a > x86_64
    if (supportedAbis.contains('arm64-v8a') &&
        androidUrls.containsKey('arm64-v8a')) {
      return androidUrls['arm64-v8a'];
    }

    if (supportedAbis.contains('armeabi-v7a') &&
        androidUrls.containsKey('armeabi-v7a')) {
      return androidUrls['armeabi-v7a'];
    }

    if (supportedAbis.contains('x86_64') && androidUrls.containsKey('x86_64')) {
      return androidUrls['x86_64'];
    }

    // 回退逻辑：返回第一个非空的路径
    return androidUrls.values.firstWhere((v) => v != null, orElse: () => '');
  }
}
