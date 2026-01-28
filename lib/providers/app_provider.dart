import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import '../models/diet_entry.dart';
import '../models/exercise.dart';
import '../models/food_item.dart';

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
      calories: 320,
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
      calories: 250,
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

  final List<FoodItem> _foodPresets = [
    FoodItem(
      id: 'f1',
      name: '鸡蛋',
      caloriesPer100g: 143,
      proteinPer100g: 13,
      carbsPer100g: 1.1,
      fatPer100g: 9.5,
    ),
    FoodItem(
      id: 'f2',
      name: '鸡胸肉',
      caloriesPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
    ),
    FoodItem(
      id: 'f3',
      name: '燕麦',
      caloriesPer100g: 389,
      proteinPer100g: 16.9,
      carbsPer100g: 66,
      fatPer100g: 6.9,
    ),
    FoodItem(
      id: 'f4',
      name: '三文鱼',
      caloriesPer100g: 208,
      proteinPer100g: 20,
      carbsPer100g: 0,
      fatPer100g: 13,
    ),
    FoodItem(
      id: 'f5',
      name: '米饭',
      caloriesPer100g: 130,
      proteinPer100g: 2.7,
      carbsPer100g: 28,
      fatPer100g: 0.3,
    ),
  ];

  final List<Exercise> _exercises = [
    Exercise(
      id: '1',
      name: '俯卧撑',
      category: ExerciseCategory.chest,
      difficulty: Difficulty.intermediate,
      targetMuscles: ['胸大肌', '三角肌前束', '肱三头肌'],
      calories: 12, // per set
      sets: 3,
      reps: '8-12次',
      description: '经典的上肢训练动作，主要锻炼胸部肌肉。',
      tips: ['保持身体呈一条直线', '手肘与身体呈45度角', '下落时胸部接近地面'],
      steps: ['双手略宽于肩支撑地面', '身体保持从头到脚呈直线', '屈肘下落至胸部接近地面', '发力推起回到起始位置'],
      image: 'assets/images/capy_pushup.png',
    ),
    Exercise(
      id: '2',
      name: '深蹲',
      category: ExerciseCategory.legs,
      difficulty: Difficulty.beginner,
      targetMuscles: ['股四头肌', '臀大肌', '腘绳肌'],
      calories: 15, // per set
      sets: 3,
      reps: '12-15次',
      description: '下肢训练之王，全面锻炼腿部肌肉。',
      tips: ['膝盖不要超过脚尖', '背部保持挺直', '下蹲至大腿与地面平行'],
      steps: [
        '双脚与肩同宽站立',
        '挺胸收腹，背部挺直',
        '臀部后坐，像坐椅子一样下蹲',
        '蹲至大腿与地面平行或略低',
        '脚跟发力站起完成动作',
      ],
      image: 'assets/images/capy_squat.png',
    ),
    Exercise(
      id: '3',
      name: '平板支撑',
      category: ExerciseCategory.core,
      difficulty: Difficulty.intermediate,
      targetMuscles: ['腹直肌', '腹横肌', '核心肌群'],
      calories:
          5, // per minute (approx, logic handles per set usually but here just unit)
      sets: 3,
      reps: '30-60秒',
      description: '静态核心训练动作，增强核心稳定性。',
      tips: ['身体保持直线', '收紧核心', '不要塌腰或翘臀'],
      steps: [
        '双肘支撑在肩部正下方',
        '双脚靠拢，脚尖点地',
        '收紧核心，身体呈一条直线',
        '保持匀速呼吸，不要憋气',
        '在规定时间内保持稳定',
      ],
      image: 'assets/images/capy_plank.png',
    ),
    Exercise(
      id: '4',
      name: '二头弯举',
      category: ExerciseCategory.arms,
      difficulty: Difficulty.beginner,
      targetMuscles: ['肱二头肌'],
      calories: 8,
      sets: 3,
      reps: '12-15次',
      description: '孤立训练肱二头肌的经典动作。',
      tips: ['保持大臂紧贴身体', '控制下放速度', '不要借力身体摆动'],
      image: 'assets/images/capy_dumbbell_curl.png',
    ),
    Exercise(
      id: '5',
      name: '快乐慢跑',
      category: ExerciseCategory.cardio,
      difficulty: Difficulty.beginner,
      targetMuscles: ['全身', '心肺功能'],
      calories:
          100, // per 10 mins unit maybe? Let's just say a higher base unit or adjust logic.
      // Actually standard logic is per set, so let's treat "1 set" as like 10 mins jog for logic simplicity or just a unit value.
      sets: 1,
      reps: '30分钟',
      description: '提升心肺功能，燃烧脂肪的有效运动。',
      tips: ['保持呼吸节奏', '落地轻盈', '注意摆臂'],
      image: 'assets/images/capy_running.png',
    ),
    Exercise(
      id: '6',
      name: '舒缓瑜伽',
      category: ExerciseCategory.yoga,
      difficulty: Difficulty.beginner,
      targetMuscles: ['全身', '柔韧性'],
      calories: 50,
      sets: 1,
      reps: '20分钟',
      description: '放松身心，提高身体柔韧性。',
      tips: ['配合呼吸', '切勿过度拉伸', '专注于身体感受'],
      image: 'assets/images/capy_yoga.png',
    ),
  ];

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  int calorieGoal = 2000;

  List<WorkoutPlan> get plans => _plans;
  List<DietEntry> get dietEntries => _dietEntries;
  List<Exercise> get exercises => _exercises;
  List<FoodItem> get foodPresets => _foodPresets;

  void addFoodPreset(FoodItem item) {
    _foodPresets.add(item);
    notifyListeners();
  }

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

  int get todayConsumedCalories {
    final today = DateTime.now().toString().split(' ')[0];
    return _plans
        .where((p) => p.date == today && p.completed)
        .fold(0, (sum, p) => sum + p.calories);
  }

  double get todayProtein =>
      _dietEntries.fold(0.0, (sum, e) => sum + e.protein);
  double get todayCarbs => _dietEntries.fold(0.0, (sum, e) => sum + e.carbs);
  double get todayFat => _dietEntries.fold(0.0, (sum, e) => sum + e.fat);

  UserStats get userStats => UserStats(
    totalWorkouts: _plans.where((p) => p.completed).length,
    totalDuration: _plans
        .where((p) => p.completed)
        .fold(0, (sum, p) => sum + p.duration),
    totalCalories: _plans
        .where((p) => p.completed)
        .fold(0, (sum, p) => sum + p.calories),
    streakDays: 5,
    joinedDays: 32,
  );
}
