import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:capyfit/data/models/user_profile.dart';
import 'package:capyfit/data/models/exercise.dart';
import 'package:capyfit/data/models/food_item.dart';
import 'package:capyfit/data/models/diet_entry.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/data/models/daily_step_entry.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String userProfileBoxName = 'userProfile';
  static const String exercisesBoxName = 'exercises';
  static const String foodItemsBoxName = 'foodItems';
  static const String dietEntriesBoxName = 'dietEntries';
  static const String workoutPlansBoxName = 'workoutPlans';
  static const String dailyStepsBoxName = 'dailySteps';
  static const String settingsBoxName = 'settings';

  late Box<UserProfile> _userProfileBox;
  late Box<Exercise> _exercisesBox;
  late Box<FoodItem> _foodItemsBox;
  late Box<DietEntry> _dietEntriesBox;
  late Box<WorkoutPlan> _workoutPlansBox;
  late Box<DailyStepEntry> _dailyStepsBox;
  late Box _settingsBox;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await Hive.initFlutter();

    // Register all adapters
    _registerAdapters();

    // 阶段 1: 仅打开启动必需的盒子 (用户资料和系统设置)
    final results = await Future.wait([
      Hive.openBox<UserProfile>(userProfileBoxName),
      Hive.openBox(settingsBoxName),
      Hive.openBox<WorkoutPlan>(workoutPlansBoxName), // 首页需要显示计划
      Hive.openBox<DailyStepEntry>(dailyStepsBoxName), // 首页需要步数
      Hive.openBox<DietEntry>(dietEntriesBoxName), // 首页需要热量
    ]);

    _userProfileBox = results[0] as Box<UserProfile>;
    _settingsBox = results[1] as Box;
    _workoutPlansBox = results[2] as Box<WorkoutPlan>;
    _dailyStepsBox = results[3] as Box<DailyStepEntry>;
    _dietEntriesBox = results[4] as Box<DietEntry>;

    _isInitialized = true;

    // 阶段 2: 后台异步打开其余大型数据库盒子，不阻塞启动
    _initRemainingBoxes();
  }

  void _registerAdapters() {
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
    Hive.registerAdapter(DailyStepEntryAdapter());
  }

  Future<void> _initRemainingBoxes() async {
    final results = await Future.wait([
      Hive.openBox<Exercise>(exercisesBoxName),
      Hive.openBox<FoodItem>(foodItemsBoxName),
    ]);
    _exercisesBox = results[0] as Box<Exercise>;
    _foodItemsBox = results[1] as Box<FoodItem>;
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

  // ========== Backup Stats ==========
  DateTime? get lastBackupTime {
    final timestamp = _settingsBox.get('lastBackupTime');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  Future<void> saveLastBackupTime(DateTime date) async {
    await _settingsBox.put('lastBackupTime', date.millisecondsSinceEpoch);
  }

  // ========== Medals ==========
  List<String> getEarnedMedalJsonList() {
    return _settingsBox.get('earnedMedals', defaultValue: <String>[]);
  }

  Future<void> saveEarnedMedalJsonList(List<String> medalJsons) async {
    await _settingsBox.put('earnedMedals', medalJsons);
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

  // ========== Daily Steps ==========
  List<DailyStepEntry> getDailySteps() {
    return _dailyStepsBox.values.toList();
  }

  Future<void> saveDailySteps(DailyStepEntry entry) async {
    // Key by date to ensure one entry per day
    await _dailyStepsBox.put(entry.date, entry);
  }

  // ========== Debug Tools ==========
  /// 清空所有数据，仅用于开发环境
  Future<void> debugClearAllBoxes() async {
    if (kDebugMode) {
      await _userProfileBox.clear();
      await _exercisesBox.clear();
      await _foodItemsBox.clear();
      await _dietEntriesBox.clear();
      await _workoutPlansBox.clear();
      await _dailyStepsBox.clear();
      await _settingsBox.clear();
      print('DEBUG: All Hive boxes cleared.');
    }
  }
}
