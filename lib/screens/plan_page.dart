import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/workout_plan.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final plans = appState.plans;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '训练计划',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
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
                          '${plan.date} · ${plan.time} · ${plan.duration}分钟',
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
                    onPressed: () => appState.deletePlan(plan.id),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Navigate to NewPlanPage
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
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
}
