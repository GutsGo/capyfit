import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:capyfit/data/models/diet_entry.dart';
import 'package:capyfit/data/models/exercise.dart';
import 'package:capyfit/data/models/food_item.dart';
import 'package:capyfit/data/models/user_profile.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/data/models/daily_step_entry.dart';
import 'package:capyfit/data/services/hive_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:capyfit/data/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  final HiveService _hiveService = HiveService();

  /// 计算数据的 HMAC 签名
  String _generateSignature(Map<String, dynamic> data) {
    final String dataString = jsonEncode(data);
    final List<int> keyBytes = utf8.encode(GlobalConstants.backupAuthKey);
    final List<int> dataBytes = utf8.encode(dataString);

    final Hmac hmac = Hmac(sha256, keyBytes);
    final Digest digest = hmac.convert(dataBytes);

    return digest.toString();
  }

  Future<String> exportData() async {
    try {
      final Map<String, dynamic> dataContent = _collectDataContent();
      final String signature = _generateSignature(dataContent);

      final Map<String, dynamic> fullData = {
        'meta': {
          'version': 2, // 升级版本号以启用签名校验
          'timestamp': DateTime.now().toIso8601String(),
          'appName': 'CapyFit',
          'signature': signature,
        },
        'data': dataContent,
      };

      final jsonString = jsonEncode(fullData);
      final fileName =
          'capyfit_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';

      // Android: Allow user to choose save location directly
      if (Platform.isAndroid) {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: '请选择保存位置',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: utf8.encode(jsonString),
        );

        if (outputFile != null) {
          // On Android with scoped storage (SAF), saveFile with `bytes` writes the file securely.
          // The returned path might be a content URI or virtual path not accessible by File API.
          // So we do not need (and cannot) write to it manually again.
          await _hiveService.saveLastBackupTime(DateTime.now());
          return '备份成功';
        } else {
          return '取消导出';
        }
      } else {
        // iOS: Use native share sheet (Save to Files included)
        // because "Save As" is not standard on iOS.
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsString(jsonString);

        final result = await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], subject: 'CapyFit 数据备份'),
        );

        if (result.status == ShareResultStatus.success) {
          await _hiveService.saveLastBackupTime(DateTime.now());
          return '备份导出成功';
        } else {
          return '备份已取消';
        }
      }
    } catch (e) {
      debugPrint('Export error: $e');
      throw '导出失败: $e';
    }
  }

  Future<String> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonString);

        if (!_validateSchema(data)) {
          throw '无效的备份文件格式';
        }

        // 强校验签名完整性 (目前仅支持 Version 2 及以上，且强制校验)
        final int version = data['meta']?['version'] ?? 0;
        final String? fileSignature = data['meta']?['signature'];
        final Map<String, dynamic>? dataContent = data['data'];

        if (version < 2 || fileSignature == null || dataContent == null) {
          throw '该备份文件已过时或格式不正确，无法导入';
        }

        final String calculatedSignature = _generateSignature(dataContent);
        if (fileSignature != calculatedSignature) {
          debugPrint('Signature mismatch! Data might be tampered.');
          throw '备份文件签名无效（数据可能已被篡改），导入已取消';
        }

        await _restoreData(data);
        return '数据恢复成功';
      } else {
        return '取消导入';
      }
    } catch (e) {
      debugPrint('Import error: $e');
      throw '导入失败: $e';
    }
  }

  Map<String, dynamic> _collectDataContent() {
    return {
      'userProfile': _hiveService.getUserProfile()?.toJsonForBackup(),
      'dietEntries': _hiveService
          .getDietEntries()
          .map((e) => e.toJson())
          .toList(),
      'workoutPlans': _hiveService
          .getWorkoutPlans()
          .map((e) => e.toJson())
          .toList(),
      'exercises': _hiveService.getExercises().map((e) => e.toJson()).toList(),
      'foodItems': _hiveService.getFoodItems().map((e) => e.toJson()).toList(),
      'dailySteps': _hiveService
          .getDailySteps()
          .map((e) => {'date': e.date, 'steps': e.steps})
          .toList(),
      'settings': {
        'joinedDate': _hiveService.joinedDate?.millisecondsSinceEpoch,
        'earnedMedals': _hiveService.getEarnedMedalJsonList(),
      },
    };
  }

  bool _validateSchema(Map<String, dynamic> data) {
    return data.containsKey('meta') &&
        data.containsKey('data') &&
        data['data'] is Map;
  }

  Future<void> _restoreData(Map<String, dynamic> data) async {
    final Map<String, dynamic> content = data['data'];

    // 1. Restore UserProfile (Merge strategy)
    if (content.containsKey('userProfile') && content['userProfile'] != null) {
      final importedProfile = UserProfile.fromJsonForBackup(
        content['userProfile'],
      );
      final currentProfile = _hiveService.getUserProfile();

      if (currentProfile != null) {
        // Merge: keep current sensitive data, overwrite settings
        final mergedProfile = currentProfile.copyWith(
          goal: importedProfile.goal,
          isSmartCalculation: importedProfile.isSmartCalculation,
          customCalorieGoal: importedProfile.customCalorieGoal,
          nickname: importedProfile.nickname,
          avatarPath: importedProfile.avatarPath,
          targetWeight: importedProfile.targetWeight,
          dailyStepsGoal: importedProfile.dailyStepsGoal,
          // height, weight, gender, age are kept from currentProfile because importedProfile has defaults
        );
        await _hiveService.saveUserProfile(mergedProfile);
      } else {
        // If no profile exists, save imported one (user will need to update height/weight/age)
        await _hiveService.saveUserProfile(importedProfile);
      }
    }

    // 1.1 Restore Settings (JoinedDate and Medals)
    if (content.containsKey('settings')) {
      final Map<String, dynamic> settings = content['settings'];
      if (settings.containsKey('joinedDate') &&
          settings['joinedDate'] != null) {
        await _hiveService.saveJoinedDate(
          DateTime.fromMillisecondsSinceEpoch(settings['joinedDate']),
        );
      }
      if (settings.containsKey('earnedMedals')) {
        final List<String> medals = List<String>.from(settings['earnedMedals']);
        await _hiveService.saveEarnedMedalJsonList(medals);
      }
    }

    // 2. Restore DietEntries
    if (content.containsKey('dietEntries')) {
      final List list = content['dietEntries'];
      for (var item in list) {
        final entry = DietEntry.fromJson(item);
        await _hiveService.saveDietEntry(entry);
      }
    }

    // 3. Restore WorkoutPlans
    if (content.containsKey('workoutPlans')) {
      final List list = content['workoutPlans'];
      for (var item in list) {
        final plan = WorkoutPlan.fromJson(item);
        await _hiveService.saveWorkoutPlan(plan);
      }
    }

    // 4. Restore Custom Exercises
    if (content.containsKey('exercises')) {
      final List list = content['exercises'];
      for (var item in list) {
        final exercise = Exercise.fromJson(item);
        await _hiveService.saveExercise(exercise);
      }
    }

    // 5. Restore Custom Food Items
    if (content.containsKey('foodItems')) {
      final List list = content['foodItems'];
      for (var item in list) {
        final food = FoodItem.fromJson(item);
        await _hiveService.saveFoodItem(food);
      }
    }

    // 6. Restore Daily Steps
    if (content.containsKey('dailySteps')) {
      final List list = content['dailySteps'];
      for (var item in list) {
        final entry = DailyStepEntry(date: item['date'], steps: item['steps']);
        await _hiveService.saveDailySteps(entry);
      }
    }
  }
}
