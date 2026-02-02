import 'package:capyfit/data/models/user_profile.dart';
import 'package:capyfit/data/services/hive_service.dart';

class UserRepository {
  final HiveService _hiveService;

  UserRepository({HiveService? hiveService})
    : _hiveService = hiveService ?? HiveService();

  bool get hasUserProfile => _hiveService.hasUserProfile;

  UserProfile? getUserProfile() {
    return _hiveService.getUserProfile();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _hiveService.saveUserProfile(profile);
  }

  String get themeMode => _hiveService.themeMode;

  Future<void> saveThemeMode(String mode) async {
    await _hiveService.saveThemeMode(mode);
  }

  DateTime? get joinedDate => _hiveService.joinedDate;

  Future<void> saveJoinedDate(DateTime date) async {
    await _hiveService.saveJoinedDate(date);
  }

  int get joinedDays => _hiveService.joinedDays;
}
