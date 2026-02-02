import 'package:capyfit/ui/common/base_vm.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/data/models/user_profile.dart';

class HomeViewModel extends BaseViewModel {
  List<WorkoutPlan> _todayPlans = [];
  List<WorkoutPlan> get todayPlans => _todayPlans;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  @override
  Future<void> init() async {
    setLoading(true);
    _userProfile = userRepository.getUserProfile();
    _loadTodayPlans();
    setLoading(false);
  }

  void _loadTodayPlans() {
    final now = DateTime.now();
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    _todayPlans = workoutRepository.getWorkoutPlans().where((p) {
      if (p.mode == PlanMode.oneTime) {
        return p.date == dateStr;
      } else {
        return dateStr.compareTo(p.date) >= 0;
      }
    }).toList();
    notifyListeners();
  }

  int get completedSteps => _todayPlans
      .where(
        (p) => p.isCompletedOn(
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
        ),
      )
      .length;

  int get totalSteps => _todayPlans.length;

  double get progress => totalSteps > 0 ? completedSteps / totalSteps : 0.0;

  Future<void> togglePlanComplete(WorkoutPlan plan) async {
    final dateStr =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    plan.toggleComplete(dateStr);
    await workoutRepository.saveWorkoutPlan(plan);
    _loadTodayPlans();
  }
}
