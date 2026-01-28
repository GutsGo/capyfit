import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/hand_drawn_widgets.dart';
import '../models/workout_plan.dart';

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

  int _lastIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final currentTab = appState.currentTabIndex;

    // Check if we just switched back to the Home tab
    if (currentTab == 0 && _lastIndex != 0) {
      _fadeController.forward(from: 0);
      _countController.forward(from: 0);
    }
    _lastIndex = currentTab;

    final stats = appState.userStats;
    final today = DateTime.now();
    final dateStr = "${today.year}年${today.month}月${today.day}日";
    final greeting = today.hour < 12
        ? '早安'
        : today.hour < 18
        ? '午安'
        : '晚安';

    final todayPlans = appState.plans
        .where((p) => p.date == today.toString().split(' ')[0])
        .toList();

    // Priority: oneTime (0) > timed (1) > longTerm (2)
    final modePriority = {
      PlanMode.oneTime: 0,
      PlanMode.timed: 1,
      PlanMode.longTerm: 2,
    };

    // Sort function for priority
    int comparePriority(WorkoutPlan a, WorkoutPlan b) {
      int cmp = modePriority[a.mode]!.compareTo(modePriority[b.mode]!);
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id); // Tie-breaker
    }

    final allSorted = List<WorkoutPlan>.from(todayPlans)..sort(comparePriority);
    final uncompleted = allSorted.where((p) => !p.completed).toList();
    final completed = allSorted.where((p) => p.completed).toList();

    final List<WorkoutPlan> candidates = [];
    candidates.addAll(uncompleted.take(2));
    if (candidates.length < 2) {
      candidates.addAll(completed.take(2 - candidates.length));
    }

    // Final sort to maintain stable order if no new plans were pulled in
    final visiblePlans = candidates..sort(comparePriority);

    final completedCount = todayPlans.where((p) => p.completed).length;
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
              _buildHeader(dateStr, greeting),
              const SizedBox(height: 24),

              // Stats Grid
              _buildStatsGrid(stats, appState.todayConsumedCalories),
              const SizedBox(height: 24),

              // Today's Plan Section
              _buildSectionTitle('今日训练计划', onSeeAll: () {}),
              const SizedBox(height: 12),

              HandDrawnCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '今日完成进度',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$completedCount/${todayPlans.length}',
                          style: const TextStyle(
                            color: AppColors.primary,
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

              // Plan List
              ...visiblePlans.map((plan) => _buildPlanItem(plan, appState)),
              if (todayPlans.isEmpty) _buildEmptyState(),

              const SizedBox(height: 24),

              // Quick Actions
              _buildSectionTitle('快捷入口'),
              const SizedBox(height: 12),
              _buildQuickActions(context, appState),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String date, String greeting) {
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
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$greeting，健身达人！',
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '今天也要加油哦~',
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
              ],
            ),
            Image.asset(
              'assets/images/capybara-mascot.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(UserStats stats, int todayCalories) {
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
          childAspectRatio: 3,
          children: [
            _buildStatCardWithImage(
              LucideIcons.calendar,
              (3 * val).round().toString(),
              '次',
              '本周训练',
              'assets/images/icons/strong.png',
              color: const Color(0xFF8B6B61),
            ),
            _buildStatCardWithImage(
              LucideIcons.flame,
              (stats.streakDays * val).round().toString(),
              '天',
              '连续打卡',
              'assets/images/icons/energe.png',
              color: const Color(0xFFE57373),
            ),
            _buildStatCardWithImage(
              LucideIcons.trendingUp,
              (todayCalories * val).round().toString(),
              'kcal',
              '消耗热量',
              'assets/images/icons/pad.png',
              color: const Color(0xFF81C784),
            ),
            _buildStatCardWithImage(
              LucideIcons.clock,
              (4.5 * val).toStringAsFixed(1),
              'h',
              '训练时长',
              'assets/images/icons/clock.png',
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
                  color: color.withOpacity(0.15),
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
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

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: const Row(
              children: [
                Text(
                  '查看全部',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPlanItem(WorkoutPlan plan, AppProvider appState) {
    final isStrength = plan.type == WorkoutType.strength;
    final imagePath = isStrength
        ? 'assets/images/icons/strong.png'
        : 'assets/images/icons/run.png';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HandDrawnCard(
        onTap: () {
          appState.togglePlanComplete(plan.id);
          _countController.forward(from: 0);
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getPlanTypeColor(plan.type).withOpacity(0.15),
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
                      decoration: plan.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: plan.completed
                          ? AppColors.textMuted
                          : AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${plan.time} · ${plan.duration}分钟 · ${plan.calories}kcal · ${_getIntensityLabel(plan.intensity)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(imagePath, width: 48, height: 48, fit: BoxFit.contain),
            const SizedBox(width: 8),
            HandDrawnContainer(
              width: 24,
              height: 24,
              borderRadius: 12,
              borderWidth: 2,
              borderColor: plan.completed
                  ? AppColors.accentMint
                  : AppColors.textMuted,
              color: plan.completed ? AppColors.accentMint : Colors.transparent,
              child: plan.completed
                  ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                  : const SizedBox(),
            ),
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
          '动作库',
          '学习标准动作',
          'assets/images/icons/weightlifting.png',
          () => context.push('/exercise'),
          icon: LucideIcons.dumbbell,
          iconColor: const Color(0xFF8B8B61),
        ),
        _buildActionCardWithImage(
          '膳食库',
          '查看食物营养',
          'assets/images/icons/eat.png',
          () => context.push('/diet/library'),
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
                color: iconColor.withOpacity(0.15),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textMain,
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
            Image.asset(
              'assets/images/icons/calendar.png',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 8),
            const Text(
              '今天还没有计划哦~',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
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
        return '高强度';
      case Intensity.medium:
        return '中等强度';
      case Intensity.low:
        return '低强度';
    }
  }
}
