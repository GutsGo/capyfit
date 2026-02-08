import 'package:capyfit/data/models/food_database.dart';
import 'package:capyfit/data/models/user_profile.dart';
import 'package:capyfit/data/services/config_service.dart';
import 'package:capyfit/data/services/food_db_service.dart';
import 'package:capyfit/data/services/ai_coach_service.dart';
import 'package:capyfit/data/utils/diet_parser.dart';

class EstimatedDietItem {
  final FoodDatabaseItem food;
  final double estimatedWeight; // 克
  final ParsedFoodItem source;

  EstimatedDietItem({
    required this.food,
    required this.estimatedWeight,
    required this.source,
  });

  double get calories =>
      (food.calories * estimatedWeight / 100).roundToDouble();
  double get protein => food.proteinValue * estimatedWeight / 100;
  double get carbs => food.carbsValue * estimatedWeight / 100;
  double get fat => food.fatValue * estimatedWeight / 100;
}

class DietEstimationService {
  final FoodDbService _foodDbService = FoodDbService();

  final ConfigService _configService = ConfigService();

  /// 默认单位权重回退 (当远程配置不可用时使用)
  static const Map<String, double> _defaultUnitWeights = {
    '碗': 200.0,
    '个': 50.0,
    '份': 250.0,
    '两': 50.0,
    '克': 1.0,
    'g': 1.0,
  };

  /// 默认别名回退
  static const Map<String, String> _defaultSynonyms = {
    '青椒': '辣椒',
    '甜椒': '辣椒',
    '米饭': '稻米',
    '肉丝': '猪肉',
    '肉片': '猪肉',
    '西红柿': '番茄',
    '土豆': '马铃薯',
    '大白菜': '白菜',
  };

  /// 获取动态配置中的单位权重
  Map<String, double> _getUnitWeights() {
    final remote = _configService.cachedConfig?['diet']?['unit_weights'];
    if (remote is Map) {
      return remote.map((k, v) => MapEntry(k.toString(), v.toDouble()));
    }
    return _defaultUnitWeights;
  }

  /// 获取动态配置中的别名映射
  Map<String, String> _getSynonyms() {
    final remote = _configService.cachedConfig?['diet']?['synonyms'];
    if (remote is Map) {
      return remote.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return _defaultSynonyms;
  }

  Future<List<EstimatedDietItem>> estimate(
    String input,
    UserProfile profile,
  ) async {
    // 逻辑保持不变...
    final parsedItems = DietParser.parse(input);
    return _processParsedItems(parsedItems, profile);
  }

  /// 使用 AI 进行更智能的解析
  Future<List<EstimatedDietItem>> aiEstimate({
    required String input,
    required UserProfile profile,
  }) async {
    final aiCoachService = AICoachService();
    final aiParsedItems = await aiCoachService.parseDietItems(input);

    if (aiParsedItems == null) {
      // 如果 AI 解析失败，回退到原有的正则解析
      return estimate(input, profile);
    }

    return _processParsedItems(aiParsedItems, profile);
  }

  /// 抽取的通用处理逻辑
  Future<List<EstimatedDietItem>> _processParsedItems(
    List<ParsedFoodItem> parsedItems,
    UserProfile profile,
  ) async {
    final List<EstimatedDietItem> results = [];

    // 计算用户的“食量伸缩系数”
    final double userTdee = profile.calculateRecommendedCalories().toDouble();
    final double scaleFactor = (userTdee / 2000.0).clamp(0.8, 1.5);

    for (final parsed in parsedItems) {
      // 1. 多阶段回退搜索
      FoodDatabaseItem? match;
      var matches = await _foodDbService.search(parsed.rawName, limit: 1);

      // 阶段 1b: 去掉 () 和 [] 及其内容后再搜索 (处理如: "甘薯（红心）[山芋，红薯]" -> "甘薯")
      if (matches.isEmpty) {
        final cleanName = parsed.rawName
            .replaceAll(RegExp(r'[\(（].*?[\)）]'), '') // 去掉圆括号内容
            .replaceAll(RegExp(r'[\[［].*?[\]］]'), '') // 去掉方括号内容
            .trim();
        if (cleanName.isNotEmpty && cleanName != parsed.rawName) {
          matches = await _foodDbService.search(cleanName, limit: 1);
        }
      }

      if (matches.isEmpty) {
        final synonyms = _getSynonyms();
        for (var entry in synonyms.entries) {
          if (parsed.rawName.contains(entry.key)) {
            matches = await _foodDbService.search(entry.value, limit: 1);
            if (matches.isNotEmpty) break;
          }
        }
      }

      if (matches.isEmpty && parsed.rawName.length > 2) {
        final cleanName = parsed.rawName.replaceAll(
          RegExp(r'[炒烩炖炸煮蒸煎烤汤拌]'),
          '',
        );
        if (cleanName != parsed.rawName) {
          matches = await _foodDbService.search(cleanName, limit: 1);
        }
      }

      if (matches.isEmpty) {
        final keywords = ['肉', '蛋', '饭', '面', '菜', '鱼'];
        for (var kw in keywords) {
          if (parsed.rawName.contains(kw)) {
            matches = await _foodDbService.search(kw, limit: 1);
            if (matches.isNotEmpty) break;
          }
        }
      }

      if (matches.isEmpty) continue;
      match = matches.first;

      // 2. 科学权重估算逻辑
      double baseWeight = _calculateBaseWeight(match, parsed.unit);

      // 3. 计算最终重量
      double finalWeight = baseWeight * (parsed.amount ?? 1.0) * scaleFactor;

      // 如果是明确以克/g为单位，不应再进行 TDEE 缩放（用户输入的就是精确值）
      if (parsed.unit == '克' || parsed.unit == 'g') {
        finalWeight = baseWeight * (parsed.amount ?? 1.0);
      }

      results.add(
        EstimatedDietItem(
          food: match,
          estimatedWeight: finalWeight,
          source: parsed,
        ),
      );
    }

    return results;
  }

  /// 差异化基础权重计算
  double _calculateBaseWeight(FoodDatabaseItem food, String? unit) {
    final weights = _getUnitWeights();

    // 如果没有单位，默认按“份”计算
    final effectiveUnit = unit ?? '份';
    double weight = weights[effectiveUnit] ?? 250.0;

    // 针对不同类别的科学修正
    if (effectiveUnit == '碗') {
      if (food.foodName.contains('粥') || food.category.contains('汤')) {
        weight = 300.0; // 汤水类更重
      } else if (food.foodName.contains('米饭')) {
        weight = 200.0;
      }
    } else if (effectiveUnit == '个') {
      if (food.category.contains('水果')) {
        weight = 180.0; // 中等水果
      } else if (food.foodName.contains('蛋')) {
        weight = 50.0; // 一个鸡蛋
      }
    } else if (effectiveUnit == '份') {
      if (food.category.contains('肉')) {
        weight = 200.0; // 肉类一份通常较少（如一份鸡排）
      }
    }

    return weight;
  }
}
