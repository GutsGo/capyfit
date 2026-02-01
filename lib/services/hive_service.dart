import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/exercise.dart';
import '../models/food_item.dart';
import '../models/diet_entry.dart';
import '../models/workout_plan.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String userProfileBoxName = 'userProfile';
  static const String exercisesBoxName = 'exercises';
  static const String foodItemsBoxName = 'foodItems';
  static const String dietEntriesBoxName = 'dietEntries';
  static const String workoutPlansBoxName = 'workoutPlans';
  static const String settingsBoxName = 'settings';

  late Box<UserProfile> _userProfileBox;
  late Box<Exercise> _exercisesBox;
  late Box<FoodItem> _foodItemsBox;
  late Box<DietEntry> _dietEntriesBox;
  late Box<WorkoutPlan> _workoutPlansBox;
  late Box _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(UserGoalAdapter());
    Hive.registerAdapter(GenderAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(ExerciseCategoryAdapter());
    Hive.registerAdapter(DifficultyAdapter());
    Hive.registerAdapter(FoodItemAdapter());
    Hive.registerAdapter(DietEntryAdapter());
    Hive.registerAdapter(MealTypeAdapter());
    Hive.registerAdapter(WorkoutPlanAdapter());
    Hive.registerAdapter(WorkoutTypeAdapter());
    Hive.registerAdapter(IntensityAdapter());
    Hive.registerAdapter(PlanModeAdapter());

    // Open boxes
    _userProfileBox = await Hive.openBox<UserProfile>(userProfileBoxName);
    _exercisesBox = await Hive.openBox<Exercise>(exercisesBoxName);
    _foodItemsBox = await Hive.openBox<FoodItem>(foodItemsBoxName);
    _dietEntriesBox = await Hive.openBox<DietEntry>(dietEntriesBoxName);
    _workoutPlansBox = await Hive.openBox<WorkoutPlan>(workoutPlansBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);

    // Initialize default data if first launch or version upgrade
    final bool hasLoadedJson = _settingsBox.get(
      'has_loaded_exercise_json_v3',
      defaultValue: false,
    );
    if (!hasLoadedJson || _exercisesBox.isEmpty) {
      await _exercisesBox.clear();
      await _initDefaultExercises();
      await _settingsBox.put('has_loaded_exercise_json_v3', true);
    }

    if (_foodItemsBox.isEmpty) {
      await _initDefaultFoodItems();
    }
  }

  // ========== User Profile ==========
  bool get hasUserProfile => _userProfileBox.isNotEmpty;

  UserProfile? getUserProfile() {
    return _userProfileBox.get('current');
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _userProfileBox.put('current', profile);
  }

  // ========== Settings ==========
  String get themeMode => _settingsBox.get('themeMode', defaultValue: 'system');

  Future<void> saveThemeMode(String mode) async {
    await _settingsBox.put('themeMode', mode);
  }

  // ========== User Stats ==========
  DateTime? get joinedDate {
    final timestamp = _settingsBox.get('joinedDate');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  Future<void> saveJoinedDate(DateTime date) async {
    await _settingsBox.put('joinedDate', date.millisecondsSinceEpoch);
  }

  int get joinedDays {
    final joined = joinedDate;
    if (joined == null) return 0;
    return DateTime.now().difference(joined).inDays + 1; // +1 to include today
  }

  // ========== Exercises ==========
  List<Exercise> getExercises() {
    return _exercisesBox.values.toList();
  }

  Future<void> saveExercise(Exercise exercise) async {
    await _exercisesBox.put(exercise.id, exercise);
  }

  Future<void> deleteExercise(String id) async {
    await _exercisesBox.delete(id);
  }

  // ========== Food Items ==========
  List<FoodItem> getFoodItems() {
    return _foodItemsBox.values.toList();
  }

  Future<void> saveFoodItem(FoodItem item) async {
    await _foodItemsBox.put(item.id, item);
  }

  Future<void> deleteFoodItem(String id) async {
    await _foodItemsBox.delete(id);
  }

  // ========== Diet Entries ==========
  List<DietEntry> getDietEntries() {
    return _dietEntriesBox.values.toList();
  }

  Future<void> saveDietEntry(DietEntry entry) async {
    await _dietEntriesBox.put(entry.id, entry);
  }

  Future<void> deleteDietEntry(String id) async {
    await _dietEntriesBox.delete(id);
  }

  // ========== Workout Plans ==========
  List<WorkoutPlan> getWorkoutPlans() {
    return _workoutPlansBox.values.toList();
  }

  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    await _workoutPlansBox.put(plan.id, plan);
  }

  Future<void> deleteWorkoutPlan(String id) async {
    await _workoutPlansBox.delete(id);
  }

  // ========== Default Data Initialization ==========
  Future<void> _initDefaultExercises() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/exercise_db.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      final List<Exercise> defaultExercises = jsonData.map((data) {
        final String categoryStr = data['category'] ?? '其他';

        // Map Chinese category to ExerciseCategory enum
        ExerciseCategory category;
        switch (categoryStr) {
          case '胸部':
            category = ExerciseCategory.chest;
            break;
          case '背部':
            category = ExerciseCategory.back;
            break;
          case '腿部':
            category = ExerciseCategory.legs;
            break;
          case '肩部':
            category = ExerciseCategory.shoulders;
            break;
          case '手臂':
            category = ExerciseCategory.arms;
            break;
          case '核心':
            category = ExerciseCategory.core;
            break;
          case '有氧':
            category = ExerciseCategory.cardio;
            break;
          case '瑜伽':
            category = ExerciseCategory.yoga;
            break;
          default:
            category = ExerciseCategory.other;
        }

        // Map difficulty
        Difficulty difficulty;
        int diffLevel = data['difficulty'] ?? 1;
        if (diffLevel <= 1) {
          difficulty = Difficulty.beginner;
        } else if (diffLevel == 2) {
          difficulty = Difficulty.intermediate;
        } else {
          difficulty = Difficulty.advanced;
        }

        return Exercise(
          id: data['id'].toString(),
          name: data['name'] ?? '未知动作',
          category: category,
          difficulty: difficulty,
          targetMuscles: List<String>.from(data['targetMuscles'] ?? []),
          met: (data['met'] ?? 5.0).toDouble(),
          sets: data['sets'] ?? 3,
          reps: data['reps'],
          description: data['description'],
          tips: List<String>.from(data['tips'] ?? []),
          steps: List<String>.from(data['steps'] ?? []),
          image: 'assets/images/${data['image']}',
        );
      }).toList();

      for (final exercise in defaultExercises) {
        await _exercisesBox.put(exercise.id, exercise);
      }
    } catch (e) {
      print('Error loading default exercises: $e');
    }
  }

  Future<void> _initDefaultFoodItems() async {
    final defaultFoodItems = [
      FoodItem(
        id: 'f1',
        name: '鸡蛋',
        caloriesPer100g: 143,
        proteinPer100g: 13,
        carbsPer100g: 1.1,
        fatPer100g: 9.5,
        emoji: '🥚',
      ),
      FoodItem(
        id: 'f2',
        name: '鸡胸肉',
        caloriesPer100g: 165,
        proteinPer100g: 31,
        carbsPer100g: 0,
        fatPer100g: 3.6,
        emoji: '🍗',
      ),
      FoodItem(
        id: 'f3',
        name: '燕麦',
        caloriesPer100g: 389,
        proteinPer100g: 16.9,
        carbsPer100g: 66,
        fatPer100g: 6.9,
        emoji: '🥣',
      ),
      FoodItem(
        id: 'f4',
        name: '三文鱼',
        caloriesPer100g: 208,
        proteinPer100g: 20,
        carbsPer100g: 0,
        fatPer100g: 13,
        emoji: '🐟',
      ),
      FoodItem(
        id: 'f5',
        name: '米饭',
        caloriesPer100g: 130,
        proteinPer100g: 2.7,
        carbsPer100g: 28,
        fatPer100g: 0.3,
        emoji: '🍚',
      ),
    ];

    for (final item in defaultFoodItems) {
      await _foodItemsBox.put(item.id, item);
    }
  }
}
