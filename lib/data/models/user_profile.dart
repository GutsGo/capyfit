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
  final double? height; // cm
  @HiveField(1)
  final double? weight; // kg
  @HiveField(2)
  final Gender gender;
  @HiveField(3)
  final int? age;
  @HiveField(4)
  final UserGoal goal;
  @HiveField(5)
  final bool isSmartCalculation;
  @HiveField(6)
  final int customCalorieGoal;
  @HiveField(7)
  final String? nickname;
  @HiveField(8)
  final String? avatarPath;
  @HiveField(9)
  final double? targetWeight; // kg
  @HiveField(10)
  final int? dailyStepsGoal;

  UserProfile({
    this.height,
    this.weight,
    required this.gender,
    this.age,
    required this.goal,
    this.isSmartCalculation = true,
    this.customCalorieGoal = 2000,
    this.nickname,
    this.avatarPath,
    this.targetWeight,
    this.dailyStepsGoal,
  });

  UserProfile copyWith({
    Object? height = _sentinel,
    Object? weight = _sentinel,
    Gender? gender,
    Object? age = _sentinel,
    UserGoal? goal,
    bool? isSmartCalculation,
    int? customCalorieGoal,
    Object? nickname = _sentinel,
    Object? avatarPath = _sentinel,
    Object? targetWeight = _sentinel,
    Object? dailyStepsGoal = _sentinel,
  }) {
    return UserProfile(
      height: height == _sentinel ? this.height : (height as double?),
      weight: weight == _sentinel ? this.weight : (weight as double?),
      gender: gender ?? this.gender,
      age: age == _sentinel ? this.age : (age as int?),
      goal: goal ?? this.goal,
      isSmartCalculation: isSmartCalculation ?? this.isSmartCalculation,
      customCalorieGoal: customCalorieGoal ?? this.customCalorieGoal,
      nickname: nickname == _sentinel ? this.nickname : (nickname as String?),
      avatarPath: avatarPath == _sentinel
          ? this.avatarPath
          : (avatarPath as String?),
      targetWeight: targetWeight == _sentinel
          ? this.targetWeight
          : (targetWeight as double?),
      dailyStepsGoal: dailyStepsGoal == _sentinel
          ? this.dailyStepsGoal
          : (dailyStepsGoal as int?),
    );
  }

  static const _sentinel = Object();

  int calculateRecommendedCalories() {
    // Mifflin-St Jeor Equation
    double bmr;

    // Fallback to defaults if data is missing
    final h = height ?? 170.0;
    final w = weight ?? 65.0;
    final a = age ?? 25;

    if (gender == Gender.male) {
      bmr = (10 * w) + (6.25 * h) - (5 * a) + 5;
    } else {
      bmr = (10 * w) + (6.25 * h) - (5 * a) - 161;
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

  // Privacy-aware backup serialization
  Map<String, dynamic> toJsonForBackup() {
    return {
      'goal': goal.index,
      'isSmartCalculation': isSmartCalculation,
      'customCalorieGoal': customCalorieGoal,
      'nickname': nickname,
      'avatarPath': avatarPath,
      'targetWeight': targetWeight,
      'dailyStepsGoal': dailyStepsGoal,
      // Exclude height, weight, gender, age for privacy
    };
  }

  factory UserProfile.fromJsonForBackup(Map<String, dynamic> json) {
    return UserProfile(
      // Default values for sensitive data
      height: 170.0,
      weight: 65.0,
      gender: Gender.values[0], // Default to male if missing (user will update)
      age: 25,
      goal: UserGoal.values[json['goal'] as int? ?? 1],
      isSmartCalculation: json['isSmartCalculation'] as bool? ?? true,
      customCalorieGoal: json['customCalorieGoal'] as int? ?? 2000,
      nickname: json['nickname'] as String?,
      avatarPath: json['avatarPath'] as String?,
      targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      dailyStepsGoal: json['dailyStepsGoal'] as int?,
    );
  }
}
