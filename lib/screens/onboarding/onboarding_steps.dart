import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../../widgets/hand_drawn_widgets.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/validators.dart';

/// 步骤1：欢迎页面
class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(
            'assets/images/capy_running.webp',
            width: 160,
            height: 160,
          ),
          const SizedBox(height: 32),
          Text(
            '欢迎使用 CapyFit',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMainColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '你的专属健身与饮食伙伴',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.getTextMutedColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '让我们花几分钟设置你的个人资料\n以便为你提供更精准的建议',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMutedColor(context),
              height: 1.5,
            ),
          ),
          const Spacer(),
          HandDrawnButton(
            label: '开始设置 →',
            onPressed: onNext,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

/// 步骤2：身体数据
class BodyDataStep extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController ageController;
  final GlobalKey<FormState> formKey;

  const BodyDataStep({
    super.key,
    required this.heightController,
    required this.weightController,
    required this.ageController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context, '📏', '身体数据', '这些数据帮助我们计算你的每日所需热量'),
              const SizedBox(height: 32),
              HandDrawnCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInputField(
                      context,
                      '身高',
                      'cm',
                      heightController,
                      Validators.height,
                      LucideIcons.ruler,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      context,
                      '体重',
                      'kg',
                      weightController,
                      Validators.weight,
                      LucideIcons.scale,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      context,
                      '年龄',
                      '岁',
                      ageController,
                      Validators.age,
                      LucideIcons.calendar,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMainColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextMutedColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    BuildContext context,
    String label,
    String suffix,
    TextEditingController controller,
    String? Function(String?)? validator,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: HandDrawnTextField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: validator,
        labelText: label,
        hintText: '请输入',
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            suffix,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMutedColor(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// 步骤3：基本资料（性别和目标）
class ProfileStep extends StatelessWidget {
  final Gender gender;
  final UserGoal goal;
  final ValueChanged<Gender> onGenderChanged;
  final ValueChanged<UserGoal> onGoalChanged;

  const ProfileStep({
    super.key,
    required this.gender,
    required this.goal,
    required this.onGenderChanged,
    required this.onGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(context, '👤', '基本资料', '告诉我们你的性别和健身目标'),
            const SizedBox(height: 32),
            // 性别选择
            Text(
              '性别',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextMainColor(context),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGenderCard(
                    context,
                    '男',
                    LucideIcons.userCircle,
                    gender == Gender.male,
                    () => onGenderChanged(Gender.male),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderCard(
                    context,
                    '女',
                    LucideIcons.userCircle2,
                    gender == Gender.female,
                    () => onGenderChanged(Gender.female),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // 目标选择
            Text(
              '健身目标',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextMainColor(context),
              ),
            ),
            const SizedBox(height: 12),
            _buildGoalCard(
              context,
              '减重',
              '减少体重，塑造更轻盈的身材',
              LucideIcons.arrowDown,
              goal == UserGoal.weightLoss,
              () => onGoalChanged(UserGoal.weightLoss),
            ),
            const SizedBox(height: 12),
            _buildGoalCard(
              context,
              '保持匀称',
              '维持现有体重，保持健康体态',
              LucideIcons.scale,
              goal == UserGoal.maintain,
              () => onGoalChanged(UserGoal.maintain),
            ),
            const SizedBox(height: 12),
            _buildGoalCard(
              context,
              '增肌',
              '增加肌肉量，提升力量和体能',
              LucideIcons.arrowUp,
              goal == UserGoal.muscleGain,
              () => onGoalChanged(UserGoal.muscleGain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMainColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextMutedColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderCard(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: HandDrawnCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.getTextMutedColor(context),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextMainColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: HandDrawnCard(
        padding: const EdgeInsets.all(16),
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextMutedColor(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : AppColors.getTextMutedColor(context),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.getTextMainColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextMutedColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(LucideIcons.checkCircle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

/// 步骤4：计算偏好
class GoalSettingStep extends StatelessWidget {
  final bool isSmart;
  final int recommendedCalories;
  final TextEditingController customGoalController;
  final ValueChanged<bool> onSmartChanged;

  const GoalSettingStep({
    super.key,
    required this.isSmart,
    required this.recommendedCalories,
    required this.customGoalController,
    required this.onSmartChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(context, '🎯', '热量目标', '选择如何设定你的每日热量目标'),
            const SizedBox(height: 32),
            // 智能计算选项
            _buildOptionCard(
              context,
              '智能计算',
              '根据你的身体数据和目标自动推荐',
              LucideIcons.sparkles,
              isSmart,
              () => onSmartChanged(true),
            ),
            if (isSmart) ...[
              const SizedBox(height: 16),
              HandDrawnContainer(
                padding: const EdgeInsets.all(16),
                color: AppColors.accentMint.withOpacity(0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.flame, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      '推荐: $recommendedCalories kcal / 天',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // 自定义选项
            _buildOptionCard(
              context,
              '自定义目标',
              '手动设置你的每日热量目标',
              LucideIcons.edit3,
              !isSmart,
              () => onSmartChanged(false),
            ),
            if (!isSmart) ...[
              const SizedBox(height: 16),
              HandDrawnTextField(
                controller: customGoalController,
                keyboardType: TextInputType.number,
                validator: Validators.dailyCalorieGoal,
                hintText: '输入每日热量',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMainColor(context),
                ),
                prefixIcon: const Icon(
                  LucideIcons.edit3,
                  color: AppColors.primary,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'kcal / 天',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextMutedColor(context),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMainColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextMutedColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: HandDrawnCard(
        padding: const EdgeInsets.all(16),
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextMutedColor(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : AppColors.getTextMutedColor(context),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.getTextMainColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextMutedColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(LucideIcons.checkCircle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

/// 步骤5：完成确认
class ConfirmationStep extends StatelessWidget {
  final double height;
  final double weight;
  final int age;
  final Gender gender;
  final UserGoal goal;
  final bool isSmart;
  final int calorieGoal;
  final VoidCallback onComplete;

  const ConfirmationStep({
    super.key,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.goal,
    required this.isSmart,
    required this.calorieGoal,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 标题
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            '设置完成！',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMainColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '确认以下信息后即可开始',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMutedColor(context),
            ),
          ),
          const SizedBox(height: 32),
          // 信息汇总
          Expanded(
            child: HandDrawnCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    '身高',
                    '${height.toStringAsFixed(0)} cm',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    '体重',
                    '${weight.toStringAsFixed(1)} kg',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(context, '年龄', '$age 岁'),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    '性别',
                    gender == Gender.male ? '男' : '女',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(context, '目标', _getGoalText(goal)),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    '每日热量',
                    '$calorieGoal kcal',
                    highlight: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          HandDrawnButton(
            label: '开始健身之旅 💪',
            onPressed: onComplete,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getGoalText(UserGoal goal) {
    switch (goal) {
      case UserGoal.weightLoss:
        return '减重';
      case UserGoal.maintain:
        return '保持匀称';
      case UserGoal.muscleGain:
        return '增肌';
    }
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextMutedColor(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: highlight
                ? AppColors.primary
                : AppColors.getTextMainColor(context),
          ),
        ),
      ],
    );
  }
}
