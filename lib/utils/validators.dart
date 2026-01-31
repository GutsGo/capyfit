/// 表单校验工具类
class Validators {
  Validators._();

  /// 必填校验
  static String? required(String? value, [String fieldName = '此字段']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  /// 数字校验
  static String? number(String? value, [String fieldName = '此字段']) {
    if (value == null || value.isEmpty) return null; // 空值由 required 校验
    if (double.tryParse(value) == null) {
      return '$fieldName必须为有效数字';
    }
    return null;
  }

  /// 范围校验
  static String? range(
    String? value, {
    double? min,
    double? max,
    String fieldName = '此字段',
    String? unit,
  }) {
    if (value == null || value.isEmpty) return null;
    final num = double.tryParse(value);
    if (num == null) return null; // 由 number 校验处理

    final unitStr = unit != null ? ' $unit' : '';
    if (min != null && num < min) {
      return '$fieldName不能小于$min$unitStr';
    }
    if (max != null && num > max) {
      return '$fieldName不能大于$max$unitStr';
    }
    return null;
  }

  /// 组合多个校验器
  static String? compose(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  /// 预设：营养素校验（每100g，0-100范围）
  static String? nutrient(String? value, String fieldName) {
    return compose(value, [
      (v) => number(v, fieldName),
      (v) => range(v, min: 0, max: 100, fieldName: fieldName, unit: 'g'),
    ]);
  }

  /// 预设：卡路里校验（每100g，0-900范围）
  static String? calories(String? value) {
    return compose(value, [
      (v) => number(v, '卡路里'),
      (v) => range(v, min: 0, max: 900, fieldName: '卡路里', unit: 'kcal'),
    ]);
  }

  /// 预设：体重校验（20-300kg）
  static String? weight(String? value) {
    return compose(value, [
      (v) => required(v, '体重'),
      (v) => number(v, '体重'),
      (v) => range(v, min: 20, max: 300, fieldName: '体重', unit: 'kg'),
    ]);
  }

  /// 预设：身高校验（50-250cm）
  static String? height(String? value) {
    return compose(value, [
      (v) => required(v, '身高'),
      (v) => number(v, '身高'),
      (v) => range(v, min: 50, max: 250, fieldName: '身高', unit: 'cm'),
    ]);
  }

  /// 预设：年龄校验（1-150）
  static String? age(String? value) {
    return compose(value, [
      (v) => required(v, '年龄'),
      (v) => number(v, '年龄'),
      (v) => range(v, min: 1, max: 150, fieldName: '年龄', unit: '岁'),
    ]);
  }

  /// 预设：食物重量校验（1-5000g）
  static String? foodWeight(String? value) {
    return compose(value, [
      (v) => required(v, '重量'),
      (v) => number(v, '重量'),
      (v) => range(v, min: 1, max: 5000, fieldName: '重量', unit: 'g'),
    ]);
  }

  /// 预设：每日卡路里目标校验（1000-5000kcal）
  static String? dailyCalorieGoal(String? value) {
    return compose(value, [
      (v) => required(v, '每日热量目标'),
      (v) => number(v, '每日热量目标'),
      (v) => range(v, min: 1000, max: 5000, fieldName: '每日热量目标', unit: 'kcal'),
    ]);
  }

  /// 预设：每日步数校验（1000-50000）
  static String? dailySteps(String? value) {
    return compose(value, [
      (v) => required(v, '每日步数'),
      (v) => number(v, '每日步数'),
      (v) => range(v, min: 1000, max: 50000, fieldName: '每日步数', unit: '步'),
    ]);
  }

  /// 预设：目标体重校验（与普通体重相同范围：20-300kg）
  static String? targetWeight(String? value) {
    return compose(value, [
      (v) => required(v, '目标体重'),
      (v) => number(v, '目标体重'),
      (v) => range(v, min: 20, max: 300, fieldName: '目标体重', unit: 'kg'),
    ]);
  }

  /// 预设：反馈内容校验（最少10字）
  static String? feedbackContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入反馈内容';
    }
    if (value.trim().length < 10) {
      return '反馈内容至少需要10个字符';
    }
    return null;
  }

  /// 邮箱格式校验
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // 空值由 required 校验
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  /// 手机号格式校验（中国大陆）
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null; // 空值由 required 校验
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '请输入有效的手机号码';
    }
    return null;
  }

  /// 联系方式校验（邮箱或手机号，可选）
  static String? contact(String? value) {
    if (value == null || value.trim().isEmpty) return null; // 选填，空值通过
    final trimmed = value.trim();
    // 尝试邮箱格式
    if (trimmed.contains('@')) {
      return email(trimmed);
    }
    // 尝试手机号格式
    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      return phone(trimmed);
    }
    return '请输入有效的邮箱或手机号';
  }
}
