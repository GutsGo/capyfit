import 'package:capyfit/ui/common/base_vm.dart';
import 'package:capyfit/data/models/diet_entry.dart';
import 'package:intl/intl.dart';

class DietViewModel extends BaseViewModel {
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  List<DietEntry> _entries = [];
  List<DietEntry> get entries => _entries;

  @override
  Future<void> init() async {
    setLoading(true);
    _loadEntries();
    setLoading(false);
  }

  void _loadEntries() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _entries = dietRepository
        .getDietEntries()
        .where((e) => e.date == dateStr)
        .toList();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _loadEntries();
  }

  double get totalCalories =>
      _entries.fold(0, (sum, e) => sum + e.totalCalories);
  double get totalProtein => _entries.fold(0, (sum, e) => sum + e.totalProtein);
  double get totalCarbs => _entries.fold(0, (sum, e) => sum + e.totalCarbs);
  double get totalFat => _entries.fold(0, (sum, e) => sum + e.totalFat);

  List<DietEntry> getEntriesForMeal(MealType type) {
    return _entries.where((e) => e.mealType == type).toList();
  }

  Future<void> addDietEntry(DietEntry entry) async {
    await dietRepository.saveDietEntry(entry);
    _loadEntries();
  }

  Future<void> deleteDietEntry(String id) async {
    await dietRepository.deleteDietEntry(id);
    _loadEntries();
  }
}
