import 'package:flutter/foundation.dart';
import 'package:capyfit/data/repositories/user_repository.dart';
import 'package:capyfit/data/repositories/workout_repository.dart';
import 'package:capyfit/data/repositories/diet_repository.dart';
import 'package:capyfit/data/repositories/exercise_repository.dart';

abstract class BaseViewModel extends ChangeNotifier {
  final UserRepository userRepository = UserRepository();
  final WorkoutRepository workoutRepository = WorkoutRepository();
  final DietRepository dietRepository = DietRepository();
  final ExerciseRepository exerciseRepository = ExerciseRepository();

  BaseViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 统一的初始化方法，供 View 在 initState 中调用
  Future<void> init() async {}
}
