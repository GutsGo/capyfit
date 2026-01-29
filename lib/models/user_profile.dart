enum UserGoal { muscleGain, weightLoss, maintain }

enum Gender { male, female }

class UserProfile {
  final double height; // cm
  final double weight; // kg
  final Gender gender;
  final int age;
  final UserGoal goal;
  final bool isSmartCalculation;
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
