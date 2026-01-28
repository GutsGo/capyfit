enum WorkoutType { strength, cardio, yoga, other }

enum Intensity { low, medium, high }

enum PlanMode { longTerm, timed, oneTime }

class WorkoutPlan {
  final String id;
  final String name;
  final String date;
  final String time;
  final int duration;
  final int calories;
  final WorkoutType type;
  final Intensity intensity;
  final bool completed;
  final List<String>? exercises;
  final PlanMode mode;

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
  });

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
    );
  }
}
