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
