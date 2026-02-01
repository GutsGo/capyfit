import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../widgets/hand_drawn_widgets.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  int _selectedType = 0;
  final List<String> _types = ['功能建议', '系统问题', '内容报错', '其他'];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    // 执行表单校验
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // [IMPORTANT] Get token via: flutter run --dart-define=GITHUB_TOKEN=your_token
      const String githubToken = String.fromEnvironment('GITHUB_TOKEN');

      if (githubToken.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('错误：请联系开发者。'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      final response = await http.post(
        Uri.parse(GlobalConstants.githubDispatchesUrl),
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'event_type': 'create_feedback_issue',
          'client_payload': {
            'type': _types[_selectedType],
            'content': _feedbackController.text.trim(),
            'contact': _contactController.text.trim(),
          },
        }),
      );

      if (mounted) {
        if (response.statusCode == 204) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '感谢您的反馈！卡皮正在努力处理中...',
                style: TextStyle(color: AppColors.getTextMainColor(context)),
              ),
              backgroundColor: AppColors.getCardColor(context),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('提交失败，请稍后重试 (${response.statusCode})'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('网络错误: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '意见反馈',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.getTextMainColor(context),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('反馈类型'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_types.length, (index) {
                  final isSelected = _selectedType == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = index),
                    child: HandDrawnContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.getCardColor(context),
                      borderRadius: 20,
                      child: Text(
                        _types[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.getTextMainColor(context),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('反馈详情'),
              HandDrawnTextField(
                controller: _feedbackController,
                maxLines: 6,
                validator: Validators.feedbackContent,
                hintText: '描述一下您遇到的问题或您的建议吧（至少10个字符）...',
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('联系方式 (选填)'),
              HandDrawnTextField(
                controller: _contactController,
                validator: Validators.contact,
                hintText: '留下邮箱或手机号，方便我们回复您',
              ),
              const SizedBox(height: 48),
              Center(
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : HandDrawnButton(
                        label: '提交反馈',
                        onPressed: _submitFeedback,
                        backgroundColor: AppColors.primary,
                        textColor: Colors.white,
                        width: double.infinity,
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.getTextMainColor(context),
        ),
      ),
    );
  }
}
