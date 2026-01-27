import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import '../models/diet_entry.dart';
import '../models/exercise.dart';

class UserStats {
  final int totalWorkouts;
  final int totalDuration;
  final int totalCalories;
  final int streakDays;
  final int joinedDays;

  UserStats({
    required this.totalWorkouts,
    required this.totalDuration,
    required this.totalCalories,
    required this.streakDays,
    required this.joinedDays,
  });
}

class AppProvider extends ChangeNotifier {
  final List<WorkoutPlan> _plans = [
    WorkoutPlan(
      id: '1',
      name: '胸部训练',
      date: DateTime.now().toString().split(' ')[0],
      time: '09:00',
      duration: 45,
      type: WorkoutType.strength,
      intensity: Intensity.medium,
      completed: false,
      exercises: ['俯卧撑', '哑铃卧推', '飞鸟'],
    ),
    WorkoutPlan(
      id: '2',
      name: '有氧运动',
      date: DateTime.now().toString().split(' ')[0],
      time: '18:00',
      duration: 30,
      type: WorkoutType.cardio,
      intensity: Intensity.low,
      completed: true,
      exercises: ['慢跑', '开合跳'],
    ),
  ];

  final List<DietEntry> _dietEntries = [
    DietEntry(
      id: '1',
      meal: MealType.breakfast,
      name: '燕麦粥 + 鸡蛋',
      calories: 350,
      protein: 18,
      carbs: 45,
      fat: 12,
      time: '08:00',
    ),
    DietEntry(
      id: '2',
      meal: MealType.lunch,
      name: '鸡胸肉沙拉',
      calories: 450,
      protein: 35,
      carbs: 25,
      fat: 20,
      time: '12:30',
    ),
    DietEntry(
      id: '3',
      meal: MealType.dinner,
      name: '三文鱼 + 蔬菜',
      calories: 520,
      protein: 32,
      carbs: 15,
      fat: 28,
      time: '19:00',
    ),
  ];

  final List<Exercise> _exercises = [
    Exercise(
      id: '1',
      name: '俯卧撑',
      category: ExerciseCategory.chest,
      difficulty: Difficulty.intermediate,
      targetMuscles: ['胸大肌', '三角肌前束', '肱三头肌'],
      sets: 3,
      reps: '8-12次',
      description: '经典的上肢训练动作，主要锻炼胸部肌肉。',
      tips: ['保持身体呈一条直线', '手肘与身体呈45度角', '下落时胸部接近地面'],
    ),
    Exercise(
      id: '2',
      name: '深蹲',
      category: ExerciseCategory.legs,
      difficulty: Difficulty.beginner,
      targetMuscles: ['股四头肌', '臀大肌', '腘绳肌'],
      sets: 3,
      reps: '12-15次',
      description: '下肢训练之王，全面锻炼腿部肌肉。',
      tips: ['膝盖不要超过脚尖', '背部保持挺直', '下蹲至大腿与地面平行'],
    ),
    // ... items can be added later
  ];

  int calorieGoal = 2000;

  List<WorkoutPlan> get plans => _plans;
  List<DietEntry> get dietEntries => _dietEntries;
  List<Exercise> get exercises => _exercises;

  void addPlan(WorkoutPlan plan) {
    _plans.add(plan);
    notifyListeners();
  }

  void togglePlanComplete(String id) {
    final index = _plans.indexWhere((p) => p.id == id);
    if (index != -1) {
      _plans[index] = _plans[index].copyWith(
        completed: !_plans[index].completed,
      );
      notifyListeners();
    }
  }

  void deletePlan(String id) {
    _plans.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void addDietEntry(DietEntry entry) {
    _dietEntries.add(entry);
    notifyListeners();
  }

  void deleteDietEntry(String id) {
    _dietEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  int get todayCalories => _dietEntries.fold(0, (sum, e) => sum + e.calories);
  double get todayProtein =>
      _dietEntries.fold(0.0, (sum, e) => sum + e.protein);
  double get todayCarbs => _dietEntries.fold(0.0, (sum, e) => sum + e.carbs);
  double get todayFat => _dietEntries.fold(0.0, (sum, e) => sum + e.fat);

  UserStats get userStats => UserStats(
    totalWorkouts: _plans.where((p) => p.completed).length,
    totalDuration: _plans
        .where((p) => p.completed)
        .fold(0, (sum, p) => sum + p.duration),
    totalCalories: 8500,
    streakDays: 5,
    joinedDays: 32,
  );
}
