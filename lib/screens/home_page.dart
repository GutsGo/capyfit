import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
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
              ...todayPlans.map((plan) => _buildPlanItem(plan, appState)),
              if (todayPlans.isEmpty) _buildEmptyState(),

              const SizedBox(height: 24),

              // Quick Actions
              _buildSectionTitle('快捷入口'),
              const SizedBox(height: 12),
              _buildQuickActions(),
              const SizedBox(
                height: 80,
              ), // Space for nav bar (not implemented yet)
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
                Text(
                  '$greeting，健身达人！',
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '今天也要加油哦~',
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
              ],
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                'assets/images/capybara-mascot.png',
                fit: BoxFit.contain,
              ),
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
          childAspectRatio: 2.2,
          children: [
            _buildStatCard(
              LucideIcons.calendar,
              (3 * val).round().toString(),
              '次',
              '本周训练',
              const Color(0x1A8B6F5C),
              AppColors.primary,
            ),
            _buildStatCard(
              LucideIcons.flame,
              (stats.streakDays * val).round().toString(),
              '天',
              '连续打卡',
              const Color(0x26E8A87C),
              AppColors.accentOrange,
            ),
            _buildStatCard(
              LucideIcons.trendingUp,
              (todayCalories * val).round().toString(),
              'kcal',
              '消耗热量',
              const Color(0x267EB8A2),
              AppColors.accentMint,
            ),
            _buildStatCard(
              LucideIcons.clock,
              (4.5 * val).toStringAsFixed(1),
              'h',
              '训练时长',
              const Color(0x33C4A989),
              AppColors.primary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String unit,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return HandDrawnCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
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
                color: _getPlanTypeColor(plan.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('💪', style: TextStyle(fontSize: 20)),
              ), // Placeholder icon
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: plan.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: plan.completed
                          ? AppColors.textMuted
                          : AppColors.textMain,
                    ),
                  ),
                  Text(
                    '${plan.time} · ${plan.duration}分钟 · ${plan.calories}kcal · ${_getIntensityLabel(plan.intensity)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: plan.completed
                      ? AppColors.accentMint
                      : AppColors.border,
                  width: 2,
                ),
                color: plan.completed ? AppColors.accentMint : null,
              ),
              child: plan.completed
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          LucideIcons.calendar,
          '制定计划',
          '安排今日训练',
          AppColors.primary,
        ),
        _buildActionCard(
          LucideIcons.trendingUp,
          '训练数据',
          '查看进度统计',
          AppColors.accentMint,
        ),
        _buildActionCard(
          LucideIcons.flame,
          '记录饮食',
          '追踪营养摄入',
          AppColors.accentOrange,
        ),
        _buildActionCard(
          LucideIcons.dumbbell,
          '动作库',
          '学习标准动作',
          AppColors.primaryLight,
        ),
      ],
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String label,
    String desc,
    Color color,
  ) {
    return HandDrawnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            desc,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("今天还没有计划哦~"));
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
