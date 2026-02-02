import 'package:capyfit/ui/common/base_vm.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:intl/intl.dart';

class PlanViewModel extends BaseViewModel {
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  List<WorkoutPlan> _dayPlans = [];
  List<WorkoutPlan> get dayPlans => _dayPlans;

  @override
  Future<void> init() async {
    setLoading(true);
    _loadPlans();
    setLoading(false);
  }

  void _loadPlans() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _dayPlans = workoutRepository.getWorkoutPlans().where((p) {
      if (p.mode == PlanMode.oneTime) {
        return p.date == dateStr;
      } else {
        return dateStr.compareTo(p.date) >= 0;
      }
    }).toList();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _loadPlans();
  }

  int get completedCount => _dayPlans
      .where(
        (p) => p.isCompletedOn(DateFormat('yyyy-MM-dd').format(_selectedDate)),
      )
      .length;

  Future<void> addPlan(WorkoutPlan plan) async {
    await workoutRepository.saveWorkoutPlan(plan);
    _loadPlans();
  }

  Future<void> deletePlan(String id) async {
    await workoutRepository.deleteWorkoutPlan(id);
    _loadPlans();
  }

  Future<void> togglePlanComplete(WorkoutPlan plan) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    plan.toggleComplete(dateStr);
    await workoutRepository.saveWorkoutPlan(plan);
    _loadPlans();
  }
}
