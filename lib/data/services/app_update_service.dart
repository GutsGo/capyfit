import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:capyfit/data/utils/constants.dart';

class UpdateInfo {
  final String latestVersion;
  final String releaseNotes;
  final String downloadUrl;
  final bool hasUpdate;

  UpdateInfo({
    required this.latestVersion,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.hasUpdate,
  });
}

class AppUpdateService {
  static const String _apiUrl = GlobalConstants.githubLatestReleaseUrl;

  /// 检查更新
  Future<UpdateInfo> checkUpdate() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String latestVersion = data['tag_name'].toString().replaceFirst(
          'v',
          '',
        );
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        bool hasUpdate = _isVersionGreater(latestVersion, currentVersion);

        String downloadUrl = '';
        if (hasUpdate) {
          final assets = data['assets'] as List;
          downloadUrl = await _getBestDownloadUrl(assets, latestVersion);
        }

        return UpdateInfo(
          latestVersion: data['tag_name'],
          releaseNotes: data['body'] ?? '无更新日志',
          downloadUrl: downloadUrl,
          hasUpdate: hasUpdate,
        );
      } else {
        throw Exception('无法获取更新信息: ${response.statusCode}');
      }
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

  /// 根据设备架构获取最佳下载链接
  Future<String> _getBestDownloadUrl(List assets, String version) async {
    if (!Platform.isAndroid) {
      // 非 Android 平台返回默认 Release 页面
      return GlobalConstants.githubLatestReleaseHtmlUrl;
    }

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final List<String> supportedAbis = androidInfo.supportedAbis;

    String? bestMatch;

    // 优先级排序：arm64-v8a > armeabi-v7a > x86_64
    if (supportedAbis.contains('arm64-v8a')) {
      bestMatch = _findAsset(assets, 'arm64-v8a');
    }

    if (bestMatch == null && supportedAbis.contains('armeabi-v7a')) {
      bestMatch = _findAsset(assets, 'armeabi-v7a');
    }

    if (bestMatch == null && supportedAbis.contains('x86_64')) {
      bestMatch = _findAsset(assets, 'x86_64');
    }

    // 如果没有找到特定架构的，尝试找通用包或返回第一个 asset
    return bestMatch ??
        (assets.isNotEmpty ? assets[0]['browser_download_url'] : '');
  }

  String? _findAsset(List assets, String arch) {
    for (var asset in assets) {
      final String name = asset['name'].toString().toLowerCase();
      if (name.contains(arch) && name.endsWith('.apk')) {
        return asset['browser_download_url'];
      }
    }
    return null;
  }
}
