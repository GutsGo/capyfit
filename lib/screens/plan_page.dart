import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/workout_plan.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getStartOfWeek(DateTime.now());
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _changeWeek(int offset) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * offset));
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final allPlans = appState.plans;

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dayPlans = allPlans.where((p) => p.date == selectedDateStr).toList();
    final completedCount = dayPlans.where((p) => p.completed).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '训练计划',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '已完成 $completedCount/${dayPlans.length}',
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
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dayPlans.length,
                    itemBuilder: (context, index) {
                      final plan = dayPlans[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HandDrawnCard(
                          onTap: () => appState.togglePlanComplete(plan.id),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getPlanTypeColor(
                                    plan.type,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(child: Text('🏋️')),
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
                                      '${plan.time} · ${plan.duration}分钟',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    _confirmDelete(context, appState, plan),
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
                                  color: plan.completed
                                      ? AppColors.accentMint
                                      : null,
                                ),
                                child: plan.completed
                                    ? const Icon(
                                        LucideIcons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/plan/add'),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                ).format(_currentWeekStart.add(const Duration(days: 3))),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = _currentWeekStart.add(Duration(days: index));
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
                        weekDays[index],
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
                          color: isSelected ? Colors.white : AppColors.textMain,
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
          const SizedBox(height: 8),
          const Text(
            '点击右下角按钮添加计划吧~',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
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

  void _confirmDelete(
    BuildContext context,
    AppProvider state,
    WorkoutPlan plan,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除计划 "${plan.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
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
            child: const Text('删除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
