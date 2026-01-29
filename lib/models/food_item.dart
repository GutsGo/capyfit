import 'package:hive/hive.dart';

part 'food_item.g.dart';

@HiveType(typeId: 6)
class FoodItem extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double caloriesPer100g;
  @HiveField(3)
  final double proteinPer100g;
  @HiveField(4)
  final double carbsPer100g;
  @HiveField(5)
  final double fatPer100g;
  @HiveField(6)
  final String? emoji;

  FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.emoji,
  });
}
