import 'package:capyfit/data/utils/assets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/ui/common/widgets/floating_calendar.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/data/utils/routes.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _jumpToToday() {
    setState(() {
      _selectedDate = DateTime.now();
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
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final dayPlans = allPlans.where((p) {
      if (p.isDeleted == true) return false;
      return p.isActiveOn(_selectedDate);
    }).toList();

    // Helper function to determine if plan should show as completed on selected date
    bool isPlanCompleted(WorkoutPlan p) {
      return p.isCompletedOn(selectedDateStr);
    }

    final completedCount = dayPlans.where((p) => isPlanCompleted(p)).length;

    final isHistory = selectedDateStr.compareTo(todayStr) < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练计划'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isSameDay(_selectedDate, DateTime.now()))
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
                style: TextStyle(
                  color: AppColors.getTextMutedColor(context),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 65), // Space for collapsed calendar
              Expanded(
                child: dayPlans.isEmpty
                    ? _buildEmptyState(isHistory)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: dayPlans.length,
                        itemBuilder: (context, index) {
                          final plan = dayPlans[index];
                          final isCompleted = isPlanCompleted(plan);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HandDrawnCard(
                              padding: EdgeInsetsGeometry.all(12),
                              onTap: () => context.push(
                                GlobalRoutes.planDetail,
                                extra: {'plan': plan, 'date': selectedDateStr},
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: _getPlanTypeColor(
                                        plan.type,
                                      ).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        _getPlanTypeImage(plan.type),
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                plan.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  decoration: isCompleted
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                  color: isCompleted
                                                      ? AppColors.getTextMutedColor(
                                                          context,
                                                        )
                                                      : AppColors.getTextMainColor(
                                                          context,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    plan.mode ==
                                                        PlanMode.longTerm
                                                    ? AppColors.primary.withValues(
                                                        alpha:
                                                            Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? 0.25
                                                            : 0.1,
                                                      )
                                                    : AppColors.accentOrange
                                                          .withValues(
                                                            alpha:
                                                                Theme.of(
                                                                      context,
                                                                    ).brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? 0.25
                                                                : 0.1,
                                                          ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                plan.recurrenceLabel,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      plan.mode ==
                                                          PlanMode.longTerm
                                                      ? (Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? AppColors
                                                                  .primaryLight
                                                            : AppColors.primary)
                                                      : (Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? AppColors
                                                                  .accentOrange
                                                                  .withValues(
                                                                    alpha: 0.9,
                                                                  )
                                                            : AppColors
                                                                  .accentOrange),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${plan.duration}分钟 · ${_getIntensityLabel(plan.intensity)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.getTextMutedColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FloatingCalendar(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: HandDrawnFAB(
        heroTag: 'plan_fab',
        onPressed: () => context.push(
          GlobalRoutes.planAdd,
          extra: {'date': selectedDateStr},
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(bool isHistory) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            GlobalAssets.iconNoPlan,
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            '这一天还没有计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextMutedColor(context),
            ),
          ),
          if (!isHistory) ...[
            const SizedBox(height: 8),
            Text(
              '点击右下角按钮添加计划吧~',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextMutedColor(context),
              ),
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
      case WorkoutType.yoga:
        return AppColors.accentPurple;
      case WorkoutType.other:
        return AppColors.accentPink;
    }
  }

  String _getPlanTypeImage(WorkoutType type) {
    switch (type) {
      case WorkoutType.strength:
        return GlobalAssets.iconStrengthType2;
      case WorkoutType.cardio:
        return GlobalAssets.iconCardioType2;
      case WorkoutType.yoga:
        return GlobalAssets.iconYogaType2;
      case WorkoutType.other:
        return GlobalAssets.iconOtherType2;
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
