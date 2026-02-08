import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:capyfit/data/services/config_service.dart';
import 'package:capyfit/data/services/hive_service.dart';
import 'package:capyfit/data/utils/logger.dart';

/// LLM 消息模型
class LLMMessage {
  final String role;
  final String content;

  LLMMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// LLM 服务类 (适配 Groq/OpenAI 协议)
class LLMService {
  final ConfigService _configService = ConfigService();
  final HiveService _hiveService = HiveService();

  // 熔断时长：6 小时
  static const Duration _breakerDuration = Duration(hours: 6);
  static const String _breakerKey = 'llm_circuit_breaker_until';

  final String? apiKey;

  LLMService({this.apiKey});

  /// 获取 API Key，优先级：显式传入 > 环境变量
  String get _effectiveApiKey {
    final key = apiKey ?? const String.fromEnvironment('OPENAI_TOKEN');
    if (key.isEmpty) {
      throw Exception('Missing OPENAI_TOKEN.');
    }
    return key;
  }

  /// 检查熔断状态
  bool get _isCircuitOpen {
    if (kDebugMode) {
      return false;
    }
    final breakerUntilStr = _hiveService.getSetting<String?>(_breakerKey);
    if (breakerUntilStr == null) return false;
    final until = DateTime.tryParse(breakerUntilStr);
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  /// 开启熔断
  void _openCircuit() {
    final until = DateTime.now().add(_breakerDuration);
    _hiveService.saveSetting(_breakerKey, until.toIso8601String());
  }

  /// 简单的聊天接口
  Future<String> chat(List<LLMMessage> messages) async {
    return _withFailover((model, baseUrl) async {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_effectiveApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages.map((m) => m.toJson()).toList(),
        }),
      );

      Log.d('LLM Chat Request: $model -> $baseUrl');
      Log.d('LLM Chat Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] as String;
      }

      if (response.statusCode == 429) {
        return null; // 触发 failover
      }

      throw Exception(
        'LLM Chat Error: ${response.statusCode} - ${response.body}',
      );
    });
  }

  /// 使用 Function Calling 接口进行精确解析
  Future<Map<String, dynamic>?> callTool({
    required List<LLMMessage> messages,
    required Map<String, dynamic> toolDefinition,
    String? toolChoiceName,
  }) async {
    return _withFailover((model, baseUrl) async {
      final body = {
        'model': model,
        'messages': messages.map((m) => m.toJson()).toList(),
        'tools': [
          {'type': 'function', 'function': toolDefinition},
        ],
        'tool_choice': toolChoiceName != null
            ? {
                'type': 'function',
                'function': {'name': toolChoiceName},
              }
            : 'auto',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_effectiveApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      Log.d('LLM Tool Request: $model -> $baseUrl');
      Log.d('LLM Tool Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final choice = data['choices'][0];
        final message = choice['message'];

        if (message['tool_calls'] != null && message['tool_calls'].isNotEmpty) {
          final toolCall = message['tool_calls'][0];
          final arguments = toolCall['function']['arguments'];
          Log.i('LLM Tool Arguments: $arguments');
          return jsonDecode(arguments) as Map<String, dynamic>;
        }
        return <String, dynamic>{}; // 成功但无工具调用
      }

      if (response.statusCode == 429) {
        return null; // 触发 failover
      }

      throw Exception(
        'LLM Tool Error: ${response.statusCode} - ${response.body}',
      );
    });
  }

  /// 故障转移与模型轮转逻辑
  Future<T> _withFailover<T>(
    Future<T?> Function(String model, String baseUrl) task,
  ) async {
    if (_isCircuitOpen) {
      throw Exception('AI 服务正处于频率限制调整中，请 6 小时后重试。');
    }

    final config = await _configService.fetchConfig();
    final llmConfig = config['llm'] as Map<String, dynamic>?;
    final baseUrl = llmConfig?['api'] ?? 'https://api.groq.com/openai/v1';
    final models = List<String>.from(
      llmConfig?['models'] ?? ['llama-3.3-70b-versatile'],
    );

    for (final model in models) {
      try {
        final result = await task(model, baseUrl);
        if (result != null) return result;
        // 如果返回 null，说明是 429，尝试下一个模型
        Log.w('Model $model rate limited (429). Trying next...');
      } catch (e) {
        // 接口错误：直接退出，不切换模型，且由于用户要求“不要 rethrow”，这里返回一个降级结果
        Log.e('Model $model encountered interface error', e);

        // 根据返回类型提供降级数据，确保上层不报错
        if (T == String) {
          return 'AI 服务暂时不可用，请稍后再试。' as T;
        }

        // 尝试安全返回空 Map 或 null（针对 callTool）
        if (null is T || <String, dynamic>{} is T) {
          try {
            return <String, dynamic>{} as T;
          } catch (_) {
            return null as T;
          }
        }

        throw Exception('AI 服务接口异常: $e');
      }
    }

    // 只有在所有模型都返回 null (即全部 429) 的情况下，才开启 6 小时熔断
    _openCircuit();
    throw Exception('当前 AI 服务负载过高，已进入 6 小时保护期，请稍后再试。');
  }
}
