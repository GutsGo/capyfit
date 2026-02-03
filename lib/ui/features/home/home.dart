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
      duration: const Duration(milliseconds: 1000),
    );
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _fadeController.forward();
        _countController.forward();
      }
    });
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        LucideIcons.footprints,
                        '${(appState.todaySteps * val).round()}',
                        '/${appState.userProfile.dailyStepsGoal}',
                        '今日步数',
                        GlobalAssets.iconRun,
                        color: const Color(0xFF5D9FE3),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
              if (todayPlans.isNotEmpty) ...[
                HandDrawnCard(
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
                const SizedBox(height: 4),
                const Text(
                  GlobalConstants.homeMotto,
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
              ],
            ),
            Image.asset(
              GlobalAssets.capybaraDance,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
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
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2,
          children: [
            _buildStatCardWithImage(
              LucideIcons.calendar,
              (stats.weeklyWorkoutCount * val).round().toString(),
              '次',
              '本周训练',
              GlobalAssets.iconTrain,
              color: const Color(0xFF8B6B61),
            ),
            _buildStatCardWithImage(
              LucideIcons.flame,
              (stats.streakDays * val).round().toString(),
              '天',
              '连续打卡',
              GlobalAssets.iconCheckin,
              color: const Color(0xFFE57373),
            ),
            _buildStatCardWithImage(
              LucideIcons.trendingUp,
              (stats.todayCalories * val).round().toString(),
              'kcal',
              '消耗热量',
              GlobalAssets.iconKcal,
              color: const Color(0xFF81C784),
            ),
            _buildStatCardWithImage(
              LucideIcons.clock,
              (stats.weeklyDurationHours * val).toStringAsFixed(1),
              'h',
              '训练时长',
              GlobalAssets.iconDuration,
              color: const Color(0xFFA1887F),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCardWithImage(
    IconData icon,
    String value,
    String unit,
    String label,
    String imagePath, {
    Color color = AppColors.primary,
  }) {
    return HandDrawnCard(
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          unit,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextMutedColor(context),
                          ),
                        ),
                      ],
                    ),
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
            ],
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Image.asset(
              imagePath,
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
          ),
        ],
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
    final isStrength = plan.type == WorkoutType.strength;
    final imagePath = isStrength
        ? GlobalAssets.iconStrong
        : GlobalAssets.iconRun;
    final todayStr = GlobalUtils.dateOnly(DateTime.now());
    final isCompleted = plan.isCompletedOn(todayStr);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HandDrawnCard(
        onTap: () => context.push(
          GlobalRoutes.planDetail,
          extra: {'plan': plan, 'date': todayStr},
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getPlanTypeColor(plan.type).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  isStrength ? LucideIcons.dumbbell : LucideIcons.heart,
                  color: _getPlanTypeColor(plan.type),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: isCompleted
                          ? AppColors.getTextMutedColor(context)
                          : AppColors.getTextMainColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${plan.time} · ${GlobalUtils.formatDuration(plan.duration)} · ${plan.calories}kcal · ${_getIntensityLabel(plan.intensity)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getTextMutedColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(imagePath, width: 48, height: 48, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppProvider appState) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildActionCardWithImage(
          GlobalConstants.homeExerciseLibrary,
          '学习标准动作',
          GlobalAssets.iconExerciseLib,
          () => context.push(GlobalRoutes.exercise),
          icon: LucideIcons.dumbbell,
          iconColor: const Color(0xFF8B8B61),
        ),
        _buildActionCardWithImage(
          GlobalConstants.homeDietLibrary,
          '查看食物营养',
          GlobalAssets.iconDietLib,
          () => context.push(GlobalRoutes.dietLibrary),
          icon: LucideIcons.utensils,
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
    required IconData icon,
    required Color iconColor,
  }) {
    return HandDrawnCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          // Icon Top Left
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
          ),
          // Mascot Image Right Center
          Positioned(
            right: 0,
            bottom: 8,
            child: Image.asset(
              imagePath,
              width: 56,
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
          // Text Bottom Left
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return HandDrawnCard(
      child: Center(
        child: Column(
          children: [
            Image.asset(GlobalAssets.iconNoPlan, width: 80, height: 80),
            const SizedBox(height: 8),
            Text(
              GlobalConstants.homeEmptyPlans,
              style: TextStyle(
                color: AppColors.getTextMutedColor(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPlanTypeColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.strength:
        return AppColors.primary;
      case WorkoutType.cardio:
        return AppColors.accentMint;
      default:
        return AppColors.accentOrange;
    }
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
