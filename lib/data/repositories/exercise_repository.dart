import 'package:capyfit/data/models/exercise.dart';
import 'package:capyfit/data/services/hive_service.dart';
import 'package:capyfit/data/services/exercise_db_service.dart';

class ExerciseRepository {
  final HiveService _hiveService;
  final ExerciseDbService _exerciseDbService;

  ExerciseRepository({
    HiveService? hiveService,
    ExerciseDbService? exerciseDbService,
  }) : _hiveService = hiveService ?? HiveService(),
       _exerciseDbService = exerciseDbService ?? ExerciseDbService();

  // User's customized exercises or recent ones from Hive
  List<Exercise> getFavoriteExercises() {
    return _hiveService.getExercises();
  }

  Future<void> saveFavoriteExercise(Exercise exercise) async {
    await _hiveService.saveExercise(exercise);
  }

  // Exercise Database (Read-only JSON)
  Future<List<Exercise>> searchExercises(
    String query, {
    List<String>? categories,
    int limit = 20,
    int offset = 0,
  }) {
    return _exerciseDbService.search(
      query,
      categories: categories,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Exercise>> getAllExercises() {
    return _exerciseDbService.getAllExercises();
  }
}
