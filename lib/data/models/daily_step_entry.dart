import 'package:hive/hive.dart';

part 'daily_step_entry.g.dart';

@HiveType(typeId: 13)
class DailyStepEntry extends HiveObject {
  @HiveField(0)
  final String date; // Format: yyyy-mm-dd

  @HiveField(1)
  final int steps;

  DailyStepEntry({required this.date, required this.steps});
}
