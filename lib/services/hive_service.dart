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

    // Initialize default data if first launch
    if (_exercisesBox.isEmpty) {
      await _initDefaultExercises();
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
    final defaultExercises = [
      Exercise(
        id: '1',
        name: '俯卧撑',
        category: ExerciseCategory.chest,
        difficulty: Difficulty.intermediate,
        targetMuscles: ['胸大肌', '三角肌前束', '肱三头肌'],
        calories: 12,
        sets: 3,
        reps: '8-12次',
        description: '经典的上肢训练动作，主要锻炼胸部肌肉。',
        tips: ['保持身体呈一条直线', '手肘与身体呈45度角', '下落时胸部接近地面'],
        steps: ['双手略宽于肩支撑地面', '身体保持从头到脚呈直线', '屈肘下落至胸部接近地面', '发力推起回到起始位置'],
        image: 'assets/images/capy_pushup.webp',
      ),
      Exercise(
        id: '2',
        name: '深蹲',
        category: ExerciseCategory.legs,
        difficulty: Difficulty.beginner,
        targetMuscles: ['股四头肌', '臀大肌', '腘绳肌'],
        calories: 15,
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
        image: 'assets/images/capy_squat.webp',
      ),
      Exercise(
        id: '3',
        name: '平板支撑',
        category: ExerciseCategory.core,
        difficulty: Difficulty.intermediate,
        targetMuscles: ['腹直肌', '腹横肌', '核心肌群'],
        calories: 5,
        sets: 3,
        reps: '30-60秒',
        description: '静态核心训练动作，增强核心稳定性。',
        tips: ['身体保持直线', '收紧核心', '不要塌腰 or 翘臀'],
        steps: [
          '双肘支撑在肩部正下方',
          '双脚靠拢，脚尖点地',
          '收紧核心，身体呈一条直线',
          '保持匀速呼吸，不要憋气',
          '在规定时间内保持稳定',
        ],
        image: 'assets/images/capy_plank.webp',
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
        image: 'assets/images/capy_dumbbell_curl.webp',
      ),
      Exercise(
        id: '5',
        name: '快乐慢跑',
        category: ExerciseCategory.cardio,
        difficulty: Difficulty.beginner,
        targetMuscles: ['全身', '心肺功能'],
        calories: 100,
        sets: 1,
        reps: '30分钟',
        description: '提升心肺功能，燃烧脂肪的有效运动。',
        tips: ['保持呼吸节奏', '落地轻盈', '注意摆臂'],
        image: 'assets/images/capy_running.webp',
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
        image: 'assets/images/capy_yoga.webp',
      ),
    ];

    for (final exercise in defaultExercises) {
      await _exercisesBox.put(exercise.id, exercise);
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
