import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/hand_drawn_widgets.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  int _selectedType = 0;
  final List<String> _types = ['功能建议', '系统问题', '内容报错', '其他'];

  @override
  void dispose() {
    _feedbackController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入反馈内容')));
      return;
    }

    // Mock submission
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
      body: SingleChildScrollView(
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
            HandDrawnContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: AppColors.getCardColor(context),
              child: TextField(
                controller: _feedbackController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: '描述一下您遇到的问题或您的建议吧...',
                  hintStyle: TextStyle(
                    color: AppColors.getTextMutedColor(context),
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: AppColors.getTextMainColor(context)),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('联系方式 (选填)'),
            HandDrawnTextField(
              controller: _contactController,
              hintText: '留下邮箱或手机号，方便我们回复您',
            ),
            const SizedBox(height: 48),
            Center(
              child: HandDrawnButton(
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
