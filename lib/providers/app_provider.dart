import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import '../models/diet_entry.dart';
import '../models/exercise.dart';
import '../models/food_item.dart';
import '../models/user_profile.dart';
import '../services/hive_service.dart';

class UserStats {
  final int totalWorkouts;
  final int totalDuration;
  final int totalCalories;
  final int streakDays;
  final int joinedDays;
  final int activeDays; // 累计有计划完成的天数
  final int weeklyWorkoutCount;
  final double weeklyDurationHours;
  final int todayCalories;

  UserStats({
    required this.totalWorkouts,
    required this.totalDuration,
    required this.totalCalories,
    required this.streakDays,
    required this.joinedDays,
    required this.activeDays,
    required this.weeklyWorkoutCount,
    required this.weeklyDurationHours,
    required this.todayCalories,
  });
}

class AppProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get hasUserProfile => _hiveService.hasUserProfile;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  List<WorkoutPlan> _plans = [];
  List<DietEntry> _dietEntries = [];
  List<FoodItem> _foodPresets = [];
  List<Exercise> _exercises = [];
  UserProfile? _userProfile;

  Future<void> init() async {
    await _hiveService.init();

    // Load theme mode
    final savedThemeMode = _hiveService.themeMode;
    switch (savedThemeMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    // Load data from Hive
    _userProfile = _hiveService.getUserProfile();
    _plans = _hiveService.getWorkoutPlans();
    _dietEntries = _hiveService.getDietEntries();
    _foodPresets = _hiveService.getFoodItems();
    _exercises = _hiveService.getExercises();

    _isInitialized = true;
    notifyListeners();
  }

  void toggleThemeMode() {
    if (_themeMode == ThemeMode.system) {
      _themeMode = ThemeMode.light;
      _hiveService.saveThemeMode('light');
    } else if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      _hiveService.saveThemeMode('dark');
    } else {
      _themeMode = ThemeMode.system;
      _hiveService.saveThemeMode('system');
    }
    notifyListeners();
  }

  UserProfile get userProfile =>
      _userProfile ??
      UserProfile(
        height: 175,
        weight: 70,
        gender: Gender.male,
        age: 25,
        goal: UserGoal.maintain,
        isSmartCalculation: true,
      );

  int get calorieGoal => userProfile.isSmartCalculation
      ? _calculateSmartCalorieGoal()
      : userProfile.customCalorieGoal;

  void updateUserProfile(UserProfile profile) {
    final isFirstProfile =
        _userProfile == null && _hiveService.joinedDate == null;
    _userProfile = profile;
    _hiveService.saveUserProfile(profile);
    // Save joined date when creating first profile
    if (isFirstProfile) {
      _hiveService.saveJoinedDate(DateTime.now());
    }
    notifyListeners();
  }

  int _calculateSmartCalorieGoal() {
    return userProfile.calculateRecommendedCalories();
  }

  double get carbGoal {
    int totalCals = calorieGoal;
    switch (userProfile.goal) {
      case UserGoal.muscleGain:
        return (totalCals * 0.45 / 4);
      case UserGoal.weightLoss:
        return (totalCals * 0.40 / 4);
      case UserGoal.maintain:
        return (totalCals * 0.50 / 4);
    }
  }

  double get proteinGoal {
    int totalCals = calorieGoal;
    switch (userProfile.goal) {
      case UserGoal.muscleGain:
        return (totalCals * 0.30 / 4);
      case UserGoal.weightLoss:
        return (totalCals * 0.40 / 4);
      case UserGoal.maintain:
        return (totalCals * 0.20 / 4);
    }
  }

  double get fatGoal {
    int totalCals = calorieGoal;
    switch (userProfile.goal) {
      case UserGoal.muscleGain:
        return (totalCals * 0.25 / 9);
      case UserGoal.weightLoss:
        return (totalCals * 0.20 / 9);
      case UserGoal.maintain:
        return (totalCals * 0.30 / 9);
    }
  }

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  List<WorkoutPlan> get plans => _plans;
  List<DietEntry> get dietEntries => _dietEntries;
  List<Exercise> get exercises => _exercises;
  List<FoodItem> get foodPresets => _foodPresets;

  void addFoodPreset(FoodItem item) {
    _foodPresets.add(item);
    _hiveService.saveFoodItem(item);
    notifyListeners();
  }

  void addPlan(WorkoutPlan plan) {
    _plans.add(plan);
    _hiveService.saveWorkoutPlan(plan);
    notifyListeners();
  }

  void togglePlanComplete(String id, {String? forDate}) {
    final index = _plans.indexWhere((p) => p.id == id);
    if (index != -1) {
      final dateStr = forDate ?? DateTime.now().toString().split(' ')[0];
      final updatedPlan = _plans[index].toggleCompletionFor(dateStr);
      _plans[index] = updatedPlan;
      _hiveService.saveWorkoutPlan(updatedPlan);
      notifyListeners();
    }
  }

  void deletePlan(String id) {
    _plans.removeWhere((p) => p.id == id);
    _hiveService.deleteWorkoutPlan(id);
    notifyListeners();
  }

  void addDietEntry(DietEntry entry) {
    _dietEntries.add(entry);
    _hiveService.saveDietEntry(entry);
    notifyListeners();
  }

  void deleteDietEntry(String id) {
    _dietEntries.removeWhere((e) => e.id == id);
    _hiveService.deleteDietEntry(id);
    notifyListeners();
  }

  int getTodayCalories(String date) => _dietEntries
      .where((e) => e.date == date)
      .fold(0, (sum, e) => sum + e.calories);

  double getTodayProtein(String date) => _dietEntries
      .where((e) => e.date == date)
      .fold(0.0, (sum, e) => sum + e.protein);

  double getTodayCarbs(String date) => _dietEntries
      .where((e) => e.date == date)
      .fold(0.0, (sum, e) => sum + e.carbs);

  double getTodayFat(String date) => _dietEntries
      .where((e) => e.date == date)
      .fold(0.0, (sum, e) => sum + e.fat);

  int get todayCalories =>
      getTodayCalories(DateTime.now().toString().split(' ')[0]);

  int get todayConsumedCalories {
    final todayStr = DateTime.now().toString().split(' ')[0];
    return _plans
        .where((p) => p.isCompletedOn(todayStr))
        .fold(0, (sum, p) => sum + p.calories);
  }

  double get todayProtein =>
      getTodayProtein(DateTime.now().toString().split(' ')[0]);
  double get todayCarbs =>
      getTodayCarbs(DateTime.now().toString().split(' ')[0]);
  double get todayFat => getTodayFat(DateTime.now().toString().split(' ')[0]);

  // Get the start of current week (Monday)
  DateTime get _weekStart {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: weekday - 1));
  }

  int get weeklyWorkoutCount {
    final weekStartStr = _weekStart.toString().split(' ')[0];
    int count = 0;
    for (var p in _plans) {
      if (p.mode == PlanMode.oneTime) {
        if (p.completed && p.date.compareTo(weekStartStr) >= 0) {
          count++;
        }
      } else {
        // longTerm: check completedDates
        if (p.completedDates != null) {
          count += p.completedDates!
              .where((d) => d.compareTo(weekStartStr) >= 0)
              .length;
        }
      }
    }
    return count;
  }

  int get weeklyDurationMinutes {
    final weekStartStr = _weekStart.toString().split(' ')[0];
    int total = 0;
    for (var p in _plans) {
      if (p.mode == PlanMode.oneTime) {
        if (p.completed && p.date.compareTo(weekStartStr) >= 0) {
          total += p.duration;
        }
      } else {
        // longTerm: check completedDates
        if (p.completedDates != null) {
          total +=
              p.completedDates!
                  .where((d) => d.compareTo(weekStartStr) >= 0)
                  .length *
              p.duration;
        }
      }
    }
    return total;
  }

  double get weeklyDurationHours => weeklyDurationMinutes / 60;

  UserStats get userStats {
    int totalWorkouts = 0;
    int totalDuration = 0;
    int totalCalories = 0;

    for (var p in _plans) {
      if (p.mode == PlanMode.oneTime) {
        if (p.completed) {
          totalWorkouts += 1;
          totalDuration += p.duration;
          totalCalories += p.calories;
        }
      } else {
        final count = p.completedDates?.length ?? 0;
        totalWorkouts += count;
        totalDuration += count * p.duration;
        totalCalories += count * p.calories;
      }
    }

    // 计算累计活跃天数（唯一日期数）
    final Set<String> activeDates = {};
    for (var p in _plans) {
      if (p.mode == PlanMode.oneTime) {
        if (p.completed) activeDates.add(p.date);
      } else {
        if (p.completedDates != null) activeDates.addAll(p.completedDates!);
      }
    }

    return UserStats(
      totalWorkouts: totalWorkouts,
      totalDuration: totalDuration,
      totalCalories: totalCalories,
      streakDays: _calculateStreakDays(),
      joinedDays: _hiveService.joinedDays,
      activeDays: activeDates.length,
      weeklyWorkoutCount: weeklyWorkoutCount,
      weeklyDurationHours: weeklyDurationHours,
      todayCalories: todayConsumedCalories,
    );
  }

  int _calculateStreakDays() {
    if (_plans.isEmpty) return 0;

    // Get all unique dates with completed workouts
    final Set<String> allCompletedDates = {};
    for (var p in _plans) {
      if (p.mode == PlanMode.oneTime) {
        if (p.completed) {
          allCompletedDates.add(p.date);
        }
      } else {
        if (p.completedDates != null) {
          allCompletedDates.addAll(p.completedDates!);
        }
      }
    }

    if (allCompletedDates.isEmpty) return 0;

    final sortedDates = allCompletedDates.toList();
    // Sort dates descending
    sortedDates.sort((a, b) => b.compareTo(a));

    // Check if today or yesterday has a completed workout
    final todayStr = DateTime.now().toString().split(' ')[0];
    final yesterdayStr = DateTime.now()
        .subtract(const Duration(days: 1))
        .toString()
        .split(' ')[0];

    if (!allCompletedDates.contains(todayStr) &&
        !allCompletedDates.contains(yesterdayStr)) {
      return 0; // Streak broken
    }

    // Calculate streak
    int streak = 0;
    DateTime checkDate = allCompletedDates.contains(todayStr)
        ? DateTime.now()
        : DateTime.now().subtract(const Duration(days: 1));

    while (true) {
      final dateStr = checkDate.toString().split(' ')[0];
      if (allCompletedDates.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
