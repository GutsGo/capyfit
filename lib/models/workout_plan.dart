import 'package:hive/hive.dart';

part 'workout_plan.g.dart';

@HiveType(typeId: 10)
enum WorkoutType {
  @HiveField(0)
  strength,
  @HiveField(1)
  cardio,
  @HiveField(2)
  yoga,
  @HiveField(3)
  other,
}

@HiveType(typeId: 11)
enum Intensity {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 12)
enum PlanMode {
  @HiveField(0)
  longTerm,
  @HiveField(2)
  oneTime,
}

@HiveType(typeId: 9)
class WorkoutPlan extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String date;
  @HiveField(3)
  final String time;
  @HiveField(4)
  final int duration;
  @HiveField(5)
  final int calories;
  @HiveField(6)
  final WorkoutType type;
  @HiveField(7)
  final Intensity intensity;
  @HiveField(8)
  final bool completed; // For oneTime plans
  @HiveField(9)
  final List<String>? exercises;
  @HiveField(10)
  final PlanMode mode;
  @HiveField(11)
  final List<String>? completedDates; // Track completed dates for longTerm plans

  WorkoutPlan({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.duration,
    required this.calories,
    required this.type,
    required this.intensity,
    required this.completed,
    this.exercises,
    this.mode = PlanMode.oneTime,
    this.completedDates,
  });

  /// Check if this plan is completed on a specific date
  bool isCompletedOn(String dateStr) {
    if (mode == PlanMode.oneTime) {
      return completed;
    } else {
      // For longTerm plans, check the completedDates list
      return completedDates?.contains(dateStr) ?? false;
    }
  }

  /// Toggle completion status for a specific date
  WorkoutPlan toggleCompletionFor(String dateStr) {
    if (mode == PlanMode.oneTime) {
      return copyWith(completed: !completed);
    } else {
      // For longTerm plans, add or remove the date from completedDates
      final dates = List<String>.from(completedDates ?? []);
      if (dates.contains(dateStr)) {
        dates.remove(dateStr);
      } else {
        dates.add(dateStr);
      }
      return copyWith(completedDates: dates);
    }
  }

  WorkoutPlan copyWith({
    String? id,
    String? name,
    String? date,
    String? time,
    int? duration,
    int? calories,
    WorkoutType? type,
    Intensity? intensity,
    bool? completed,
    List<String>? exercises,
    PlanMode? mode,
    List<String>? completedDates,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      completed: completed ?? this.completed,
      exercises: exercises ?? this.exercises,
      mode: mode ?? this.mode,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}
