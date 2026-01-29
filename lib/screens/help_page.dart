import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/hand_drawn_widgets.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '使用帮助',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.getTextMainColor(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHelpCard(
            context,
            '如何创建训练计划？',
            '在“计划”页面，点击右下角的“+”按钮，选择您想要进行的练习并设定目标即可。',
            LucideIcons.plusCircle,
          ),
          const SizedBox(height: 16),
          _buildHelpCard(
            context,
            '每日热量是如何计算的？',
            '我们采用 Mifflin-St Jeor 公式，根据您的身高、体重、年龄和健身目标自动计算推荐热量。',
            LucideIcons.calculator,
          ),
          const SizedBox(height: 16),
          _buildHelpCard(
            context,
            '数据会同步到云端吗？',
            '目前版本所有数据均存储在您的本地设备上。请记得在“数据备份”中定期导出备份。',
            LucideIcons.database,
          ),
          const SizedBox(height: 16),
          _buildHelpCard(
            context,
            '如何切换深色模式？',
            '在个人中心顶部，点击太阳或月亮图标即可快速切换主题。',
            LucideIcons.moon,
          ),
          const SizedBox(height: 32),
          HandDrawnContainer(
            padding: const EdgeInsets.all(20),
            color: AppColors.primary.withOpacity(0.05),
            child: Column(
              children: [
                const Icon(
                  LucideIcons.heartHandshake,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  '还有其他问题？',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.getTextMainColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '欢迎通过意见反馈告诉我们，我们会尽快为您解答。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextMutedColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(
    BuildContext context,
    String question,
    String answer,
    IconData icon,
  ) {
    return HandDrawnCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.getTextMainColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMainColor(context).withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
