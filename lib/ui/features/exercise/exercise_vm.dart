import 'package:capyfit/ui/common/base_vm.dart';
import 'package:capyfit/data/models/exercise.dart';

class ExerciseViewModel extends BaseViewModel {
  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  final int _pageSize = 20;

  final List<String> _selectedCategories = [];
  List<String> get selectedCategories => _selectedCategories;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  @override
  Future<void> init() async {
    await loadExercises();
  }

  Future<void> loadExercises() async {
    setLoading(true);
    _hasMore = true;
    _exercises = await exerciseRepository.searchExercises(
      _searchQuery,
      categories: _selectedCategories,
      limit: _pageSize,
      offset: 0,
    );
    _hasMore = _exercises.length >= _pageSize;
    setLoading(false);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final more = await exerciseRepository.searchExercises(
      _searchQuery,
      categories: _selectedCategories,
      limit: _pageSize,
      offset: _exercises.length,
    );

    if (more.isEmpty) {
      _hasMore = false;
    } else {
      _exercises.addAll(more);
      _hasMore = more.length >= _pageSize;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadExercises();
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    loadExercises();
  }
}
