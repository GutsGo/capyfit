import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/hand_drawn_widgets.dart';
import '../models/workout_plan.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _todayStartOfWeek;
  late PageController _pageController;
  int _currentPageIndex = 1000;

  @override
  void initState() {
    super.initState();
    _todayStartOfWeek = _getStartOfWeek(DateTime.now());
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getWeekStartForIndex(int index) {
    return _todayStartOfWeek.add(Duration(days: (index - 1000) * 7));
  }

  void _changeWeek(int offset) {
    _pageController.animateToPage(
      _currentPageIndex + offset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
    );
  }

  void _jumpToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _pageController.animateToPage(
      1000,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutBack,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final allPlans = appState.plans;

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final dayPlans = allPlans.where((p) {
      if (p.mode == PlanMode.oneTime) {
        return p.date == selectedDateStr;
      } else {
        // longTerm: show if selectedDate is on or after p.date
        return selectedDateStr.compareTo(p.date) >= 0;
      }
    }).toList();

    final completedCount = dayPlans.where((p) => p.completed).length;

    final isToday = selectedDateStr == todayStr;
    final isHistory = selectedDateStr.compareTo(todayStr) < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '训练计划',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isSameDay(_selectedDate, DateTime.now()) ||
              _currentPageIndex != 1000)
            IconButton(
              icon: const Icon(
                LucideIcons.calendarDays,
                color: AppColors.primary,
              ),
              onPressed: _jumpToToday,
              tooltip: '回到今天',
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '已完成 '),
                    TextSpan(
                      text: '$completedCount',
                      style: const TextStyle(
                        color: AppColors.accentMint,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: '/${dayPlans.length}'),
                  ],
                ),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: dayPlans.isEmpty
                ? _buildEmptyState(isHistory)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dayPlans.length,
                    itemBuilder: (context, index) {
                      final plan = dayPlans[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HandDrawnCard(
                          onTap: isToday
                              ? () => appState.togglePlanComplete(plan.id)
                              : null,
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getPlanTypeColor(
                                    plan.type,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Icon(
                                    plan.type == WorkoutType.strength
                                        ? LucideIcons.dumbbell
                                        : LucideIcons.heart,
                                    color: _getPlanTypeColor(plan.type),
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            plan.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: plan.completed
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: plan.completed
                                                  ? AppColors.textMuted
                                                  : AppColors.textMain,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                plan.mode == PlanMode.longTerm
                                                ? AppColors.primary.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : AppColors.accentOrange
                                                      .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            plan.mode == PlanMode.longTerm
                                                ? '长期'
                                                : '单次',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  plan.mode == PlanMode.longTerm
                                                  ? AppColors.primary
                                                  : AppColors.accentOrange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${plan.time} · ${plan.duration}分钟 · ${_getIntensityLabel(plan.intensity)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isToday) ...[
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.trash2,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, appState, plan),
                                ),
                                HandDrawnContainer(
                                  width: 28,
                                  height: 28,
                                  borderRadius: 14,
                                  borderWidth: 2,
                                  borderColor: plan.completed
                                      ? AppColors.accentMint
                                      : AppColors.border,
                                  color: plan.completed
                                      ? AppColors.accentMint
                                      : Colors.transparent,
                                  child: plan.completed
                                      ? const Icon(
                                          LucideIcons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : const SizedBox(),
                                ),
                              ] else if (isHistory)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Icon(
                                    plan.completed
                                        ? LucideIcons.checkCircle2
                                        : LucideIcons.circle,
                                    size: 20,
                                    color: plan.completed
                                        ? AppColors.accentMint
                                        : AppColors.border,
                                  ),
                                ),
                              // if isFuture, show no status and no operations as requested ("无状态和操作")
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: HandDrawnFAB(
        heroTag: 'plan_fab',
        onPressed: () => context.push('/plan/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildCalendar() {
    final currentWeekStart = _getWeekStartForIndex(_currentPageIndex);

    return HandDrawnContainer(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      borderRadius: 24,
      borderColor: AppColors.primary,
      borderWidth: 1.5,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.chevronLeft, size: 20),
                onPressed: () => _changeWeek(-1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                DateFormat(
                  'yyyy年M月',
                ).format(currentWeekStart.add(const Duration(days: 3))),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.chevronRight, size: 20),
                onPressed: () => _changeWeek(1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 85,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemBuilder: (context, weekIndex) {
                final weekStart = _getWeekStartForIndex(weekIndex);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (dayIndex) {
                    final date = weekStart.add(Duration(days: dayIndex));
                    final isSelected = _isSameDay(date, _selectedDate);
                    final isToday = _isSameDay(date, DateTime.now());
                    final weekDays = ['一', '二', '三', '四', '五', '六', '日'];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        width: 40,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryDark
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              weekDays[dayIndex],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textMain,
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(height: 2),
                              Text(
                                '今天',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : AppColors.accentOrange,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isHistory) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/capybara-mascot.png',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            '这一天还没有计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          if (!isHistory) ...[
            const SizedBox(height: 8),
            const Text(
              '点击右下角按钮添加计划吧~',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 60), // Adjust for FAB space
        ],
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

  void _confirmDelete(
    BuildContext context,
    AppProvider state,
    WorkoutPlan plan,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: HandDrawnContainer(
          color: AppColors.background,
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '确认删除',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                '确定要删除计划 "${plan.name}" 吗？',
                style: const TextStyle(fontSize: 16, color: AppColors.textMain),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '取消',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HandDrawnButton(
                    onPressed: () {
                      state.deletePlan(plan.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('计划已删除'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    label: '删除',
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
