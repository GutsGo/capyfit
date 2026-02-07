import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/data/models/user_profile.dart';
import 'package:capyfit/data/utils/validators.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _formKey = GlobalKey<FormState>();
  late UserGoal _selectedGoal;
  late TextEditingController _weightGoalController;
  late TextEditingController _dailyStepsController;
  late TextEditingController _customGoalController;
  late bool _isSmart;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().userProfile;
    _selectedGoal = profile.goal;
    _weightGoalController = TextEditingController(
      text:
          profile.targetWeight?.toString() ?? profile.weight?.toString() ?? '',
    );
    _dailyStepsController = TextEditingController(
      text: profile.dailyStepsGoal?.toString() ?? '',
    );
    _customGoalController = TextEditingController(
      text: profile.customCalorieGoal.toString(),
    );
    _isSmart = profile.isSmartCalculation;
  }

  @override
  void dispose() {
    _weightGoalController.dispose();
    _dailyStepsController.dispose();
    _customGoalController.dispose();
    super.dispose();
  }

  int _calculateLiveRecommended() {
    final profile = context.read<AppProvider>().userProfile;
    // Use current profile data but override the goal with selected one
    final tempProfile = profile.copyWith(goal: _selectedGoal);
    return tempProfile.calculateRecommendedCalories();
  }

  void _saveGoals() {
    // 执行表单校验
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appProvider = context.read<AppProvider>();
    final currentProfile = appProvider.userProfile;

    final newProfile = currentProfile.copyWith(
      goal: _selectedGoal,
      targetWeight: double.tryParse(_weightGoalController.text),
      dailyStepsGoal: int.tryParse(_dailyStepsController.text),
      isSmartCalculation: _isSmart,
      customCalorieGoal: int.tryParse(_customGoalController.text) ?? 2000,
    );

    appProvider.updateUserProfile(newProfile);

    Navigator.pop(context);
    showHandDrawnSnackBar(context, '目标设置已成功更新！');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('目标设置')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                      Validators.targetWeight,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      '每日步数目标',
                      _dailyStepsController,
                      TextInputType.number,
                      LucideIcons.footprints,
                      Validators.dailySteps,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('计算偏好'),
              HandDrawnCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '智能计算目标',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.getTextMainColor(context),
                              ),
                            ),
                            Text(
                              '根据身体数据自动推荐',
                              style: TextStyle(
                                color: AppColors.getTextMutedColor(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isSmart,
                          onChanged: (val) => setState(() => _isSmart = val),
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                    if (_isSmart) ...[
                      const SizedBox(height: 12),
                      HandDrawnContainer(
                        padding: const EdgeInsets.all(12),
                        color: AppColors.accentMint.withOpacity(0.2),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.sparkles,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '当前推荐: ${_calculateLiveRecommended()} kcal / 天',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (!_isSmart) ...[
                      const SizedBox(height: 16),
                      _buildInputField(
                        '自定义每日热量目标 (kcal)',
                        _customGoalController,
                        TextInputType.number,
                        LucideIcons.flame,
                        Validators.dailyCalorieGoal,
                      ),
                    ],
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
    IconData icon, [
    String? Function(String?)? validator,
  ]) {
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
          validator: validator,
          hintText: '请输入...',
        ),
      ],
    );
  }
}
