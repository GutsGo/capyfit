import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/hand_drawn_widgets.dart';
import '../providers/app_provider.dart';
import '../models/user_profile.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late UserGoal _selectedGoal;
  late TextEditingController _weightGoalController;
  late TextEditingController _dailyStepsController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().userProfile;
    _selectedGoal = profile.goal;
    _weightGoalController = TextEditingController(
      text: profile.weight.toString(),
    ); // Placeholder logic
    _dailyStepsController = TextEditingController(text: '10000');
  }

  @override
  void dispose() {
    _weightGoalController.dispose();
    _dailyStepsController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    // In a real app, update the provider/database
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '目标设置已成功更新！',
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
          '目标设置',
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
            _buildSectionTitle('长期目标'),
            HandDrawnCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildGoalOption(
                    '减重瘦身',
                    '减少体脂，塑造苗条身材',
                    LucideIcons.trendingDown,
                    UserGoal.weightLoss,
                  ),
                  const Divider(height: 24),
                  _buildGoalOption(
                    '保持平衡',
                    '维持现状，追求健康生活',
                    LucideIcons.scale,
                    UserGoal.maintain,
                  ),
                  const Divider(height: 24),
                  _buildGoalOption(
                    '增肌强力',
                    '增加肌肉，提升力量素质',
                    LucideIcons
                        .armchair, // Using similar icon if bicep is not available
                    UserGoal.muscleGain,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('具体指标'),
            HandDrawnCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInputField(
                    '目标体重 (kg)',
                    _weightGoalController,
                    TextInputType.number,
                    LucideIcons.list,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    '每日步数目标',
                    _dailyStepsController,
                    TextInputType.number,
                    LucideIcons.footprints,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            HandDrawnContainer(
              padding: const EdgeInsets.all(16),
              color: AppColors.accentMint.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.info,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '设置合理的目标有助于更好地坚持。建议每周减重不超过 0.5-1kg。',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextMainColor(
                          context,
                        ).withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: HandDrawnButton(
                label: '设定目标',
                onPressed: _saveGoals,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              ),
            ),
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

  Widget _buildGoalOption(
    String title,
    String subtitle,
    IconData icon,
    UserGoal goal,
  ) {
    final isSelected = _selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getBackgroundColor(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : AppColors.getTextMutedColor(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.getTextMainColor(context),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.getTextMutedColor(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                LucideIcons.checkCircle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    TextInputType type,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.getTextMutedColor(context)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextMutedColor(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        HandDrawnTextField(
          controller: controller,
          keyboardType: type,
          hintText: '请输入...',
        ),
      ],
    );
  }
}
