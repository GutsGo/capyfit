import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/data/services/hive_service.dart';

class WorkoutRepository {
  final HiveService _hiveService;

  WorkoutRepository({HiveService? hiveService})
    : _hiveService = hiveService ?? HiveService();

  List<WorkoutPlan> getWorkoutPlans() {
    return _hiveService.getWorkoutPlans();
  }

  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    await _hiveService.saveWorkoutPlan(plan);
  }

  Future<void> deleteWorkoutPlan(String id) async {
    await _hiveService.deleteWorkoutPlan(id);
  }
}
