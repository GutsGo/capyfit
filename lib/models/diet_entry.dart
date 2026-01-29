import 'package:hive/hive.dart';

part 'diet_entry.g.dart';

@HiveType(typeId: 8)
enum MealType {
  @HiveField(0)
  breakfast,
  @HiveField(1)
  lunch,
  @HiveField(2)
  dinner,
  @HiveField(3)
  snack,
}

@HiveType(typeId: 7)
class DietEntry extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final MealType meal;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final int calories;
  @HiveField(4)
  final double protein;
  @HiveField(5)
  final double carbs;
  @HiveField(6)
  final double fat;
  @HiveField(7)
  final String time;
  @HiveField(8)
  final String date;

  DietEntry({
    required this.id,
    required this.meal,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.time,
    required this.date,
  });

  DietEntry copyWith({
    String? id,
    MealType? meal,
    String? name,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? time,
    String? date,
  }) {
    return DietEntry(
      id: id ?? this.id,
      meal: meal ?? this.meal,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      time: time ?? this.time,
      date: date ?? this.date,
    );
  }
}
