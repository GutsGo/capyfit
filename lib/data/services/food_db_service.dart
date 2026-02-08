import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:capyfit/data/models/food_database.dart';
import 'package:capyfit/data/utils/assets.dart';
import 'package:capyfit/data/utils/logger.dart';

/// 食物数据库服务
/// 提供懒加载、缓存和高效搜索功能
class FoodDbService {
  static final FoodDbService _instance = FoodDbService._internal();
  factory FoodDbService() => _instance;
  FoodDbService._internal();

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
      Log.e('加载食物数据库失败', e);
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
    List<String>? categories,
    int limit = 50,
    int offset = 0,
  }) async {
    final allFoods = await getAllFoods();
    final lowerQuery = query.toLowerCase();

    // 过滤逻辑
    final filteredFoods = allFoods.where((food) {
      // 关键词过滤
      bool matchesQuery = true;
      if (lowerQuery.isNotEmpty) {
        matchesQuery = food.foodName.toLowerCase().contains(lowerQuery);
      }

      // 分类过滤
      bool matchesCategory = true;
      if (categories != null && categories.isNotEmpty) {
        matchesCategory = categories.contains(food.category);
      }
      return matchesQuery && matchesCategory;
    }).toList();

    if (query.isNotEmpty) {
      // 优化排序：完全匹配 > 前缀匹配 > 包含匹配
      filteredFoods.sort((a, b) {
        final aName = a.foodName.toLowerCase();
        final bName = b.foodName.toLowerCase();

        // 1. 完全匹配优先
        if (aName == lowerQuery && bName != lowerQuery) return -1;
        if (bName == lowerQuery && aName != lowerQuery) return 1;

        // 2. 前缀匹配优先
        final aStarts = aName.startsWith(lowerQuery);
        final bStarts = bName.startsWith(lowerQuery);
        if (aStarts && !bStarts) return -1;
        if (bStarts && !aStarts) return 1;

        // 3. 长度更短（更精准）优先 (例如 "辣椒" 优于 "辣椒油")
        return aName.length.compareTo(bName.length);
      });
    }

    // 分页
    final end = (offset + limit).clamp(0, filteredFoods.length);
    if (offset >= filteredFoods.length) return [];
    return filteredFoods.sublist(offset, end);
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
