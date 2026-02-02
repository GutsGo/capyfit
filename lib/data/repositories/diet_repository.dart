import 'package:capyfit/data/models/diet_entry.dart';
import 'package:capyfit/data/models/food_database.dart';
import 'package:capyfit/data/models/food_item.dart';
import 'package:capyfit/data/services/hive_service.dart';
import 'package:capyfit/data/services/food_db_service.dart';

class DietRepository {
  final HiveService _hiveService;
  final FoodDbService _foodDbService;

  DietRepository({HiveService? hiveService, FoodDbService? foodDbService})
    : _hiveService = hiveService ?? HiveService(),
      _foodDbService = foodDbService ?? FoodDbService();

  // Diet Entries (Local storage via Hive)
  List<DietEntry> getDietEntries() {
    return _hiveService.getDietEntries();
  }

  Future<void> saveDietEntry(DietEntry entry) async {
    await _hiveService.saveDietEntry(entry);
  }

  Future<void> deleteDietEntry(String id) async {
    await _hiveService.deleteDietEntry(id);
  }

  // Food Presets (User's custom foods)
  List<FoodItem> getFoodItems() {
    return _hiveService.getFoodItems();
  }

  Future<void> saveFoodItem(FoodItem item) async {
    await _hiveService.saveFoodItem(item);
  }

  Future<void> deleteFoodItem(String id) async {
    await _hiveService.deleteFoodItem(id);
  }

  // Food Database (Read-only JSON)
  Future<List<FoodDatabaseItem>> searchFoods(
    String query, {
    int limit = 50,
    int offset = 0,
  }) {
    return _foodDbService.search(query, limit: limit, offset: offset);
  }

  Future<FoodDatabaseItem?> getFoodByCode(String code) {
    return _foodDbService.getFoodByCode(code);
  }

  Future<List<FoodDatabaseItem>> getPopularFoods({int limit = 20}) {
    return _foodDbService.getPopularFoods(limit: limit);
  }
}
