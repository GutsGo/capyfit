import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:capyfit/data/models/exercise.dart';
import 'package:capyfit/data/utils/assets.dart';

/// 动作数据库服务
/// 提供懒加载和高效搜索功能
class ExerciseDbService {
  static final ExerciseDbService _instance = ExerciseDbService._internal();
  factory ExerciseDbService() => _instance;
  ExerciseDbService._internal();

  List<Exercise>? _cachedData;
  bool _isLoading = false;

  /// 检查数据是否已加载
  bool get isLoaded => _cachedData != null;

  /// 获取所有动作数据
  Future<List<Exercise>> getAllExercises() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _cachedData ?? [];
    }

    _isLoading = true;
    try {
      final jsonString = await rootBundle.loadString(GlobalAssets.exerciseDb);
      _cachedData = await compute(_parseJson, jsonString);
      return _cachedData!;
    } catch (e) {
      debugPrint('加载动作数据库失败: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// 在后台线程解析 JSON
  static List<Exercise> _parseJson(String jsonString) {
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((data) {
      // 适配已清洗的 JSON 格式
      ExerciseCategory category;
      final catStr = data['category'] ?? '其他';
      switch (catStr) {
        case '胸部':
          category = ExerciseCategory.chest;
          break;
        case '背部':
          category = ExerciseCategory.back;
          break;
        case '腿部':
          category = ExerciseCategory.legs;
          break;
        case '肩部':
          category = ExerciseCategory.shoulders;
          break;
        case '手臂':
          category = ExerciseCategory.arms;
          break;
        case '核心':
          category = ExerciseCategory.core;
          break;
        case '有氧':
          category = ExerciseCategory.cardio;
          break;
        case '瑜伽':
          category = ExerciseCategory.yoga;
          break;
        default:
          category = ExerciseCategory.other;
      }

      Difficulty difficulty;
      final diffVal = data['difficulty'] ?? 1;
      if (diffVal <= 1) {
        difficulty = Difficulty.beginner;
      } else if (diffVal == 2) {
        difficulty = Difficulty.intermediate;
      } else {
        difficulty = Difficulty.advanced;
      }

      return Exercise(
        id: data['id'].toString(),
        name: data['name'] ?? '未知动作',
        category: category,
        difficulty: difficulty,
        targetMuscles: List<String>.from(data['targetMuscles'] ?? []),
        met: (data['met'] ?? 5.0).toDouble(),
        sets: data['sets'] ?? 3,
        reps: data['reps'],
        description: data['description'],
        tips: List<String>.from(data['tips'] ?? []),
        steps: List<String>.from(data['steps'] ?? []),
        image: '${GlobalAssets.imagesPath}/${data['image']}',
      );
    }).toList();
  }

  /// 搜索并分页
  Future<List<Exercise>> search(
    String query, {
    List<String>? categories,
    int limit = 20,
    int offset = 0,
  }) async {
    final all = await getAllExercises();

    // 过滤
    final filtered = all.where((ex) {
      // 分类过滤
      if (categories != null && categories.isNotEmpty) {
        final catLabel = _getCategoryLabel(ex.category);
        if (!categories.contains(catLabel)) return false;
      }
      // 搜索词过滤
      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        return ex.name.toLowerCase().contains(lowerQuery) ||
            ex.targetMuscles.any((m) => m.toLowerCase().contains(lowerQuery));
      }
      return true;
    }).toList();

    // 排序
    filtered.sort((a, b) {
      final idA = int.tryParse(a.id) ?? 0;
      final idB = int.tryParse(b.id) ?? 0;
      return idA.compareTo(idB);
    });

    // 分页
    final end = (offset + limit).clamp(0, filtered.length);
    if (offset >= filtered.length) return [];
    return filtered.sublist(offset, end);
  }

  String _getCategoryLabel(ExerciseCategory cat) {
    switch (cat) {
      case ExerciseCategory.chest:
        return '胸部';
      case ExerciseCategory.back:
        return '背部';
      case ExerciseCategory.legs:
        return '腿部';
      case ExerciseCategory.shoulders:
        return '肩部';
      case ExerciseCategory.arms:
        return '手臂';
      case ExerciseCategory.core:
        return '核心';
      case ExerciseCategory.cardio:
        return '有氧';
      case ExerciseCategory.yoga:
        return '瑜伽';
      case ExerciseCategory.other:
        return '其他';
    }
  }
}
