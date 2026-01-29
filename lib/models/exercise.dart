import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 4)
enum ExerciseCategory {
  @HiveField(0)
  chest,
  @HiveField(1)
  back,
  @HiveField(2)
  legs,
  @HiveField(3)
  shoulders,
  @HiveField(4)
  arms,
  @HiveField(5)
  core,
  @HiveField(6)
  cardio,
  @HiveField(7)
  yoga,
  @HiveField(8)
  other,
}

@HiveType(typeId: 5)
enum Difficulty {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
}

@HiveType(typeId: 3)
class Exercise extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final ExerciseCategory category;
  @HiveField(3)
  final Difficulty difficulty;
  @HiveField(4)
  final List<String> targetMuscles;
  @HiveField(5)
  final int? sets;
  @HiveField(6)
  final String? reps;
  @HiveField(7)
  final String? duration;
  @HiveField(8)
  final String? description;
  @HiveField(9)
  final List<String>? tips;
  @HiveField(10)
  final List<String>? steps;
  @HiveField(11)
  final int calories;
  @HiveField(12)
  final String? image;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.targetMuscles,
    required this.calories,
    this.sets,
    this.reps,
    this.duration,
    this.description,
    this.tips,
    this.steps,
    this.image,
  });
}
