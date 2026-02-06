import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/data/utils/assets.dart';
import 'package:capyfit/data/utils/constants.dart';
import 'package:capyfit/data/utils/utils.dart';
import 'package:capyfit/data/utils/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _countController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeController.forward();
    _countController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();

    final stats = appState.userStats;
    final today = DateTime.now();
    final dateStr = GlobalUtils.formatDate(today);
    final greeting = GlobalUtils.getGreeting();

    final todayStr = GlobalUtils.dateOnly(today);

    final todayPlans = appState.plans
        .where((p) => p.isActiveOn(today))
        .toList();

    // Priority: oneTime (0) > longTerm (1)
    final modePriority = {PlanMode.oneTime: 0, PlanMode.longTerm: 1};

    // Sort function for priority
    int comparePriority(WorkoutPlan a, WorkoutPlan b) {
      int cmp = modePriority[a.mode]!.compareTo(modePriority[b.mode]!);
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id); // Tie-breaker
    }

    final allSorted = List<WorkoutPlan>.from(todayPlans)..sort(comparePriority);
    final uncompleted = allSorted
        .where((p) => !p.isCompletedOn(todayStr))
        .toList();
    final completed = allSorted
        .where((p) => p.isCompletedOn(todayStr))
        .toList();

    final List<WorkoutPlan> candidates = [];
    candidates.addAll(uncompleted.take(2));
    if (candidates.length < 2) {
      candidates.addAll(completed.take(2 - candidates.length));
    }

    // Final sort to maintain stable order if no new plans were pulled in
    final visiblePlans = candidates..sort(comparePriority);

    final completedCount = todayPlans
        .where((p) => p.isCompletedOn(todayStr))
        .length;
    final progress = todayPlans.isEmpty
        ? 0.0
        : completedCount / todayPlans.length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              _buildHeader(dateStr, greeting, appState),
              const SizedBox(height: 24),

              // Stats Grid
              _buildStatsGrid(stats),
              const SizedBox(height: 24),

              // Today's Plan Section
              _buildSectionTitle(GlobalConstants.homeTitle),
              const SizedBox(height: 12),
              // Steps Card (Full Width)
              if (appState.userProfile.dailyStepsGoal != null) ...[
                AnimatedBuilder(
                  animation: _countController,
                  builder: (context, child) {
                    final val = _countController.value;
                    return GestureDetector(
                      onTap: () => _showStepsInput(context, appState),
                      child: _buildStatCardWithImage(
                        '${(appState.todaySteps * val).round()}',
                        '/${appState.userProfile.dailyStepsGoal}',
                        '今日步数',
                        GlobalAssets.iconCardioType,
                        color: const Color(0xFF5D9FE3),
                        fullWidth: true,
                        isAchieved:
                            appState.todaySteps >=
                            (appState.userProfile.dailyStepsGoal ?? 0),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
              if (todayPlans.isNotEmpty) ...[
                HandDrawnCard(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            GlobalConstants.homeProgress,
                            style: TextStyle(
                              color: AppColors.getTextMutedColor(context),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$completedCount/${todayPlans.length}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CustomProgressBar(progress: progress),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Plan List
              ...visiblePlans.map((plan) => _buildPlanItem(plan, appState)),
              if (todayPlans.isEmpty) _buildEmptyState(),

              const SizedBox(height: 24),

              // Quick Actions
              _buildSectionTitle(GlobalConstants.homeQuickActions),
              const SizedBox(height: 12),
              _buildQuickActions(context, appState),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String date, String greeting, AppProvider appState) {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.getTextMutedColor(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$greeting，${appState.userProfile.nickname ?? GlobalConstants.profileUserDefaultName}！',
                  style: TextStyle(
                    color: AppColors.getTextMainColor(context),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(UserStats stats) {
    return AnimatedBuilder(
      animation: _countController,
      builder: (context, child) {
        final val = _countController.value;
        return Row(
          children: [
            Expanded(
              child: _buildVerticalStatCard(
                (stats.weeklyWorkoutCount * val).round().toString(),
                '次',
                '本周训练',
                GlobalAssets.iconTrain,
                isAchieved: stats.weeklyWorkoutCount >= 10,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildVerticalStatCard(
                (stats.streakDays * val).round().toString(),
                '天',
                '连续打卡',
                GlobalAssets.iconCheckin,
                isAchieved: stats.streakDays >= 5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildVerticalStatCard(
                (stats.todayCalories * val).round().toString(),
                'kcal',
                '消耗热量',
                GlobalAssets.iconKcal,
                isAchieved: stats.todayCalories >= 8000,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildVerticalStatCard(
                (stats.weeklyDurationHours * val).toStringAsFixed(1),
                'h',
                '训练时长',
                GlobalAssets.iconDuration,
                isAchieved: stats.weeklyDurationHours >= 12,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVerticalStatCard(
    String value,
    String unit,
    String label,
    String imagePath, {
    bool isAchieved = false,
  }) {
    final bgColor = isAchieved
        ? AppColors.accentOrange.withValues(alpha: 0.2)
        : null;

    return HandDrawnCard(
      padding: EdgeInsets.zero,
      color: bgColor,
      child: SizedBox(
        height:
            105, // Define a fixed height to avoid layout issues in ScrollView
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bottom Image with clipping effect
              Positioned(
                bottom: -12,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset(
                    imagePath,
                    height: 54,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Text Content area at the top
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isAchieved
                                  ? AppColors.accentOrange
                                  : AppColors.getTextMainColor(context),
                            ),
                          ),
                          const SizedBox(width: 1),
                          Text(
                            unit,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.getTextMutedColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.getTextMutedColor(context),
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildStatCardWithImage(
    String value,
    String unit,
    String label,
    String imagePath, {
    Color color = AppColors.primary,
    bool fullWidth = false,
    bool isAchieved = false,
  }) {
    final bgColor = isAchieved
        ? AppColors.accentOrange.withValues(alpha: 0.2)
        : null;

    return HandDrawnCard(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.zero,
      color: bgColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isAchieved
                              ? AppColors.accentOrange
                              : AppColors.getTextMainColor(context),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextMutedColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextMutedColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -4,
              bottom: -8,
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  imagePath,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextMainColor(context),
      ),
    );
  }

  Widget _buildPlanItem(WorkoutPlan plan, AppProvider appState) {
    final todayStr = GlobalUtils.dateOnly(DateTime.now());
    final isCompleted = plan.isCompletedOn(todayStr);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HandDrawnCard(
        width: double.infinity,
        onTap: () => context.push(
          GlobalRoutes.planDetail,
          extra: {'plan': plan, 'date': todayStr},
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check for narrow screens (e.g. iPhone SE 1st gen is 320px wide)
            // Card content width approx: 320 - 32(screen pad) - 24(card pad) = 264
            // Standard iPhone (375px) width approx: 319
            final isNarrow = constraints.maxWidth < 300;

            final infoText = isNarrow
                ? GlobalUtils.formatDuration(plan.duration)
                : '${GlobalUtils.formatDuration(plan.duration)} · ${plan.calories}kcal · ${_getIntensityLabel(plan.intensity)}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? AppColors.getTextMutedColor(context)
                        : AppColors.getTextMainColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  infoText,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextMutedColor(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppProvider appState) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 84,
      ),
      children: [
        _buildActionCardWithImage(
          GlobalConstants.homeExerciseLibrary,
          '学习标准动作',
          GlobalAssets.iconExerciseLib,
          () => context.push(GlobalRoutes.exercise),
          iconColor: const Color(0xFF8B8B61),
        ),
        _buildActionCardWithImage(
          GlobalConstants.homeDietLibrary,
          '查看食物营养',
          GlobalAssets.iconDietLib,
          () => context.push(GlobalRoutes.dietLibrary),
          iconColor: const Color(0xFFC17D5C),
        ),
      ],
    );
  }

  Widget _buildActionCardWithImage(
    String label,
    String desc,
    String imagePath,
    VoidCallback onTap, {
    required Color iconColor,
  }) {
    return HandDrawnCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.getTextMainColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -4,
              bottom: -8,
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  imagePath,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return HandDrawnCard(
      child: Center(
        child: Column(
          children: [
            Image.asset(GlobalAssets.iconNoPlan, width: 64, height: 64),
            const SizedBox(height: 8),
            Text(
              GlobalConstants.homeEmptyPlans,
              style: TextStyle(
                color: AppColors.getTextMutedColor(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIntensityLabel(Intensity intensity) {
    switch (intensity) {
      case Intensity.high:
        return GlobalConstants.planHighIntensity;
      case Intensity.medium:
        return GlobalConstants.planMediumIntensity;
      case Intensity.low:
        return GlobalConstants.planLowIntensity;
    }
  }

  void _showStepsInput(BuildContext context, AppProvider appState) {
    final controller = TextEditingController(
      text: appState.todaySteps.toString(),
    );
    final formKey = GlobalKey<FormState>();

    HandDrawnBottomSheet.show(
      context: context,
      builder: (context) => Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '记录今日步数',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            HandDrawnTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              hintText: '输入步数',
              suffixIcon: const Icon(LucideIcons.footprints, size: 16),
              autofocus: true,
              validator: (val) {
                if (val == null || val.isEmpty) return '请输入步数';
                final steps = int.tryParse(val);
                if (steps == null) return '请输入有效的数字';
                if (steps > 500000) return '步数不能超过 500,000';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: AppColors.getTextMutedColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                HandDrawnButton(
                  label: '确定',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final steps = int.parse(controller.text);
                      appState.updateDailySteps(steps);
                      Navigator.pop(context);
                      showHandDrawnSnackBar(context, '步数已更新！');
                    }
                  },
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
