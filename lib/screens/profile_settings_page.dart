import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../models/user_profile.dart';
import '../widgets/common_widgets.dart';
import '../widgets/hand_drawn_widgets.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _customGoalController;
  late Gender _gender;
  late UserGoal _goal;
  late bool _isSmart;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().userProfile;
    _heightController = TextEditingController(text: profile.height.toString());
    _weightController = TextEditingController(text: profile.weight.toString());
    _ageController = TextEditingController(text: profile.age.toString());
    _customGoalController = TextEditingController(
      text: profile.customCalorieGoal.toString(),
    );
    _gender = profile.gender;
    _goal = profile.goal;
    _isSmart = profile.isSmartCalculation;

    // Add listeners for real-time updates
    _heightController.addListener(_onInputChanged);
    _weightController.addListener(_onInputChanged);
    _ageController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {
      // Just trigger rebuild to update the "Current Recommended" display
    });
  }

  int _calculateLiveRecommended() {
    final height = double.tryParse(_heightController.text) ?? 175;
    final weight = double.tryParse(_weightController.text) ?? 70;
    final age = int.tryParse(_ageController.text) ?? 25;

    final tempProfile = UserProfile(
      height: height,
      weight: weight,
      gender: _gender,
      age: age,
      goal: _goal,
      isSmartCalculation: _isSmart,
    );

    return tempProfile.calculateRecommendedCalories();
  }

  @override
  void dispose() {
    _heightController.removeListener(_onInputChanged);
    _weightController.removeListener(_onInputChanged);
    _ageController.removeListener(_onInputChanged);
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _customGoalController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final provider = context.read<AppProvider>();
    final newProfile = UserProfile(
      height: double.tryParse(_heightController.text) ?? 175,
      weight: double.tryParse(_weightController.text) ?? 70,
      gender: _gender,
      age: int.tryParse(_ageController.text) ?? 25,
      goal: _goal,
      isSmartCalculation: _isSmart,
      customCalorieGoal: int.tryParse(_customGoalController.text) ?? 2000,
    );
    provider.updateUserProfile(newProfile);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '个人资料已更新',
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
          '个人设置',
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
            _buildSectionTitle('身体数据'),
            HandDrawnCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInputField(
                    '身高 (cm)',
                    _heightController,
                    TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    '体重 (kg)',
                    _weightController,
                    TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField('年龄', _ageController, TextInputType.number),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('基本资料'),
            HandDrawnCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildGenderPicker(),
                  const Divider(height: 32),
                  _buildGoalPicker(),
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
                        activeColor: AppColors.primary,
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
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            Center(
              child: HandDrawnButton(
                label: '保存设置',
                onPressed: _saveProfile,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
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

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextMutedColor(context),
          ),
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

  Widget _buildGenderPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '性别',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.getTextMainColor(context),
          ),
        ),
        Row(
          children: [
            _buildChoiceChip(
              '男',
              _gender == Gender.male,
              () => setState(() => _gender = Gender.male),
            ),
            const SizedBox(width: 8),
            _buildChoiceChip(
              '女',
              _gender == Gender.female,
              () => setState(() => _gender = Gender.female),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '健身期望',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.getTextMainColor(context),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildChoiceChip(
              '减重',
              _goal == UserGoal.weightLoss,
              () => setState(() => _goal = UserGoal.weightLoss),
            ),
            _buildChoiceChip(
              '匀称',
              _goal == UserGoal.maintain,
              () => setState(() => _goal = UserGoal.maintain),
            ),
            _buildChoiceChip(
              '增肌',
              _goal == UserGoal.muscleGain,
              () => setState(() => _goal = UserGoal.muscleGain),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: HandDrawnContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 12,
        color: isSelected
            ? AppColors.primary
            : AppColors.getBackgroundColor(context),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMain,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
