import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/food_database.dart';
import '../utils/assets.dart';

/// 食物数据库服务
/// 提供懒加载、缓存和高效搜索功能
class FoodDatabaseService {
  static final FoodDatabaseService _instance = FoodDatabaseService._internal();
  factory FoodDatabaseService() => _instance;
  FoodDatabaseService._internal();

  List<FoodDatabaseItem>? _cachedData;
  bool _isLoading = false;

  /// 检查数据是否已加载
  bool get isLoaded => _cachedData != null;

  /// 获取所有食物数据
  Future<List<FoodDatabaseItem>> getAllFoods() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    if (_isLoading) {
      // 等待加载完成
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _cachedData ?? [];
    }

    _isLoading = true;
    try {
      final jsonString = await rootBundle.loadString(GlobalAssets.foodDb);
      // 使用 compute 在后台线程解析 JSON
      _cachedData = await compute(_parseJson, jsonString);
      return _cachedData!;
    } catch (e) {
      debugPrint('加载食物数据库失败: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// 在后台线程解析 JSON
  static List<FoodDatabaseItem> _parseJson(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => FoodDatabaseItem.fromJson(item)).toList();
  }

  /// 搜索食物
  /// [query] 搜索关键词
  /// [limit] 返回结果数量限制，默认50
  /// [offset] 起始位置，用于分页
  Future<List<FoodDatabaseItem>> search(
    String query, {
    int limit = 50,
    int offset = 0,
  }) async {
    final allFoods = await getAllFoods();

    if (query.isEmpty) {
      // 分页返回所有食物
      final end = (offset + limit).clamp(0, allFoods.length);
      if (offset >= allFoods.length) return [];
      return allFoods.sublist(offset, end);
    }

    final lowerQuery = query.toLowerCase();
    final results = <FoodDatabaseItem>[];
    int matchCount = 0;

    for (final food in allFoods) {
      if (food.foodName.toLowerCase().contains(lowerQuery)) {
        if (matchCount >= offset) {
          results.add(food);
          if (results.length >= limit) break;
        }
        matchCount++;
      }
    }

    return results;
  }

  /// 根据食物代码获取食物
  Future<FoodDatabaseItem?> getFoodByCode(String code) async {
    final allFoods = await getAllFoods();
    try {
      return allFoods.firstWhere((f) => f.foodCode == code);
    } catch (e) {
      return null;
    }
  }

  /// 获取常用食物（前N条）
  Future<List<FoodDatabaseItem>> getPopularFoods({int limit = 20}) async {
    final allFoods = await getAllFoods();
    return allFoods.take(limit).toList();
  }

  /// 预加载数据
  Future<void> preload() async {
    await getAllFoods();
  }
}
