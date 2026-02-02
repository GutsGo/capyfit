import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/data/models/user_profile.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/data/utils/validators.dart';
import 'package:capyfit/data/utils/constants.dart';
import 'package:capyfit/data/utils/assets.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/data/utils/routes.dart';

/// 步骤1：欢迎页面
class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  final bool isAgreed;
  final ValueChanged<bool> onAgreedChanged;

  const WelcomeStep({
    super.key,
    required this.onNext,
    required this.isAgreed,
    required this.onAgreedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(GlobalAssets.logoMac, width: 160, height: 160),
                const SizedBox(height: 20),
                Text(
                  GlobalConstants.onboardingWelcomeTitle,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextMainColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  GlobalConstants.onboardingWelcomeSubtitle,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.getTextMainColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  GlobalConstants.onboardingWelcomeDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextMutedColor(context),
                    height: 1.5,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 协议勾选
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isAgreed,
                  onChanged: (v) => onAgreedChanged(v ?? false),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => onAgreedChanged(!isAgreed),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextMutedColor(context),
                      ),
                      children: [
                        const TextSpan(text: '我已阅读并同意 '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () => context.push(GlobalRoutes.terms),
                            child: const Text(
                              '《用户协议》',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' 和 '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () => context.push(GlobalRoutes.privacy),
                            child: const Text(
                              '《隐私政策》',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          HandDrawnButton(
            key: const ValueKey('onboarding_start_button'),
            label: GlobalConstants.onboardingStart,
            onPressed: isAgreed ? onNext : () {},
            width: double.infinity,
            backgroundColor: isAgreed
                ? AppColors.primary
                : Colors.grey.shade300,
            textColor: isAgreed ? Colors.white : Colors.grey.shade600,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// 步骤2：身体数据 + 性别
class BodyDataStep extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController ageController;
  final Gender gender;
  final ValueChanged<Gender> onGenderChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const BodyDataStep({
    super.key,
    required this.heightController,
    required this.weightController,
    required this.ageController,
    required this.gender,
    required this.onGenderChanged,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(
                    context,
                    '📏',
                    GlobalConstants.onboardingBodyDataTitle,
                    GlobalConstants.onboardingBodyDataSubtitle,
                  ),
                  const SizedBox(height: 24),

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
                          '🧝‍♂️',
                          gender == Gender.male,
                          () => onGenderChanged(Gender.male),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGenderCard(
                          context,
                          '女',
                          '🧝‍♀️',
                          gender == Gender.female,
                          () => onGenderChanged(Gender.female),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    '身体数据 (可选)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextMainColor(context),
                    ),
                  ),
                  const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                '跳过',
                style: TextStyle(
                  color: AppColors.getTextMutedColor(context),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          HandDrawnButton(
            key: const ValueKey('onboarding_next_body_button'),
            label: '下一步',
            onPressed: onNext,
            width: double.infinity,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(
    BuildContext context,
    String label,
    String emoji,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: HandDrawnCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
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

  Widget _buildHeader(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMainColor(context),
          ),
        ),
        const SizedBox(height: 4),
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

/// 步骤3：健身目标
class ProfileStep extends StatelessWidget {
  final UserGoal goal;
  final ValueChanged<UserGoal> onGoalChanged;
  final VoidCallback onNext;

  const ProfileStep({
    super.key,
    required this.goal,
    required this.onGoalChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(context, '🎯', '你的目标', '选择你最想达成的健身目标'),
                  const SizedBox(height: 32),
                  // 目标选择
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
          ),
          const SizedBox(height: 24),
          HandDrawnButton(
            key: const ValueKey('onboarding_finish_button'),
            label: '开始健身之旅 💪',
            onPressed: onNext,
            width: double.infinity,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
          ),
        ],
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
