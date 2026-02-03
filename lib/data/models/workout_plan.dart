import 'package:hive/hive.dart';
import 'package:lunar/lunar.dart';

part 'workout_plan.g.dart';

@HiveType(typeId: 10)
enum WorkoutType {
  @HiveField(0)
  strength,
  @HiveField(1)
  cardio,
  @HiveField(2)
  yoga,
  @HiveField(3)
  other,
}

@HiveType(typeId: 11)
enum Intensity {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 12)
enum PlanMode {
  @HiveField(0)
  longTerm,
  @HiveField(2)
  oneTime,
}

@HiveType(typeId: 9)
class WorkoutPlan extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String date;
  @HiveField(3)
  final String time;
  @HiveField(4)
  final int duration;
  @HiveField(5)
  final int calories;
  @HiveField(6)
  final WorkoutType type;
  @HiveField(7)
  final Intensity intensity;
  @HiveField(8)
  final bool completed; // For oneTime plans
  @HiveField(9)
  final List<String>? exercises;
  @HiveField(10)
  final PlanMode mode;
  @HiveField(11)
  final List<String>? completedDates; // Track completed dates for longTerm plans
  @HiveField(12)
  final String? endDate; // For longTerm plans, the date when it was "deleted"
  @HiveField(13)
  final bool? isDeleted; // Logical delete for oneTime plans
  @HiveField(14)
  final List<int>? repeatDays; // 1-7 for Mon-Sun, null/empty for everyday
  @HiveField(15, defaultValue: false)
  final bool isChinaHolidayPlan; // True if active on holidays
  @HiveField(16, defaultValue: false)
  final bool isChinaWorkdayPlan; // True if active on workdays (including make-up workdays)

  WorkoutPlan({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.duration,
    required this.calories,
    required this.type,
    required this.intensity,
    required this.completed,
    this.exercises,
    this.mode = PlanMode.oneTime,
    this.completedDates,
    this.endDate,
    this.isDeleted,
    this.repeatDays,
    this.isChinaHolidayPlan = false,
    this.isChinaWorkdayPlan = false,
  });

  /// Get a user-friendly label for the plan's recurrence mode
  String get recurrenceLabel {
    if (mode == PlanMode.oneTime) {
      return '单次计划';
    }

    if (isChinaWorkdayPlan) {
      return '长期 (工作日)';
    }

    if (isChinaHolidayPlan) {
      return '长期 (节假日)';
    }

    if (repeatDays != null && repeatDays!.isNotEmpty) {
      final days = repeatDays!.toSet().toList()..sort();
      final dayLabels = days
          .map((d) {
            const labels = ['一', '二', '三', '四', '五', '六', '日'];
            return labels[d - 1];
          })
          .join('/');
      return '长期 (周$dayLabels)';
    }

    return '长期 (每天)';
  }

  /// Check if this plan is completed on a specific date
  bool isCompletedOn(String dateStr) {
    if (mode == PlanMode.oneTime) {
      return completed;
    } else {
      // For longTerm plans, check the completedDates list
      return completedDates?.contains(dateStr) ?? false;
    }
  }

  /// Check if the plan is active on a specific date (for filtering)
  bool isActiveOn(DateTime date) {
    if (mode == PlanMode.oneTime) {
      final dateOnlyStr = date.toString().split(' ')[0];
      return this.date == dateOnlyStr;
    }

    // LongTerm plan
    final dateOnlyStr = date.toString().split(' ')[0];

    // Check endDate
    if (endDate != null && dateOnlyStr.compareTo(endDate!) > 0) {
      return false;
    }

    // Check startDate (using this.date as start date for long term plans)
    if (dateOnlyStr.compareTo(this.date) < 0) {
      return false;
    }

    if (isChinaWorkdayPlan) {
      final solar = Solar.fromYmd(date.year, date.month, date.day);
      final holiday = HolidayUtil.getHoliday(solar.toYmd());
      // A day is a workday if:
      // 1. It's a normal workday (Mon-Fri) and NOT a holiday
      // 2. OR it's a weekend but marked as WORK (make-up day) in holiday list

      if (holiday != null) {
        return holiday.isWork();
      } else {
        // No holiday info, follow Mon-Fri rule
        final weekday = date.weekday;
        return weekday >= 1 && weekday <= 5;
      }
    }

    if (isChinaHolidayPlan) {
      final solar = Solar.fromYmd(date.year, date.month, date.day);
      final holiday = HolidayUtil.getHoliday(solar.toYmd());

      // A day is a holiday if:
      // 1. It is marked as holiday (NOT work) in holiday list
      // 2. OR it's a weekend (Sat-Sun) and NOT marked as work

      if (holiday != null) {
        return !holiday.isWork();
      } else {
        final weekday = date.weekday;
        return weekday == 6 || weekday == 7;
      }
    }

    if (repeatDays != null && repeatDays!.isNotEmpty) {
      return repeatDays!.contains(date.weekday);
    }

    // Default to everyday if no specific rules
    return true;
  }

  /// Toggle completion status for a specific date
  WorkoutPlan toggleCompletionFor(String dateStr) {
    if (mode == PlanMode.oneTime) {
      return copyWith(completed: !completed);
    } else {
      // For longTerm plans, add or remove the date from completedDates
      final dates = List<String>.from(completedDates ?? []);
      if (dates.contains(dateStr)) {
        dates.remove(dateStr);
      } else {
        dates.add(dateStr);
      }
      return copyWith(completedDates: dates);
    }
  }

  /// Toggle completion status for a specific date (alias for toggleCompletionFor for matching older code)
  WorkoutPlan toggleComplete(String dateStr) {
    return toggleCompletionFor(dateStr);
  }

  WorkoutPlan copyWith({
    String? id,
    String? name,
    String? date,
    String? time,
    int? duration,
    int? calories,
    WorkoutType? type,
    Intensity? intensity,
    bool? completed,
    List<String>? exercises,
    PlanMode? mode,
    List<String>? completedDates,
    String? endDate,
    bool? isDeleted,
    List<int>? repeatDays,
    bool? isChinaHolidayPlan,
    bool? isChinaWorkdayPlan,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      completed: completed ?? this.completed,
      exercises: exercises ?? this.exercises,
      mode: mode ?? this.mode,
      completedDates: completedDates ?? this.completedDates,
      endDate: endDate ?? this.endDate,
      isDeleted: isDeleted ?? this.isDeleted,
      repeatDays: repeatDays ?? this.repeatDays,
      isChinaHolidayPlan: isChinaHolidayPlan ?? this.isChinaHolidayPlan,
      isChinaWorkdayPlan: isChinaWorkdayPlan ?? this.isChinaWorkdayPlan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'time': time,
      'duration': duration,
      'calories': calories,
      'type': type.index,
      'intensity': intensity.index,
      'completed': completed,
      'exercises': exercises,
      'mode': mode.index,
      'completedDates': completedDates,
      'endDate': endDate,
      'isDeleted': isDeleted,
      'repeatDays': repeatDays,
      'isChinaHolidayPlan': isChinaHolidayPlan,
      'isChinaWorkdayPlan': isChinaWorkdayPlan,
    };
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      duration: json['duration'] as int,
      calories: json['calories'] as int,
      type: WorkoutType.values[json['type'] as int],
      intensity: Intensity.values[json['intensity'] as int],
      completed: json['completed'] as bool,
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mode: PlanMode.values[json['mode'] as int? ?? 1], // Default to oneTime
      completedDates: (json['completedDates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      endDate: json['endDate'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      isChinaHolidayPlan: json['isChinaHolidayPlan'] as bool? ?? false,
      isChinaWorkdayPlan: json['isChinaWorkdayPlan'] as bool? ?? false,
    );
  }
}
