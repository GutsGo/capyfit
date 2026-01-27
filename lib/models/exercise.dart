enum ExerciseCategory { chest, back, legs, shoulders, arms, core, cardio }
enum Difficulty { beginner, intermediate, advanced }

class Exercise {
  final String id;
  final String name;
  final ExerciseCategory category;
  final Difficulty difficulty;
  final List<String> targetMuscles;
  final int? sets;
  final String? reps;
  final String? duration;
  final String? description;
  final List<String>? tips;
  final String? image;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.targetMuscles,
    this.sets,
    this.reps,
    this.duration,
    this.description,
    this.tips,
    this.image,
  });
}
