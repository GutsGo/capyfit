import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/data/models/diet_entry.dart';
import 'package:capyfit/data/models/daily_step_entry.dart';
import 'package:capyfit/data/repositories/workout_repository.dart';
import 'package:capyfit/data/repositories/diet_repository.dart';
import 'package:capyfit/data/services/hive_service.dart';

class StatsViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final DietRepository _dietRepository;
  final HiveService _hiveService;

  StatsViewModel({
    WorkoutRepository? workoutRepository,
    DietRepository? dietRepository,
    HiveService? hiveService,
  }) : _workoutRepository = workoutRepository ?? WorkoutRepository(),
       _dietRepository = dietRepository ?? DietRepository(),
       _hiveService = hiveService ?? HiveService();

  int _selectedDays = 7;
  int get selectedDays => _selectedDays;

  List<WorkoutPlan> _allPlans = [];
  List<DietEntry> _allDietEntries = [];
  List<DailyStepEntry> _allSteps = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _allPlans = _workoutRepository.getWorkoutPlans();
    _allDietEntries = _dietRepository.getDietEntries();
    _allSteps = _hiveService.getDailySteps();

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedDays(int days) {
    _selectedDays = days;
    notifyListeners();
  }

  // --- 运动统计 ---

  /// 获取过去 X 天的运动趋势（每天时长）
  Map<String, double> getDurationTrend() {
    final result = <String, double>{};
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (int i = _selectedDays - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = dateFormat.format(date);
      double totalDuration = 0;

      for (final plan in _allPlans) {
        if (plan.isCompletedOn(dateStr)) {
          totalDuration += plan.duration;
        }
      }
      result[DateFormat('MM/dd').format(date)] = totalDuration;
    }
    return result;
  }

  /// 获取过去 X 天的热量消耗趋势
  Map<String, double> getCaloriesBurnTrend() {
    final result = <String, double>{};
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (int i = _selectedDays - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = dateFormat.format(date);
      double totalCalories = 0;

      for (final plan in _allPlans) {
        if (plan.isCompletedOn(dateStr)) {
          totalCalories += plan.calories;
        }
      }
      result[DateFormat('MM/dd').format(date)] = totalCalories;
    }
    return result;
  }

  // --- 饮食统计 ---

  /// 获取过去 X 天的摄入热量与目标热量（如果有目标）对比
  Map<String, double> getDietCaloriesTrend() {
    final result = <String, double>{};
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (int i = _selectedDays - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = dateFormat.format(date);
      double dayCalories = 0;

      for (final entry in _allDietEntries) {
        if (entry.date == dateStr) {
          dayCalories += entry.calories;
        }
      }
      result[DateFormat('MM/dd').format(date)] = dayCalories;
    }
    return result;
  }

  /// 获取指定期间的三大营养素比例
  List<double> getMacroNutrientStats() {
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: _selectedDays));

    for (final entry in _allDietEntries) {
      final entryDate = DateTime.tryParse(entry.date);
      if (entryDate != null && entryDate.isAfter(cutoff)) {
        totalProtein += entry.protein;
        totalCarbs += entry.carbs;
        totalFat += entry.fat;
      }
    }

    final sum = totalProtein + totalCarbs + totalFat;
    if (sum == 0) return [0, 0, 0];
    return [totalProtein, totalCarbs, totalFat];
  }

  // --- 步数统计 ---

  /// 获取过去 X 天的步数趋势
  Map<String, double> getStepsTrend() {
    final result = <String, double>{};
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (int i = _selectedDays - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = dateFormat.format(date);

      final entry = _allSteps.firstWhere(
        (e) => e.date == dateStr,
        orElse: () => DailyStepEntry(date: dateStr, steps: 0),
      );

      result[DateFormat('MM/dd').format(date)] = entry.steps.toDouble();
    }
    return result;
  }

  // --- 综合分析 ---

  double get totalDurationInSelectedPeriod {
    double total = 0;
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (int i = _selectedDays - 1; i >= 0; i--) {
      final dateStr = dateFormat.format(now.subtract(Duration(days: i)));
      for (final plan in _allPlans) {
        if (plan.isCompletedOn(dateStr)) {
          total += plan.duration;
        }
      }
    }
    return total;
  }

  double get totalCaloriesBurnInSelectedPeriod {
    double total = 0;
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (int i = _selectedDays - 1; i >= 0; i--) {
      final dateStr = dateFormat.format(now.subtract(Duration(days: i)));
      for (final plan in _allPlans) {
        if (plan.isCompletedOn(dateStr)) {
          total += plan.calories;
        }
      }
    }
    return total;
  }
}
