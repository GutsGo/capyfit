class ParsedFoodItem {
  final String rawName;
  final double? amount;
  final String? unit;

  ParsedFoodItem({required this.rawName, this.amount, this.unit});

  @override
  String toString() =>
      'ParsedFoodItem(name: $rawName, amount: $amount, unit: $unit)';
}

class DietParser {
  /// 解析输入字符串，将其拆分为多个食物项
  /// 例如: "米饭2碗 + 青椒炒肉丝, 鸡蛋1个"
  static List<ParsedFoodItem> parse(String input) {
    if (input.isEmpty) return [];

    // 1. 使用分隔符拆分 (+, ,, 空格)
    // 注意：匹配多个连续的分隔符
    final segments = input
        .split(RegExp(r'[+\,\s]+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return segments.map(_parseSegment).toList();
  }

  static ParsedFoodItem _parseSegment(String segment) {
    // 正则匹配: [名称] [数量(可选)] [单位(可选)]
    // 例如: "米饭2碗", "青椒炒肉丝", "鸡蛋1个", "100g牛肉"

    // 匹配数字（支持小数）和单位
    final regex = RegExp(r'^([^\d]+)?([\d.]+)?(.*)?$');
    final match = regex.firstMatch(segment.trim());

    if (match == null) {
      return ParsedFoodItem(rawName: segment);
    }

    String? namePart = match.group(1)?.trim();
    String? amountStr = match.group(2);
    String? unitPart = match.group(3)?.trim();

    // 处理像 "100g牛肉" 这种情况，名称在数字后面
    if (namePart == null || namePart.isEmpty) {
      if (unitPart != null && unitPart.isNotEmpty) {
        // 尝试从 unitPart 中分离出名称
        // 比如 "g牛肉" -> unit: "g", name: "牛肉"
        final commonUnits = ['g', '克', '碗', '份', '个', '两', '盘'];
        for (final u in commonUnits) {
          if (unitPart.startsWith(u)) {
            final possibleName = unitPart.substring(u.length).trim();
            if (possibleName.isNotEmpty) {
              return ParsedFoodItem(
                rawName: possibleName,
                amount: double.tryParse(amountStr ?? ''),
                unit: u,
              );
            }
          }
        }
      }
    }

    return ParsedFoodItem(
      rawName: namePart ?? segment,
      amount: double.tryParse(amountStr ?? ''),
      unit: unitPart,
    );
  }
}
