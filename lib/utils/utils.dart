import 'constants.dart';

class GlobalUtils {
  /// 格式化日期为 "yyyy年M月d日"
  static String formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 获取当前时间的问候语
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return GlobalConstants.homeGreetingMorning;
    } else if (hour < 18) {
      return GlobalConstants.homeGreetingAfternoon;
    } else {
      return GlobalConstants.homeGreetingEvening;
    }
  }

  /// 格式化持续时间（分钟）
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes分钟';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours小时';
    }
    return '$hours小时$remainingMinutes分钟';
  }

  /// 仅保留日期部分的字符串 (yyyy-MM-dd)
  static String dateOnly(DateTime date) {
    return date.toString().split(' ')[0];
  }

  /// 格式化加入天数
  static String formatJoinedDays(int days) {
    return '加入卡皮健身第 $days 天';
  }
}
