/// 食物数据库模型
/// 完整映射 food_db.json 的数据结构
library;

import 'food_item.dart';

class FoodDatabaseItem {
  final String foodCode;
  final String foodName;
  final String edible; // 可食部
  final String water; // 水分
  final String energyKCal; // 能量(kcal)
  final String energyKJ; // 能量(kJ)
  final String protein; // 蛋白质
  final String fat; // 脂肪
  final String cho; // 碳水化合物
  final String dietaryFiber; // 膳食纤维
  final String cholesterol; // 胆固醇
  final String ash; // 灰分
  final String vitaminA; // 维生素A
  final String carotene; // 胡萝卜素
  final String retinol; // 视黄醇
  final String thiamin; // 硫胺素(B1)
  final String riboflavin; // 核黄素(B2)
  final String niacin; // 烟酸
  final String vitaminC; // 维生素C
  final String vitaminETotal; // 维生素E总量
  final String vitaminE1; // α-维生素E
  final String vitaminE2; // β-维生素E
  final String vitaminE3; // γ-维生素E
  final String ca; // 钙
  final String p; // 磷
  final String k; // 钾
  final String na; // 钠
  final String mg; // 镁
  final String fe; // 铁
  final String zn; // 锌
  final String se; // 硒
  final String cu; // 铜
  final String mn; // 锰
  final String remark; // 备注
  final String emoji;
  final String category;

  const FoodDatabaseItem({
    required this.foodCode,
    required this.foodName,
    required this.energyKCal,
    required this.protein,
    required this.fat,
    required this.cho,
    this.edible = '100',
    this.water = '—',
    this.energyKJ = '0',
    this.dietaryFiber = '—',
    this.cholesterol = '—',
    this.ash = '—',
    this.vitaminA = '—',
    this.carotene = '—',
    this.retinol = '—',
    this.thiamin = '—',
    this.riboflavin = '—',
    this.niacin = '—',
    this.vitaminC = '—',
    this.vitaminETotal = '—',
    this.vitaminE1 = '—',
    this.vitaminE2 = '—',
    this.vitaminE3 = '—',
    this.ca = '—',
    this.p = '—',
    this.k = '—',
    this.na = '—',
    this.mg = '—',
    this.fe = '—',
    this.zn = '—',
    this.se = '—',
    this.cu = '—',
    this.mn = '—',
    this.remark = '',
    this.emoji = '🍴',
    this.category = '调味品类',
  });

  factory FoodDatabaseItem.fromJson(Map<String, dynamic> json) {
    return FoodDatabaseItem(
      foodCode: json['foodCode'] as String? ?? '',
      foodName: json['foodName'] as String? ?? '',
      edible: json['edible'] as String? ?? '—',
      water: json['water'] as String? ?? '—',
      energyKCal: json['energyKCal'] as String? ?? '0',
      energyKJ: json['energyKJ'] as String? ?? '0',
      protein: json['protein'] as String? ?? '0',
      fat: json['fat'] as String? ?? '0',
      cho: json['CHO'] as String? ?? '0',
      dietaryFiber: json['dietaryFiber'] as String? ?? '—',
      cholesterol: json['cholesterol'] as String? ?? '—',
      ash: json['ash'] as String? ?? '—',
      vitaminA: json['vitaminA'] as String? ?? '—',
      carotene: json['carotene'] as String? ?? '—',
      retinol: json['retinol'] as String? ?? '—',
      thiamin: json['thiamin'] as String? ?? '—',
      riboflavin: json['riboflavin'] as String? ?? '—',
      niacin: json['niacin'] as String? ?? '—',
      vitaminC: json['vitaminC'] as String? ?? '—',
      vitaminETotal: json['vitaminETotal'] as String? ?? '—',
      vitaminE1: json['vitaminE1'] as String? ?? '—',
      vitaminE2: json['vitaminE2'] as String? ?? '—',
      vitaminE3: json['vitaminE3'] as String? ?? '—',
      ca: json['Ca'] as String? ?? '—',
      p: json['P'] as String? ?? '—',
      k: json['K'] as String? ?? '—',
      na: json['Na'] as String? ?? '—',
      mg: json['Mg'] as String? ?? '—',
      fe: json['Fe'] as String? ?? '—',
      zn: json['Zn'] as String? ?? '—',
      se: json['Se'] as String? ?? '—',
      cu: json['Cu'] as String? ?? '—',
      mn: json['Mn'] as String? ?? '—',
      remark: json['remark'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🍴',
      category: json['category'] as String? ?? '调味品类',
    );
  }

  /// 解析数值，处理 "—" 和 "Tr" 等特殊值
  double _parseValue(String value) {
    if (value == '—' || value == 'Tr' || value.isEmpty) {
      return 0.0;
    }
    return double.tryParse(value) ?? 0.0;
  }

  /// 获取热量（kcal）
  double get calories => _parseValue(energyKCal);

  /// 获取蛋白质（g）
  double get proteinValue => _parseValue(protein);

  /// 获取脂肪（g）
  double get fatValue => _parseValue(fat);

  /// 获取碳水化合物（g）
  double get carbsValue => _parseValue(cho);

  /// 获取膳食纤维（g）
  double get fiberValue => _parseValue(dietaryFiber);

  /// 获取水分（g）
  double get waterValue => _parseValue(water);

  /// 转换为 FoodItem（用于持久化存储）
  FoodItem toFoodItem() {
    return FoodItem(
      id: foodCode,
      name: foodName,
      caloriesPer100g: calories,
      proteinPer100g: proteinValue,
      carbsPer100g: carbsValue,
      fatPer100g: fatValue,
      emoji: emoji == '🍴' ? null : emoji,
    );
  }
}
