import 'package:capyfit/data/models/exercise.dart';
import 'package:capyfit/data/services/food_db_service.dart';
import 'package:capyfit/data/services/llm_service.dart';
import 'package:capyfit/data/utils/diet_parser.dart';
import 'package:capyfit/data/utils/logger.dart';

class AICoachService {
  final LLMService _llmService = LLMService();

  // 全局静态变量，确保切换页面后依然生效
  static DateTime? _lastInterpretationTime;

  /// 检查动作解读的速率限制 (10秒内最多一次)
  bool checkInterpretationRateLimit() {
    final now = DateTime.now();
    if (_lastInterpretationTime != null &&
        now.difference(_lastInterpretationTime!).inSeconds < 10) {
      return false;
    }
    _lastInterpretationTime = now;
    return true;
  }

  /// 1. 智能化饮食解析 (原 DietEstimationService.aiEstimate)
  Future<List<ParsedFoodItem>?> parseDietItems(String input) async {
    // 召回本地数据库中的匹配项以辅助 LLM 标准化名称
    final refContext = await _getRecallContext(input);

    final dietTool = {
      'name': 'parse_diet',
      'description':
          'Parse natural language diet description into structured food items. '
          'Estimate the weight in grams if the user doesn\'t specify a precise amount. '
          '${refContext.isNotEmpty ? "Prefer using names from: $refContext" : ""}',
      'parameters': {
        'type': 'object',
        'properties': {
          'items': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'food': {
                  'type': 'string',
                  'description':
                      'The standard name of the food from the provided list',
                },
                'amount': {
                  'type': 'number',
                  'description':
                      'The estimated amount in grams (numeric only).',
                },
              },
              'required': ['food', 'amount'],
            },
          },
        },
        'required': ['items'],
      },
    };

    try {
      final result = await _llmService.callTool(
        messages: [
          LLMMessage(
            role: 'system',
            content:
                '你是一位专业营养师。请将用户的输入（如“两碗米饭”）解析为结构化列表并估算其重量（单位克）。'
                '注意：必须优先匹配《中国食物成分表》第六版中的食物。'
                '请根据一个成年人、标准体重，合理估算对应食物的“克”数（例如：普通瓷碗一碗熟米饭约200克）。'
                '${refContext.isNotEmpty ? "参考库(格式为 名称(代码)): $refContext 。请从中选择最匹配的项。" : "从《中国食物成分表》第六版中选择最匹配的项。"}',
          ),
          LLMMessage(role: 'user', content: input),
        ],
        toolDefinition: dietTool,
        toolChoiceName: 'parse_diet',
      );

      if (result != null && result['items'] != null) {
        final List<ParsedFoodItem> items = [];
        for (final item in (result['items'] as List)) {
          items.add(
            ParsedFoodItem(
              rawName: item['food'],
              amount: item['amount']?.toDouble(),
              unit: '克',
            ),
          );
        }
        return items;
      }
    } catch (e) {
      // 记录错误或打印，此处返回 null 触发业务侧回退逻辑
      Log.e('AI Diet Parse Error: $e');
    }
    return null;
  }

  /// 2. 卡皮巴拉健康周报 (预留)
  Future<String> generateWeeklyReport(String userDataSummary) async {
    return _llmService.chat([
      LLMMessage(
        role: 'system',
        content:
            '你是一只情绪稳定的卡皮巴拉健康教练（CapyCoach）。请根据用户的一周数据，用佛系、温暖但专业的口吻写一份简短的周报。',
      ),
      LLMMessage(role: 'user', content: '这是我本周的数据汇总：$userDataSummary'),
    ]);
  }

  /// 3. 动作深度解读
  Future<String> getExerciseInterpretation(Exercise exercise) async {
    final prompt =
        '''
          你是一位资深的健身教练和运动表现专家。请针对动作“${exercise.name}”提供专业的深度解读。
          解读应包含以下几个维度：
          1. 动作本质：用通俗易懂但科学的语言解释这个动作训练的核心逻辑。
          2. 精准发力：如何更好地感知目标肌肉收缩，有哪些心理暗示（Internal Cue）可以帮助发力。
          3. 常见盲点：除了常规注意事项，普通人最容易忽视的细节或常见的代偿点。
          4. 进阶进阶：如何根据个人能力进行微调或增加挑战。

          请保持口吻专业、亲切，使用卡皮巴拉的身份，适当使用表情符号。纯文本，非MD格式。
        ''';

    return _llmService.chat([
      LLMMessage(
        role: 'system',
        content: '你是一只博学多才、深耕健身领域的卡皮巴拉教练。你说话慢条斯理，但每一句都直击要害。',
      ),
      LLMMessage(role: 'user', content: prompt),
    ]);
  }

  /// 4. 个性化鼓励语录 (预留)
  Future<String> getMotivationalQuote(String actionName) async {
    return _llmService.chat([
      LLMMessage(
        role: 'system',
        content: '你是一只可爱的卡皮巴拉。用户刚刚完成了“$actionName”。请说一句独特的、有共鸣的话鼓励它。',
      ),
    ]);
  }

  /// 辅助方法：从本地库中召回最相关的名称及其代码，极致节省 Token
  Future<String> _getRecallContext(String input) async {
    try {
      // 1. 获取食物匹配 (取前 12 个相关项，增加召回概率)
      final foodItems = await FoodDbService().search(input, limit: 12);

      if (foodItems.isEmpty) return '';

      // 以 名称(代码) 格式组合，LLM 对这种格式非常敏感
      final result = foodItems
          .map((e) => '${e.foodName}(${e.foodCode})')
          .join(',');
      Log.d('RAG Recall Context: $input -> $result');
      return result;
    } catch (e) {
      Log.e('RAG Recall Error: $e');
      return '';
    }
  }
}
