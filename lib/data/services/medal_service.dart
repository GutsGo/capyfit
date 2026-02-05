import 'package:capyfit/data/models/medal.dart';
import 'package:capyfit/data/models/diet_entry.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/data/models/user_profile.dart';
import 'package:capyfit/data/models/daily_step_entry.dart';

class MedalService {
  static final List<Medal> allMedals = [
    Medal(
      id: 'morning_immortal',
      name: '早起仙人',
      description: '累计3天在8:00前进行打卡或记录',
      emoji: '💊',
      image: 'assets/images/medals/morning_immortal.webp',
      level: MedalLevel.iron,
    ),
    Medal(
      id: 'calorie_nomad',
      name: '低卡行者',
      description: '单日摄入热量不超标且有运动记录',
      emoji: '🏺',
      image: 'assets/images/medals/calorie_nomad.webp',
      level: MedalLevel.iron,
    ),
    Medal(
      id: 'walker_master',
      name: '百步真君',
      description: '累计步数达到10万步',
      emoji: '☁️',
      image: 'assets/images/medals/walker_master.webp',
      level: MedalLevel.silver,
    ),
    Medal(
      id: 'stamina_pagoda',
      name: '毅力宝塔',
      description: '累计完成50个训练计划',
      emoji: '⛩️',
      image: 'assets/images/medals/stamina_pagoda.webp',
      level: MedalLevel.gold,
    ),
    Medal(
      id: 'food_expert',
      name: '美食专家',
      description: '累计记录饮食项超过50条',
      emoji: '🥗',
      image: 'assets/images/medals/food_expert.webp',
      level: MedalLevel.iron,
    ),
    Medal(
      id: 'step_sprint',
      name: '神行太保',
      description: '单日步数突破20000步',
      emoji: '⚡',
      image: 'assets/images/medals/step_sprint.webp',
      level: MedalLevel.silver,
    ),
    Medal(
      id: 'hard_work',
      name: '苦修者',
      description: '累计运动时长达到1000分钟',
      emoji: '⏳',
      image: 'assets/images/medals/hard_work.webp',
      level: MedalLevel.gold,
    ),
    Medal(
      id: 'herb_taster',
      name: '尝遍百草',
      description: '累计记录过15种不同的食物',
      emoji: '🎋',
      image: 'assets/images/medals/herb_taster.webp',
      level: MedalLevel.iron,
    ),
    Medal(
      id: 'active_streak',
      name: '初窥天道',
      description: '连续活跃打卡达到7天',
      emoji: '📅',
      image: 'assets/images/medals/active_streak.webp',
      level: MedalLevel.silver,
    ),
    Medal(
      id: 'variety_master',
      name: '文武双全',
      description: '累计完成过3种不同类型的训练',
      emoji: '☯️',
      image: 'assets/images/medals/variety_master.webp',
      level: MedalLevel.silver,
    ),
  ];

  static List<Medal> checkNewMedals({
    required List<DietEntry> dietEntries,
    required List<WorkoutPlan> plans,
    required List<DailyStepEntry> stepEntries,
    required UserProfile profile,
    required List<String> earnedMedalIds,
    required int calorieGoal,
  }) {
    List<Medal> newlyEarned = [];

    for (var medal in allMedals) {
      if (earnedMedalIds.contains(medal.id)) continue;

      bool earned = false;
      switch (medal.id) {
        case 'morning_immortal':
          earned = _checkMorningImmortal(dietEntries, plans);
          break;
        case 'calorie_nomad':
          earned = _checkCalorieNomad(dietEntries, plans, calorieGoal);
          break;
        case 'walker_master':
          earned = _checkWalkerMaster(stepEntries);
          break;
        case 'stamina_pagoda':
          earned = _checkStaminaPagoda(plans);
          break;
        case 'food_expert':
          earned = dietEntries.length >= 50;
          break;
        case 'step_sprint':
          earned = stepEntries.any((e) => e.steps >= 20000);
          break;
        case 'hard_work':
          earned = _checkWorkoutDuration(plans);
          break;
        case 'herb_taster':
          earned = dietEntries.map((e) => e.name).toSet().length >= 15;
          break;
        case 'active_streak':
          earned = _checkActiveStreak(stepEntries);
          break;
        case 'variety_master':
          earned = _checkVarietyMaster(plans);
          break;
      }

      if (earned) {
        newlyEarned.add(medal.copyWith(earnedDate: DateTime.now()));
      }
    }

    return newlyEarned;
  }

  static bool _checkMorningImmortal(
    List<DietEntry> diets,
    List<WorkoutPlan> plans,
  ) {
    Set<String> earlyDates = {};
    for (var d in diets) {
      final hour = int.tryParse(d.time.split(':')[0]) ?? 24;
      if (hour < 8) earlyDates.add(d.date);
    }
    for (var p in plans) {
      final hour = int.tryParse(p.time.split(':')[0]) ?? 24;
      if (hour < 8) {
        if (p.mode == PlanMode.oneTime && p.completed) {
          earlyDates.add(p.date);
        }
        // LongTerm plans don't have a specific persistent 'completion time' for each date in the same way
        // without more complex data, so we mainly check diets and oneTime plans.
      }
    }
    return earlyDates.length >= 3;
  }

  static bool _checkCalorieNomad(
    List<DietEntry> diets,
    List<WorkoutPlan> plans,
    int goal,
  ) {
    Map<String, int> dailyCals = {};
    for (var d in diets) {
      dailyCals[d.date] = (dailyCals[d.date] ?? 0) + d.calories;
    }

    for (var date in dailyCals.keys) {
      if (dailyCals[date]! <= goal && dailyCals[date]! > 0) {
        // Check if there was any workout on that date
        bool hadWorkout = plans.any((p) => p.isCompletedOn(date));
        if (hadWorkout) return true;
      }
    }
    return false;
  }

  static bool _checkWalkerMaster(List<DailyStepEntry> steps) {
    int total = steps.fold(0, (sum, e) => sum + e.steps);
    return total >= 100000;
  }

  static bool _checkStaminaPagoda(List<WorkoutPlan> plans) {
    int count = 0;
    for (var p in plans) {
      if (p.mode == PlanMode.oneTime) {
        if (p.completed) count++;
      } else {
        count += p.completedDates?.length ?? 0;
      }
    }
    return count >= 50;
  }

  static bool _checkWorkoutDuration(List<WorkoutPlan> plans) {
    int totalMinutes = 0;
    for (var p in plans) {
      if (p.mode == PlanMode.oneTime) {
        if (p.completed) totalMinutes += p.duration;
      } else {
        totalMinutes += (p.completedDates?.length ?? 0) * p.duration;
      }
    }
    return totalMinutes >= 1000;
  }

  static bool _checkActiveStreak(List<DailyStepEntry> steps) {
    if (steps.isEmpty) return false;
    final dates = steps.map((e) => e.date).toSet().toList()..sort();
    if (dates.length < 7) return false;

    int currentStreak = 1;
    int maxStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final prev = DateTime.parse(dates[i - 1]);
      final curr = DateTime.parse(dates[i]);
      if (curr.difference(prev).inDays == 1) {
        currentStreak++;
      } else if (curr.difference(prev).inDays > 1) {
        currentStreak = 1;
      }
      if (currentStreak > maxStreak) maxStreak = currentStreak;
    }
    return maxStreak >= 7;
  }

  static bool _checkVarietyMaster(List<WorkoutPlan> plans) {
    Set<WorkoutType> types = {};
    for (var p in plans) {
      bool isCompleted = false;
      if (p.mode == PlanMode.oneTime) {
        isCompleted = p.completed;
      } else {
        isCompleted = (p.completedDates?.isNotEmpty ?? false);
      }

      if (isCompleted) {
        types.add(p.type);
      }
    }
    return types.length >= 3;
  }
}
