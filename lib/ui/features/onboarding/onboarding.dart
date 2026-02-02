import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/data/models/user_profile.dart';
import 'package:capyfit/ui/features/onboarding/onboarding_steps.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final _bodyDataFormKey = GlobalKey<FormState>();

  // 当前步骤 (0-4)
  int _currentStep = 0;
  final int _totalSteps = 5;

  // 表单控制器
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _customGoalController;

  // 状态
  Gender _gender = Gender.male;
  UserGoal _goal = UserGoal.maintain;
  bool _isSmart = true;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(text: '170');
    _weightController = TextEditingController(text: '65');
    _ageController = TextEditingController(text: '25');
    _customGoalController = TextEditingController(text: '2000');

    _heightController.addListener(_onInputChanged);
    _weightController.addListener(_onInputChanged);
    _ageController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {});
  }

  int _calculateRecommendedCalories() {
    final height = double.tryParse(_heightController.text) ?? 170;
    final weight = double.tryParse(_weightController.text) ?? 65;
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
    _pageController.dispose();
    _heightController.removeListener(_onInputChanged);
    _weightController.removeListener(_onInputChanged);
    _ageController.removeListener(_onInputChanged);
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _customGoalController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    setState(() => _currentStep = step);
  }

  void _nextStep() {
    // 步骤1（身体数据）需要验证
    if (_currentStep == 1) {
      // 直接验证输入数据
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);
      final age = int.tryParse(_ageController.text);

      if (height == null || height < 50 || height > 300) {
        _showValidationError('请输入有效的身高 (50-300 cm)');
        return;
      }
      if (weight == null || weight < 20 || weight > 500) {
        _showValidationError('请输入有效的体重 (20-500 kg)');
        return;
      }
      if (age == null || age < 1 || age > 150) {
        _showValidationError('请输入有效的年龄 (1-150 岁)');
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _saveAndComplete() {
    final provider = context.read<AppProvider>();
    final newProfile = UserProfile(
      height: double.tryParse(_heightController.text) ?? 170,
      weight: double.tryParse(_weightController.text) ?? 65,
      gender: _gender,
      age: int.tryParse(_ageController.text) ?? 25,
      goal: _goal,
      isSmartCalculation: _isSmart,
      customCalorieGoal: int.tryParse(_customGoalController.text) ?? 2000,
    );
    provider.updateUserProfile(newProfile);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 进度指示器占位，防止布局跳动
            SizedBox(
              height: 60,
              child: _currentStep > 0 ? _buildProgressIndicator() : null,
            ),
            // 页面内容
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  // 步骤0: 欢迎页
                  WelcomeStep(onNext: _nextStep),
                  // 步骤1: 身体数据
                  BodyDataStep(
                    heightController: _heightController,
                    weightController: _weightController,
                    ageController: _ageController,
                    formKey: _bodyDataFormKey,
                  ),
                  // 步骤2: 基本资料
                  ProfileStep(
                    gender: _gender,
                    goal: _goal,
                    onGenderChanged: (g) => setState(() => _gender = g),
                    onGoalChanged: (g) => setState(() => _goal = g),
                  ),
                  // 步骤3: 计算偏好
                  GoalSettingStep(
                    isSmart: _isSmart,
                    recommendedCalories: _calculateRecommendedCalories(),
                    customGoalController: _customGoalController,
                    onSmartChanged: (v) => setState(() => _isSmart = v),
                  ),
                  // 步骤4: 完成确认
                  ConfirmationStep(
                    height: double.tryParse(_heightController.text) ?? 170,
                    weight: double.tryParse(_weightController.text) ?? 65,
                    age: int.tryParse(_ageController.text) ?? 25,
                    gender: _gender,
                    goal: _goal,
                    isSmart: _isSmart,
                    calorieGoal: _isSmart
                        ? _calculateRecommendedCalories()
                        : (int.tryParse(_customGoalController.text) ?? 2000),
                    onComplete: _saveAndComplete,
                  ),
                ],
              ),
            ),
            // 导航按钮（欢迎页和确认页不显示）
            if (_currentStep > 0 && _currentStep < _totalSteps - 1)
              _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: _currentStep > 0 ? _previousStep : null,
            child: Icon(
              LucideIcons.arrowLeft,
              color: _currentStep > 0
                  ? AppColors.getTextMainColor(context)
                  : Colors.transparent,
            ),
          ),
          const SizedBox(width: 16),
          // 进度条
          Expanded(
            child: Row(
              children: List.generate(_totalSteps - 1, (index) {
                // 欢迎页不计入进度，所以从 index+1 开始比较
                final isActive = index < _currentStep;
                final isCurrent = index == _currentStep - 1;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isActive || isCurrent
                          ? AppColors.primary
                          : AppColors.getTextMutedColor(
                              context,
                            ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 16),
          // 步骤计数
          Text(
            '$_currentStep / ${_totalSteps - 1}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // 上一步按钮
          if (_currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: AppColors.getTextMutedColor(
                      context,
                    ).withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '上一步',
                  style: TextStyle(
                    color: AppColors.getTextMainColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 1) const SizedBox(width: 16),
          // 下一步按钮
          Expanded(
            flex: _currentStep > 1 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == _totalSteps - 2 ? '确认信息' : '下一步',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
