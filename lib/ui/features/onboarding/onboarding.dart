import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/data/models/user_profile.dart';
import 'package:capyfit/ui/features/onboarding/onboarding_steps.dart';
import 'package:capyfit/data/utils/constants.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  // 当前步骤 (0-2)
  int _currentStep = 0;
  final int _totalSteps = 3;

  // 表单控制器
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;

  // 状态
  Gender _gender = Gender.male;
  UserGoal _goal = UserGoal.maintain;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _ageController = TextEditingController();

    _heightController.addListener(_onInputChanged);
    _weightController.addListener(_onInputChanged);
    _ageController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {});
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
    super.dispose();
  }

  bool _isMoving = false;

  void _goToStep(int step) {
    if (_isMoving || !_pageController.hasClients) return;

    if (_currentStep == step) return;

    _isMoving = true;
    _pageController
        .animateToPage(
          step,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        )
        .then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() => _isMoving = false);
            }
          });
        });

    setState(() => _currentStep = step);
  }

  void _nextStep() {
    if (_isMoving) return;

    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    } else if (_currentStep == _totalSteps - 1) {
      _saveAndComplete();
    }
  }

  void _handleBodyDataNext() {
    if (_heightController.text.trim().isEmpty ||
        _weightController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty) {
      showHandDrawnSnackBar(
        context,
        '请填写完整身体数据后再继续，或点击跳过',
        type: ToastType.info,
      );
      return;
    }
    _nextStep();
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
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

  void _saveAndComplete() {
    final provider = context.read<AppProvider>();
    final newProfile = UserProfile(
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      gender: _gender,
      age: int.tryParse(_ageController.text),
      goal: _goal,
      isSmartCalculation: true,
      nickname: GlobalConstants.profileUserDefaultName,
      avatarPath: GlobalConstants.profileDefaultAvatar,
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
              child: AbsorbPointer(
                absorbing: _isMoving,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    if (_currentStep != index) {
                      setState(() => _currentStep = index);
                    }
                  },
                  children: [
                    // 步骤0: 欢迎页
                    WelcomeStep(onNext: _nextStep),
                    // 步骤1: 身体数据 + 性别
                    BodyDataStep(
                      heightController: _heightController,
                      weightController: _weightController,
                      ageController: _ageController,
                      gender: _gender,
                      onGenderChanged: (g) => setState(() => _gender = g),
                      onNext: _handleBodyDataNext,
                      onSkip: _nextStep,
                    ),
                    // 步骤2: 健身目标
                    ProfileStep(
                      goal: _goal,
                      onGoalChanged: (g) => setState(() => _goal = g),
                      onNext: _saveAndComplete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
