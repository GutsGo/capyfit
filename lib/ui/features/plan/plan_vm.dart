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
      if (p.isDeleted == true) return false;

      if (p.mode == PlanMode.oneTime) {
        // 单次计划：如果是当天计划，或者虽然是过去但已完成的计划（历史课查）
        return p.date == dateStr ||
            (p.completed && p.date.compareTo(dateStr) < 0);
      } else {
        // 长期计划：selectedDate >= 创建日期 且 (未删除 或 selectedDate <= 结束日期)
        final isStarted = dateStr.compareTo(p.date) >= 0;
        final isNotEnded =
            p.endDate == null || dateStr.compareTo(p.endDate!) <= 0;
        return isStarted && isNotEnded;
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
