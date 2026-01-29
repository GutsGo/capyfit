import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
enum UserGoal {
  @HiveField(0)
  muscleGain,
  @HiveField(1)
  weightLoss,
  @HiveField(2)
  maintain,
}

@HiveType(typeId: 2)
enum Gender {
  @HiveField(0)
  male,
  @HiveField(1)
  female,
}

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  final double height; // cm
  @HiveField(1)
  final double weight; // kg
  @HiveField(2)
  final Gender gender;
  @HiveField(3)
  final int age;
  @HiveField(4)
  final UserGoal goal;
  @HiveField(5)
  final bool isSmartCalculation;
  @HiveField(6)
  final int customCalorieGoal;

  UserProfile({
    required this.height,
    required this.weight,
    required this.gender,
    required this.age,
    required this.goal,
    this.isSmartCalculation = true,
    this.customCalorieGoal = 2000,
  });

  UserProfile copyWith({
    double? height,
    double? weight,
    Gender? gender,
    int? age,
    UserGoal? goal,
    bool? isSmartCalculation,
    int? customCalorieGoal,
  }) {
    return UserProfile(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      isSmartCalculation: isSmartCalculation ?? this.isSmartCalculation,
      customCalorieGoal: customCalorieGoal ?? this.customCalorieGoal,
    );
  }

  int calculateRecommendedCalories() {
    // Mifflin-St Jeor Equation
    double bmr;
    if (gender == Gender.male) {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Activity multiplier (Assuming Moderate Activity: 1.55)
    double tdee = bmr * 1.55;

    // Goal adjustment
    switch (goal) {
      case UserGoal.muscleGain:
        return (tdee + 300).round();
      case UserGoal.weightLoss:
        return (tdee - 500).round();
      case UserGoal.maintain:
        return tdee.round();
    }
  }
}
