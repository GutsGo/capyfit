enum MealType { breakfast, lunch, dinner, snack }

class DietEntry {
  final String id;
  final MealType meal;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String time;

  DietEntry({
    required this.id,
    required this.meal,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.time,
  });
}
