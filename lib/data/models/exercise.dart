import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 4)
enum ExerciseCategory {
  @HiveField(0)
  core,
  @HiveField(1)
  upperBody,
  @HiveField(2)
  lowerBody,
  @HiveField(3)
  fullBody,
  @HiveField(4)
  cardio,
  @HiveField(5)
  bodySculpting,
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
  @HiveField(12)
  final String? image;
  @HiveField(13)
  final double met;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.targetMuscles,
    required this.met,
    this.sets,
    this.reps,
    this.duration,
    this.description,
    this.tips,
    this.steps,
    this.image,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'difficulty': difficulty.index,
      'targetMuscles': targetMuscles,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'description': description,
      'tips': tips,
      'steps': steps,
      'image': image,
      'met': met,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ExerciseCategory.values[json['category'] as int],
      difficulty: Difficulty.values[json['difficulty'] as int],
      targetMuscles: List<String>.from(json['targetMuscles'] as List),
      met: (json['met'] as num).toDouble(),
      sets: json['sets'] as int?,
      reps: json['reps'] as String?,
      duration: json['duration'] as String?,
      description: json['description'] as String?,
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList(),
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      image: json['image'] as String?,
    );
  }
}
